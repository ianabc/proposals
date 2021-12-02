class SchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_location, only: %w[new_schedule_run]

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

  def authorize_user
    authorize! params[:action], SchedulesController
  end
end
