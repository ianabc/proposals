# A class for interacting with the HMC schedule optimizer

class HungarianMonteCarlo
  require 'socket'
  attr_reader :errors

  def initialize(schedule_run:)
    @schedule_run = schedule_run
    @location = schedule_run.location
    @errors = {}

    set_hmc_params
    update_run_params
  end

  def run_optimizer
    socket = hmc_connect
    return if @errors.present?

    socket.puts "#{@hmc_access_code}.to_s" if hmc_reply(socket, 'Access code')
    socket.puts "newrun" if hmc_reply(socket, 'READY')
    socket.puts formatted_run_params if hmc_reply(socket, 'Run parameters')
    socket.puts proposal_data.join("\n") if hmc_reply(socket, 'Send proposals')
    update_schedule_runs(socket)
    socket.close
    @schedule_run.pid
  end

  def hmc_reply(socket, prompt)
    socket.gets&.chomp&.match?(prompt)
  rescue => e
    @errors['HMC'] = "Error reading socket! #{e.message}"
  end

  def hmc_connect
    TCPSocket.open(@hmc_server, @hmc_port)
  rescue SocketError => e
    @errors['HMC'] = "Error connecting to HMC! #{e.message}"
  end

  def update_schedule_runs(socket)
    output = ''
    output << line while line == socket&.gets

    if output.match?('Launching HungarianMonteCarlo')
      pid = output.split(':').last.strip.to_i
      update_schedule_run(pid) if pid.present?
    else
      @errors['HMC runtime error'] = "HMC may not have launched".squish
    end
  end

  def proposal_data
    formatted_data = @schedule_run.test_mode ? hmc_test_data : hmc_formatted_data
    # trailing newline at end of input required
    add_placeholder_events(formatted_data.values.shuffle) << "\n"
  end

  def hmc_test_data
    proposals = Proposal.where(year: @schedule_run.year)
                        .where.not(code: nil).limit(@location.num_weeks)

    proposals.each_with_object({}) do |proposal, data|
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
                        .where(outcome: 'Approved')
                        .where(year: @schedule_run.year)

    skip_proposals = []
    proposals.each_with_object({}) do |proposal, data|
      next if invalid_proposal?(proposal)
      next if skip_proposals.include?(proposal)

      priority = 2
      code = proposal.code
      preferred_dates = format_dates(proposal.preferred_dates).join(';')
      impossible_dates = format_dates(proposal.impossible_dates).join(';')

      if proposal.assigned_date.present?
        priority = 1
        start_date = proposal.assigned_date
        end_date = start_date + 5.days
        preferred_dates = format_dates([start_date, end_date]).join(';')
      end

      code << " (1/2 workshop)" if proposal.assigned_size == 'Half'

      if proposal.same_week_as.present?
        other_proposal = find_other_proposal(proposal.code,
                                             proposal.same_week_as,
                                             'same_week_as')
        next if other_proposal.blank?

        code = "#{other_proposal&.code} and #{proposal.code}"
        preferred_dates, impossible_dates, data, skip_proposals =
          merge_and_purge(other_proposal, proposal, data, skip_proposals)
      end

      if proposal.week_after.present?
        other_proposal = find_other_proposal(proposal.code,
                                             proposal.same_week_as,
                                             'week_after')
        next if other_proposal.blank?

        code = "#{other_proposal&.code} followed by #{proposal.code}"
        preferred_dates, impossible_dates, data, skip_proposals =
          merge_and_purge(other_proposal, proposal, data, skip_proposals)
      end

      data[code] = "#{code}:#{priority}: #{preferred_dates}: #{impossible_dates}:"
    end
  end

  def formatted_excluded_dates
    @location.exclude_dates.each_with_object([]) do |date_range, excluded|
      next if date_range.blank?

      start_date, end_date = date_range.split(' - ')
      excluded << [Date.parse(start_date).strftime("%m/%d/%Y"),
                   Date.parse(end_date).strftime("%m/%d/%Y")]
    end
  end

  def add_placeholder_events(proposal_data)
    return proposal_data if @location.exclude_dates.blank?

    prefix = "#{@schedule_run.year.to_s.chars.last(2).join}w"
    code_num = 6600

    formatted_excluded_dates.each do |dates|
      # Priority 1 ensures that placeholder proposal is scheduled on 1st date
      proposal_data << "#{prefix}#{code_num}:1: #{dates[0]};#{dates[1]}: :"
      code_num += 1
    end
    proposal_data
  end

  def formatted_run_params
    # Usage: HungarianMonteCarlo <run_id> <date of first workshop (yyyy-mm-dd)>
    # <number of weeks> <number of runs> <number of cases>\n")
    s = @schedule_run
    start_week = s.startweek.strftime("%Y-%m-%d")
    "#{s.id} #{start_week} #{s.weeks} #{s.runs} #{s.cases}"
  end

  private

  def find_other_proposal(code, other_code, kind)
    other_proposal = Proposal.find_by(code: other_code)
    if other_proposal.blank?
      @errors[kind] = "Proposal #{code} has non-existent proposal #{other_code}
                       in its #{kind} field!".squish
    end
    other_proposal
  end

  def update_schedule_run(pid)
    if pid.blank?
      @errors['HMC runtime error'] = "No process ID returned for run
                                      #{@schedule_run.id}!".squish
    else
      @schedule_run.update_columns(pid: pid, start_time: DateTime.current)
    end
  end

  def set_hmc_params
    @hmc_server = ENV.fetch('HMC_SERVER', nil)
    @hmc_port = ENV.fetch('HMC_PORT', nil)
    @hmc_access_code = ENV.fetch('HMC_ACCESS', nil)

    return unless [@hmc_server, @hmc_port, @hmc_access_code].any?(&:blank?)

    @errors['HMC settings'] = "Missing HMC environment variable!"
  end

  def save_schedule_run
    @schedule_run.save
  rescue ActiveRecord::Error => e
    @errors['ScheduleRun'] = "Error saving ScheduleRun record: #{e.message}."
    @errors['ScheduleRun'] << "\n\n#{@schedule_run.inspect}"
  end

  def update_run_params
    save_schedule_run if @schedule_run.id.blank?

    @schedule_run.update_columns(startweek: @location.start_date,
                                 weeks: @location.num_weeks)
  rescue ActiveRecord::ActiveRecordError => e
    @errors['ScheduleRun'] = "Error updating ScheduleRun record: #{e.message}."
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
