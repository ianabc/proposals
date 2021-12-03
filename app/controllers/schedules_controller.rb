class SchedulesController < ApplicationController
  before_action :authenticate_user!, except: %i[create]
  before_action :authorize_user, except: %i[create]
  before_action :set_location, only: %w[new_schedule_run]
  skip_before_action :verify_authenticity_token, only: %i[create]
  before_action :parse_request, :authenticate_api_key, :schedules_data, only: %i[create]

  def new; end

  def create; end

  def new_schedule_run; end

  def run_hmc_program
    schedule_run = ScheduleRun.new(run_params)
    if schedule_run.save
      hmc_program(schedule_run)
    else
      render json: { errors: schedule_run.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def run_params
    params.permit(:weeks, :runs, :cases, :location_id, :year, :test_mode)
  end

  def hmc_program(schedule_run)
    hmc = HungarianMonteCarlo.new(schedule_run: schedule_run)
    if hmc.errors
      render json: { errors: hmc.errors }, status: :unprocessable_entity
    else
      HmcJob.new(hmc).perform
      head :accepted
    end
  end

  def set_location
    @location = Location.find_by(id: params[:location])
  end

  def parse_request
    @json_data = JSON.parse(request.body.read)
  rescue JSON::ParserError
    head :bad_request
  end

  def authenticate_api_key
    return if ENV['SCHEDULE_API_KEY'] == @json_data["SCHEDULE_API_KEY"]

    unauthorized
  end

  def schedules_data
    run_data = @json_data["run_data"]
    run_data.each do |run|
      schedules_assignments(run)
    end
  end

  def schedules_assignments(run)
    run["assignments"].flatten.each do |assignment|
      schedule = Schedule.new(schedule_run_id: run["schedule_run_id"], case_num: run["case_num"],
                              hmc_score: run["hmc_score"], week: assignment["week"],
                              proposal: assignment["proposal"])
      schedule.save
    end
  end

  def unauthorized
    head :unauthorized
  end

  def authorize_user
    authorize! params[:action], SchedulesController
  end
end
