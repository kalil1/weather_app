class ForecastsController < ApplicationController
  before_action :set_forecast, only: %i[show edit update destroy]

  def index
    sql = if params[:search].present?
      ["SELECT * FROM forecasts WHERE zip_code = $1 ORDER BY created_at DESC", [params[:search]]]
    else
      ["SELECT * FROM forecasts ORDER BY created_at DESC", []]
    end
  
    result = ActiveRecord::Base.connection.exec_query(*sql)
    @forecasts = result.map { |row| Forecast.new(row).tap(&:readonly!) }
  end

  def show; end

  def new
    @forecast = Forecast.new
  end

  def create
  zip = params[:forecast][:zip_code]

  result = ActiveRecord::Base.connection.exec_query(
    "SELECT * FROM forecasts WHERE zip_code = $1 ORDER BY created_at DESC LIMIT 1",
    "SQL",
    [[nil, zip]]
  ).first

  if result && Time.parse(result['created_at'].to_s) > 30.minutes.ago
    @forecast = Forecast.new(result).tap(&:readonly!)
    unless @forecast.cached
      ActiveRecord::Base.connection.exec_update(
        "UPDATE forecasts SET cached = TRUE WHERE id = $1",
        "SQL",
        [[nil, @forecast.id]]
      )
      @forecast.cached = true
    end
  else
    data = WeatherFetcher.new(zip).fetch
    unless data
      flash.now[:alert] = 'Could not fetch weather data.'
      return render :index, status: :unprocessable_entity
    end

    existing = ActiveRecord::Base.connection.exec_query(
      "SELECT id FROM forecasts WHERE zip_code = $1 LIMIT 1",
      "SQL",
      [[nil, data[:zip_code]]]
    ).first

    if existing
      ActiveRecord::Base.connection.exec_update(
        "UPDATE forecasts SET temperature = $1, high = $2, low = $3, description = $4, raw_data = $5, cached = $6, created_at = $7, updated_at = $8 WHERE id = $9",
        "SQL",
        [
          [nil, data[:temperature]],
          [nil, data[:high]],
          [nil, data[:low]],
          [nil, data[:description]],
          [nil, data[:raw_data]],
          [nil, data[:cached]],
          [nil, data[:fetched_at]],
          [nil, Time.current],
          [nil, existing['id']]
        ]
      )
      @forecast = Forecast.find(existing['id']) # fallback to AR here to keep it clean
    else
      ActiveRecord::Base.connection.exec_insert(
        "INSERT INTO forecasts (zip_code, temperature, high, low, description, raw_data, cached, created_at, updated_at) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)",
        "SQL",
        [
          [nil, data[:zip_code]],
          [nil, data[:temperature]],
          [nil, data[:high]],
          [nil, data[:low]],
          [nil, data[:description]],
          [nil, data[:raw_data]],
          [nil, data[:cached]],
          [nil, data[:fetched_at]],
          [nil, Time.current]
        ]
      )
      @forecast = Forecast.order(created_at: :desc).find_by(zip_code: data[:zip_code])
    end
  end

  respond_to do |format|
    format.turbo_stream
    format.html { redirect_to forecasts_path, notice: "Forecast loaded#{@forecast.cached ? ' (from cache)' : ''}." }
  end
end
  
def destroy
  ActiveRecord::Base.connection.exec_delete(
    "DELETE FROM forecasts WHERE id = $1",
    "SQL",
    [[nil, params[:id]]]
  )
  redirect_to forecasts_url, notice: 'Forecast was successfully destroyed.'
end

  private

  def set_forecast
    result = ActiveRecord::Base.connection.exec_query(
      "SELECT * FROM forecasts WHERE id = $1",
      "SQL",
      [[nil, params[:id]]]
    ).first
  
    @forecast = Forecast.new(result).tap(&:readonly!) if result
  end
  
  def forecast_params
    params.require(:forecast).permit(:zip_code)
  end
end
