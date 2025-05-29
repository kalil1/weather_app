require 'rails_helper'

RSpec.describe ForecastsController, type: :controller do
  let(:valid_zip) { '33032' }
  let(:forecast_data) do
    {
      zip_code: valid_zip,
      temperature: '75.0',
      high: '80.0',
      low: '70.0',
      description: 'clear sky',
      raw_data: '{}',
      fetched_at: Time.current,
      cached: false
    }
  end

  describe 'POST #create' do
    context 'when forecast does not exist' do
      it 'creates a new forecast' do
        allow_any_instance_of(WeatherFetcher).to receive(:fetch).and_return(forecast_data)

        post :create, params: { forecast: { zip_code: valid_zip } }

        expect(Forecast.where(zip_code: valid_zip).count).to eq(1)
        expect(response).to redirect_to(forecasts_path)
      end
    end

    context 'when forecast exists and is recent' do
      it 'uses the existing forecast and marks it cached' do
        forecast = Forecast.create!(forecast_data.merge(created_at: 10.minutes.ago))

        expect {
          post :create, params: { forecast: { zip_code: valid_zip } }
        }.not_to change(Forecast, :count)

        expect(assigns(:forecast)).to eq(forecast)
        expect(assigns(:forecast).cached).to be(true)
        expect(response).to redirect_to(forecasts_path)
      end
    end

    context 'when forecast fetch fails' do
      it 'renders index with error' do
        allow_any_instance_of(WeatherFetcher).to receive(:fetch).and_return(nil)

        post :create, params: { forecast: { zip_code: valid_zip } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to match(/Could not fetch weather data/)
      end
    end
  end
end
