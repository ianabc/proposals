# A class for interacting with the HMC schedule optimizer

class HungarianMonteCarlo
  require 'socket'
  attr_reader :errors

  def initialize(schedule_run:, test_mode: false)
    @schedule_run = schedule_run
    @location = schedule_run.location
    @test_mode = test_mode

    @errors = {}
    set_hmc_params
    validate_location
    update_run_params
  end

  def run_optimizer
    socket = hmc_connect
    socket.puts @hmc_access_code if hmc_reply(socket, 'Access code')
    socket.puts('newrun') if hmc_reply(socket, 'READY')
    socket.puts(formatted_run_params) if hmc_reply(socket, 'Run parameters')
    socket.puts proposal_data.join("\n") if hmc_reply(socket, 'Send proposals')
    update_schedule_runs(socket)
    socket.close
  end

  def hmc_reply(socket, prompt)
    socket.gets.chomp.match?(prompt)
  rescue IOError => e
    @errors['HMC'] = "Error reading socket! #{e.message}"
  end

  def hmc_connect
    TCPSocket.open(@hmc_server, @hmc_port)
  rescue IOError => e
    @errors['HMC'] = "Error connecting to HMC! #{e.message}"
  end

  def update_schedule_runs(socket)
    output = socket.gets.chomp
    if output.match?('HMC launched')
      pid = output.split(':').last.strip.to_i
      update_schedule_run(pid)
    else
      @errors['HMC runtime error'] = "HMC failed to launch for run
                                      #{@schedule_run.id}!".squish
    end
  end

  def proposal_data
    formatted_data = @test_mode ? hmc_formatted_test_data : hmc_formatted_data
    add_placeholder_events(formatted_data.values)
  end

  def hmc_formatted_test_data
    proposals = Proposal.where(year: @schedule_run.year).limit(program_weeks)

    proposals.shuffle.each_with_object({}) do |proposal, data|
      next if invalid_proposal?(proposal)

      priority = 2
      code = proposal.code
      preferred_dates = format_dates(proposal.preferred_dates).join(';')
      impossible_dates = format_dates(proposal.impossible_dates).join(';')

      data[code] = "#{code}:#{priority}: #{preferred_dates}: #{impossible_dates}:"
    end
  end

  def hmc_formatted_data
    proposals = Proposal.where(assigned_location: @location)
                        .where(outcome: 'Accepted')
                        .where(year: @schedule_run.year)

    skip_proposals = []
    proposals.shuffle.each_with_object({}) do |proposal, data|
      next if invalid_proposal?(proposal)
      next if skip_proposals.include?(proposal)

      priority = 2
      code = proposal.code
      preferred_dates = format_dates(proposal.preferred_dates).join(';')
      impossible_dates = format_dates(proposal.impossible_dates).join(';')

      if proposal.assigned_date.present?
        priority = 1
        preferred_dates = format_dates([proposal.assigned_date]).first
      end

      code << " (1/2 workshop)" if proposal.assigned_size == 'Half'

      if proposal.same_week_as.present?
        code = "#{proposal.same_week_as&.code} and #{proposal.code}"
        preferred_dates, impossible_dates, data, skip_proposals =
          merge_and_purge(proposal.same_week_as, proposal, data, skip_proposals)
      end

      if proposal.week_after.present?
        code = "#{proposal.week_after&.code} followed by #{proposal.code}"
        preferred_dates, impossible_dates, data, skip_proposals =
          merge_and_purge(proposal.week_after, proposal, data, skip_proposals)
      end

      data[code] = "#{code}:#{priority}: #{preferred_dates}: #{impossible_dates}:"
    end
  end

  def add_placeholder_events(proposal_data)
    return proposal_data if @location.exclude_dates.blank?

    prefix = "#{@schedule_run.year.to_s.chars.last(2).join}w"
    code_num = 6660

    format_dates(@location.exclude_dates).each do |date|
      proposal_data << "#{prefix}#{code_num}:1: #{date}: :"
      code_num += 1
    end
    proposal_data
  end

  private

  def update_schedule_run(pid)
    if pid.blank?
      @errors['HMC runtime error'] = "No process ID returned for run
                                      #{@schedule_run.id}!".squish
    else
      @schedule_run.update_columns(pid: pid)
    end
  end

  def set_hmc_params
    @hmc_server = ENV['HMC_SERVER']
    @hmc_port = ENV['HMC_PORT']
    @hmc_access_code = ENV['HMC_ACCESS']

    return unless [@hmc_server, @hmc_port, @hmc_access_code].any?(&:blank?)

    @errors['HMC settings'] = "Missing HMC environment variable!"
  end

  def validate_location
    unless @location.start_date.sunday?
      @errors['Location'] = "Location #{@location.code} start_date is not a
                             Sunday!".squish
    end

    return if @location.end_date.friday?

    @errors['Location'] << "Location #{@location.code} end_date is not a
                            Friday!".squish
  end

  def update_run_params
    @schedule_run.update_columns(startweek: @location.start_date,
                                 weeks: program_weeks,
                                 start_time: DateTime.current)
  end

  def program_weeks
    extend SchedulesHelper
    weeks_in_location(@location)
  end

  def invalid_proposal?(proposal)
    return if proposal.code.present?

    error_message = "#{proposal.title} (id: #{proposal.id}) has no code!"
    if @errors['Proposal'].blank?
      @errors['Proposal'] = error_message
    else
      @errors['Proposal'] << "\n #{error_message}"
    end
  end

  def format_dates(dates)
    dates.map { |d| d.strftime("%m/%d/%Y") }
  end

  def formatted_run_params
    # Usage: HungarianMonteCarlo <run_id> <date of first workshop (yyyy-mm-dd)>
    # <number of weeks> <number of runs> <number of cases>\n")
    s = @schedule_run
    start_week = s.startweek.strftime("%Y-%m-%d")
    "#{s.id} #{start_week} #{s.weeks} #{s.runs} #{s.cases}"
  end

  def merge_and_purge(proposal1, proposal2, data, skip_proposals)
    merged_dates = merge_preferred_dates(proposal1, proposal2)
    preferred_dates = format_dates(merged_dates).join(';')

    merged_dates = merge_impossible_dates(proposal1, proposal2)
    impossible_dates = format_dates(merged_dates).join(';')

    if data.key?(proposal1&.code)
      data.delete(proposal1&.code)
    else
      skip_proposals << proposal1
    end

    [preferred_dates, impossible_dates, data, skip_proposals]
  end

  def assigned?(proposal1, proposal2)
    proposal1.assigned_date.present? || proposal2.assigned_date.present?
  end

  def assigned(proposal1, proposal2)
    return [proposal1.assigned_date] if proposal1.assigned_date.present?

    # see adjust_preferred_week() for explanation
    return [proposal2.assigned_date - 1.week] if proposal2.week_after.present?

    [proposal2.assigned_date]
  end

  def most_dates(proposal1, proposal2)
    [proposal1.preferred_dates.count, proposal2.preferred_dates.count].max
  end

  def adjust_preferred_week(proposal)
    preferred_dates = proposal.preferred_dates

    # For .week_after, both proposals will be given to the optimzer as one event,
    # "event1 followed by event2". Therefore, proposal2's preferred dates must
    # be set to a week earlier so that the schedule optimizer assigns it to
    # the actual preferred date of proposal2, the week after proposal1
    preferred_dates = proposal.preferred_dates.map { |d| d - 1.week } if proposal.week_after.present?

    preferred_dates
  end

  def merge_preferred_dates(proposal1, proposal2)
    return assigned(proposal1, proposal2) if assigned?(proposal1, proposal2)

    proposal2_preferred = adjust_preferred_week(proposal2)

    merged = []
    most_dates(proposal1, proposal2).times do |i|
      merged << proposal1.preferred_dates[i] if proposal1.preferred_dates[i]
      merged << proposal2_preferred[i] if proposal2_preferred[i]
    end
    merged.uniq
  end

  def merge_impossible_dates(proposal1, proposal2)
    proposal2_impossible = proposal2.impossible_dates

    proposal2_impossible = proposal2.impossible_dates.map { |d| d - 1.week } if proposal2.week_after.present?

    (proposal1.impossible_dates + proposal2_impossible).uniq
  end
end
