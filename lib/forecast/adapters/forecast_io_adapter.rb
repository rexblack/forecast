class Forecast
  module Adapters
    class ForecastIoAdapter
      
      include Forecast::Adapter
      
      def current(latitude, longitude)
        result = get_json(get_action(latitude, longitude))
        get_forecast({latitude: latitude, longitude: longitude}.merge(result['currently'])) unless nil
      end
      
      def hourly(latitude, longitude)
        result = get_json(get_action(latitude, longitude))
        forecasts = Forecast::Collection.new
        result['hourly']['data'].each do |hash|
          forecasts << get_forecast({latitude: latitude, longitude: longitude}.merge(hash))
        end
        return forecasts
      end
      
      def daily(latitude, longitude)
        result = get_json(get_action(latitude, longitude))
        forecasts = Forecast::Collection.new
        result['daily']['data'].each do |hash|
          forecasts << get_forecast({latitude: latitude, longitude: longitude}.merge(hash))
        end
        return forecasts
      end
      
      private
      
        def get_action(latitude, longitude)
          api_key = options[:api_key]
          return "https://api.forecast.io/forecast/#{api_key}/#{latitude},#{longitude}"
        end
        
        def get_forecast(hash)
          forecast = Forecast.new(hash)
          forecast.latitude = hash[:latitude]
          forecast.longitude = hash[:longitude]
          forecast.time = get_time(hash['time'])
          forecast.condition = get_condition(hash['summary'])
          forecast.text = get_text(hash['summary'])
          forecast.temperature_min = get_temperature(hash['temperatureMin'], :fahrenheit)
          forecast.temperature_max = get_temperature(hash['temperatureMax'], :fahrenheit)
          forecast.temperature = get_temperature(hash.has_key?('temperature') ? hash['temperature'] : [hash['temperatureMin'], hash['temperatureMax']], :fahrenheit)
          return forecast
        end
      
    end
  end
end




    