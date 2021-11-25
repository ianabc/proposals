# A class for interacting with the HMC schedule optimizer

class HungarianMonteCarlo
  attr_reader :errors
  require 'socket'

  def initialize(run_params:, test_mode: false)
    @location = run_params['location']
    @year = run_params['year']
    @test_mode = test_mode
    @run_params = run_params

    @errors = {}
    @maximum_preferred_dates = 5
    @maximum_impossible_dates = 2
    @hmc_server = 'hmc'
    @hmc_port = 29000
    @hmc_access_code = ENV['HMC_ACCESS']
    validate_location
    validate_run_params
  end

  def send_data_file
    socket = hmc_connect
    socket.puts @hmc_access_code if hmc_reply(socket, 'Access code')
    socket.puts('newrun') if hmc_reply(socket, 'READY')
    socket.puts(formatted_run_params) if hmc_reply(socket, 'Run parameters')

    if hmc_reply(socket, 'Send proposals')
      File.readlines(create_data_file).each do |line|
        socket.puts line
      end

      if hmc_reply(socket, 'Launching HungarianMonteCarlo')
        update_schedule_runs(socket)
      end
    end

    socket.close
  end

  def hmc_reply(socket, prompt)
    begin
      return socket.gets.chomp.match?(prompt)
    rescue IOError => error
      @errors['HMC'] = "Error reading socket! #{error.message}"
    end
  end

  def hmc_connect
    begin
      return TCPSocket.open(@hmc_server, @hmc_port)
    rescue IOError => error
      @errors['HMC'] = "Error connecting to HMC! #{error.message}"
    end
  end

  def update_schedule_runs(socket)
    # Update the schedule_runs table with the start time and the pid number
  end

  def create_data_file
    timestamp = DateTime.current.to_i
    datafile_name = "#{Rails.root}/tmp/propfile-#{@year}-#{timestamp}.txt"
    fh = File.open(datafile_name, 'w')

    proposals = @test_mode ? testing_mode_proposals : accepted_proposals

    proposals.each do |code, params|
      fh.puts(params)
    end

    fh.close
    datafile_name
  end

  def testing_mode_proposals
    proposals = Proposal.where(year: @year).limit(program_weeks)
    # do other processing...
  end

  def accepted_proposals
    proposals = Proposal.where(assigned_location: @location)
                        .where(outcome: 'Accepted').where(year: @year)

    same_weeks = proposals.select { |p| p.same_week_as.present? }
    week_afters = proposals.select { |p| p.week_after.present? }
    half_workshops = proposals.select { |p| p.assigned_size == 'Half' }

    skip_proposals = []
    proposals.shuffle.each_with_object({}) do |proposal, data|
      next if invalid_proposal?(proposal)
      next if skip_proposals.include?(proposal)

      priority = 2
      priority = 1 if proposal.assigned_date.present?
      code = proposal.code
      preferred_dates = format_dates(proposal.preferred_dates).join(';')
      impossible_dates = format_dates(proposal.impossible_dates).join(';')

      if proposal.assigned_date.present?
        preferred_dates = format_dates([proposal.assigned_date]).first
      end

      if same_weeks.include?(proposal)
        other_proposal = proposal.same_week_as
        code << " and #{other_proposal&.code}"

        merged_dates = merge_preferred_dates(other_proposal, proposal)
        preferred_dates = format_dates(merged_dates).join(';')

        merged_dates = merge_impossible_dates(other_proposal, proposal)
        impossible_dates = format_dates(merged_dates).join(';')

        if data.key?(other_proposal&.code)
          data.delete(other_proposal&.code)
        else
          skip_proposals << other_proposal
        end
      elsif half_workshops.include?(proposal)
        # Half workshops without .same_week_as will be paired by the optimizer
        code << " (1/2 workshop)"
      end

      if week_afters.include?(proposal)
        week_after_proposal = proposal.week_after
        code = "#{week_after_proposal&.code} followed by #{proposal.code}"

        merged_dates = merge_preferred_dates(week_after_proposal, proposal)
        preferred_dates = format_dates(merged_dates).join(';')

        merged_dates = merge_impossible_dates(week_after_proposal, proposal)
        impossible_dates = format_dates(merged_dates).join(';')

        if data.key?(week_after_proposal&.code)
          data.delete(week_after_proposal&.code)
        else
          skip_proposals << week_after_proposal
        end
      end

      data[code] = "#{code}:#{priority}: #{preferred_dates}: #{impossible_dates}:"
    end
  end

  private

  def program_weeks
    include SchedulesHelper
    weeks_in_location(@location)
  end

  def validate_location
    unless @location.start_date.sunday?
      @errors['Location'] = "Location #{@location.code} start_date is not a
                             Sunday!".squish
    end

    unless @location.end_date.friday?
      @errors['Location'] << "Location #{@location.code} end_date is not a
                              Friday!".squish
    end
  end

  def validate_run_params
    required_keys = %w[run_id start_week number_of_weeks number_of_runs
                       number_of_best_cases]

    unless (required_keys - @run_params.keys).empty?
      @errors['Run parameters'] = "Run parameters must include at least these
        keys: #{required_keys.join(', ')}".squish
    end
  end

  def invalid_proposal?(proposal)
    if proposal.code.blank?
      error_message = "#{proposal.title} (id: #{proposal.id}) has no code!"
      if @errors['Proposal'].blank?
        @errors['Proposal'] = error_message
      else
        @errors['Proposal'] << "\n #{error_message}"
      end

      next
    end
  end

  def format_dates(dates)
    dates.map { |d| d.strftime("%m/%d/%Y") }
  end

  def formatted_run_params
    r = @run_params
    r['run_id'] + ' ' + r['start_week'] + ' ' + r['number_of_weeks'] + ' ' +
    r['number_of_runs'] + r['number_of_best_cases']
  end

  def merge_preferred_dates(proposal1, proposal2)
    return [proposal1.assigned_date] if proposal1.assigned_date.present?

    if proposal2.assigned_date.present?
      return [proposal2.assigned_date - 1.week] if proposal2.week_after.present?

      return [proposal2.assigned_date]
    end

    proposal1_preferred = proposal1.preferred_dates
    proposal2_preferred = proposal2.preferred_dates

    # For .week_after, both proposals will be given to the optimzer as one event,
    # "event1 followed by event2". Therefore, proposal2's preferred dates must
    # be set to a week earlier so that the schedule optimizer assigns it to
    # the actual preferred date of proposal2, the week after proposal1
    if proposal2.week_after.present?
      proposal2_preferred = proposal2.preferred_dates.map { |d| d - 1.week }
    end


    merged_dates = []

    p1count = proposal1_preferred.count
    p2count = proposal2_preferred.count

    (p1count > p2count ? p1count : p2count).times do |i|
      merged_dates << proposal1_preferred[i] if proposal1_preferred[i]
      merged_dates << proposal2_preferred[i] if proposal2_preferred[i]
    end
    merged_dates.uniq
  end

  def merge_impossible_dates(proposal1, proposal2)
    proposal2_impossible = proposal2.impossible_dates.map { |d| d - 1.week }
    (proposal1.impossible_dates + proposal2_impossible).uniq
  end
end
