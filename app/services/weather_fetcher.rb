class WeatherFetcher
    include HTTParty
    base_uri 'https://api.openweathermap.org/data/2.5'
  
    def initialize(zip_code)
      @zip_code = zip_code
      @api_key = ENV['OPENWEATHER_API_KEY']
    end
  
    def fetch
        cached = true
        result = Rails.cache.fetch("forecast:#{@zip_code}", expires_in: 30.minutes) do
          cached = false
          response = self.class.get("/weather", query: {
            zip: "#{@zip_code},us",
            appid: @api_key,
            units: 'imperial'
          })
      
          return nil unless response.success?
      
          {
            zip_code: @zip_code,
            temperature: response['main']['temp'].to_s,
            high: response['main']['temp_max'].to_s,
            low: response['main']['temp_min'].to_s,
            description: response['weather'][0]['description'],
            raw_data: response.to_json,
            fetched_at: Time.current,
            cached: false
          }
        end
      
        result.merge(cached: cached)
      rescue
        nil
      end      
  end
  