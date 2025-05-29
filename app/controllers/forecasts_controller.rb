class ForecastsController < ApplicationController
  before_action :set_forecast, only: %i[show edit update destroy]

  def index
    if params[:search].present?
      @forecasts = Forecast.where(zip_code: params[:search]).order(created_at: :desc)
    else
      @forecasts = Forecast.all.order(created_at: :desc)
    end
  end

  def show; end

  def new
    @forecast = Forecast.new
  end

  def create
    zip = params[:forecast][:zip_code]
    existing_forecast = Forecast.where(zip_code: zip).order(created_at: :desc).first
  
    if existing_forecast && existing_forecast.created_at > 30.minutes.ago
      @forecast = existing_forecast
      @forecast.update(cached: true) unless @forecast.cached?
    else
      result = WeatherFetcher.new(zip).fetch
  
      if result
        @forecast = Forecast.new(result)
        @forecast.save
      else
        flash.now[:alert] = 'Could not fetch weather data.'
        return render :index, status: :unprocessable_entity
      end
    end
  
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to forecasts_path, notice: "Forecast loaded#{@forecast.cached? ? ' (from cache)' : ''}." }
    end
  end
  
  def destroy
    @forecast.destroy
    redirect_to forecasts_url, notice: 'Forecast was successfully destroyed.'
  end

  private

  def set_forecast
    @forecast = Forecast.find(params[:id])
  end

  def forecast_params
    params.require(:forecast).permit(:zip_code)
  end
end
