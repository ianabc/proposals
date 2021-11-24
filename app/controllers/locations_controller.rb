class LocationsController < ApplicationController
  load_and_authorize_resource
  before_action :set_location, only: %i[show edit update destroy]

  def index
    @locations = Location.all
  end

  def show; end

  def new
    @location = Location.new
  end

  def edit; end

  def create
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to @location, notice: "Location was successfully created." }
        format.json { render :show, status: :created, location: @location }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to @location, notice: "Location was successfully updated." }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit, status: :unprocessable_entity, error: "Unable to update location." }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @location.destroy
    respond_to do |format|
      format.html { redirect_to locations_url, notice: "Location was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def weeks_exclude_dates
    start_date = params[:start].to_date
    end_date = params[:end].to_date - 5.days
    exclude_dates = []
    while start_date <= end_date
      week_days = start_date
      week_days += 6.days
      exclude_dates << "#{start_date} - #{week_days}"
      start_date = week_days
    end
    render json: { exclude_dates: exclude_dates }, status: :ok
  end

  private

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :code, :city, :country, :start_date, :end_date, :exclude_dates)
  end
end
