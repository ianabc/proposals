# A class for saving schedule data posted from HMC

class HmcResultsSave
  attr_reader :errors

  def initialize(schedule_params)
    @run_id = schedule_params['schedule_run_id']
    @run_data = schedule_params['run_data']
    @errors = ''
  end

  def missing_assignments
    @errors << "Empty week assignments!" if @run_data["assignments"].blank?
    unless @run_data["assignments"].respond_to(:flatten)
      @errors << "Unexpected assignment data structure"
    end
  end

  def save
    return if missing_assignments

    @run_data["assignments"].flatten.each do |assignment|
      save_schedule(assignment) if @errors.empty?
    end

    @errors.empty?
  end

  def save_schedule(assignment)
    schedule = Schedule.new(schedule_run_id: @run_id,
                            case_num: @run_data["case_num"],
                            hmc_score: @run_data["hmc_score"],
                            week: assignment["week"],
                            proposal: assignment["proposal"])
    return if schedule.save

    @errors << schedule.errors.full_messages
  end
end
