class Forecast
  module Adapters
    class ForecastIoAdapter
      
      include Forecast::Adapter
      
      def current(latitude, longitude)
        result = Forecast::Utils.get_json(url(latitude, longitude))
        get_forecast(result['currently']) unless nil
      end
      
      def hourly(latitude, longitude)
        result = Forecast::Utils.get_json(url(latitude, longitude))
        forecasts = Forecast::Collection.new
        result['hourly']['data'].each do |item|
          forecasts << get_forecast(item)
        end
        return forecasts
      end
      
      def daily(latitude, longitude)
        result = Forecast::Utils.get_json(url(latitude, longitude))
        forecasts = Forecast::Collection.new
        result['daily']['data'].each do |item|
          forecasts << get_forecast(item)
        end
        return forecasts
      end
      
      private
      
        def url(latitude, longitude)
          return "https://api.forecast.io/forecast/#{options[:api_key]}/#{latitude},#{longitude}"
        end
        
        def get_forecast(hash)
          forecast = Forecast.new(hash)
          forecast.time = get_time(hash['time'])
          forecast.condition = get_condition(hash['summary'])
          forecast.text = get_text(hash['summary'])
          forecast.temperature_min = get_temperature(hash['temperatureMin'])
          forecast.temperature_max = get_temperature(hash['temperatureMax'])
          forecast.temperature = get_temperature(hash.has_key?('temperature') ? hash['temperature'] : [hash['temperatureMin'], hash['temperatureMax']])
          return forecast
        end
      
    end
  end
end




    