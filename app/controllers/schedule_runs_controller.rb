class ScheduleRunsController < ApplicationController
  def destroy
    @schedule_run = ScheduleRun.find(params[:id])
    @schedule_run.destroy
    flash[:notice] = "Schedule result is deleted successfully"
    redirect_to new_schedule_path
  end
end
