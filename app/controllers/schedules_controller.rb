class SchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_location, only: %w[new_schedule_run]
  before_action :set_schedule_run, only: %w[abort_run optimized_schedule]

  def new; end

  def new_schedule_run; end

  def run_hmc_program
    schedule_run = ScheduleRun.new(run_params)
    if schedule_run.save
      hmc_program(schedule_run)
    else
      render json: { errors: schedule_run.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def abort_run
    # TODO: abort_run method pending
  end

  def optimized_schedule
    @case_num = if params[:page].to_i > @schedule_run.cases
                  @schedule_run.cases
                else
                  params[:page] >= "1" ? params[:page] : 1
                end
    @schedules = Schedule.where(schedule_run_id: @schedule_run.id, case_num: @case_num)
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
      HmcJob.new(hmc).perform(schedule_run)
      head :accepted
    end
  end

  def set_schedule_run
    @schedule_run = ScheduleRun.find_by(id: params[:run_id])
  end

  def set_location
    @location = Location.find_by(id: params[:location])
  end

  def authorize_user
    authorize! params[:action], SchedulesController
  end
end
