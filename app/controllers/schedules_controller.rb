class SchedulesController < ApplicationController
  def new; end

  def form
    @location = Location.find_by(id: params[:location])
  end
end
