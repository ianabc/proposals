# A class for saving schedule data posted from HMC

class HmcResultsSave
  attr_reader :errors

  def initialize(schedule_params)
    @run_id = schedule_params['schedule_run_id']
    @run_data = schedule_params['run_data']
    @errors = ''
  end

  def missing_assignments(case_data)
    unless case_data.key?("assignments")
      @errors << "Missing assignments!"
      return true
    end

    if case_data["assignments"].blank?
      @errors << "Empty week assignments!"
      return true
    end

    unless case_data["assignments"].respond_to?(:flatten)
      @errors << "Unexpected assignment data structure"
      return true
    end

    false
  end

  def save
    @run_data.each do |case_data|
      save_schedule(case_data) unless @errors.present?
    end

    if @errors.empty?
      ScheduleRun.find_by(id: @run_id).update(end_time: DateTime.current)
    end
  end

  def save_schedule(case_data)
    return if missing_assignments(case_data)

    case_data["assignments"].flatten.each do |assignment|
      schedule = Schedule.new(schedule_run_id: @run_id,
                              case_num: case_data["case_num"],
                              hmc_score: case_data["hmc_score"],
                              week: assignment["week"],
                              proposal: assignment["proposal"])
      schedule.save
      @errors << schedule.errors.full_messages.join(', ')
    end
  end
end
