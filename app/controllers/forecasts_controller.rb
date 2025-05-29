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
    result = WeatherFetcher.new(params[:forecast][:zip_code]).fetch
  
    if result
      @forecast = Forecast.new(
        zip_code: result[:zip_code],
        temperature: result[:temperature],
        description: result[:description],
        created_at: result[:fetched_at],
        cached: result[:cached]
      )
  
      if @forecast.save
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to forecasts_path, notice: "Forecast successfully fetched#{result[:cached] ? ' (from cache)' : ''}." }
        end
      else
        flash.now[:alert] = 'Error saving forecast.'
        render :new
      end
    else
      flash.now[:alert] = 'Could not fetch weather data.'
      @forecast = Forecast.new(zip_code: params[:forecast][:zip_code])
      render :new
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
