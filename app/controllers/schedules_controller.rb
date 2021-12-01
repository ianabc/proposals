class SchedulesController < ApplicationController
  def new; end

  def form
    @location = Location.find_by(id: params[:location])
  end

  def run_hmc_program
    schedule_run = ScheduleRun.new(run_params)
    if schedule_run.save
      HungarianMonteCarlo.new(schedule_run: schedule_run).run_optimizer
    else
      redirect_to form_schedules_path(location: params[:location_id]), alert: schedule_run.errors.full_messages
    end
  end

  private

  def run_params
    params.permit(:weeks, :runs, :cases, :location_id, :year, :test_mode)
  end
end
