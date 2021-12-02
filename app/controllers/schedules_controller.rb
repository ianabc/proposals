class SchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_location, only: %w[new_schedule_run]

  def new; end

  def new_schedule_run; end

  def run_hmc_program
    schedule_run = ScheduleRun.new(run_params)
    if schedule_run.save
      HungarianMonteCarlo.new(schedule_run: schedule_run).run_optimizer
    else
      redirect_to new_schedule_run_schedules_path(location: params[:location_id]),
                  alert: schedule_run.errors.full_messages
    end
  end

  private

  def run_params
    params.permit(:weeks, :runs, :cases, :location_id, :year, :test_mode)
  end

  def set_location
    @location = Location.find_by(id: params[:location])
  end

  def authorize_user
    authorize! params[:action], SchedulesController
  end
end
