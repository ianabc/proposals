class ScheduleRunsController < ApplicationController
  def destroy
    @schedule_run = ScheduleRun.find_by(id: params[:id])
    if @schedule_run.destroy
      flash[:notice] = t('.success')
    else
      flash[:alert] = @schedule_run.errors.full_messages.joins(', ')
    end
    redirect_to new_schedule_path
  end
end
