class Forecast
  module Adapters
    class OpenWeatherMapAdapter
      
      include Forecast::Adapter
      
      def current(latitude, longitude)
        forecast = nil
        result = Forecast::Utils.get_json(url('weather', latitude, longitude))
        if result
          forecast = get_forecast(result.merge({latitude: latitude, longitude: longitude}))
        end
        return forecast
      end
      
      def hourly(latitude, longitude)
        forecasts = Forecast::Collection.new
        result = Forecast::Utils.get_json(url('forecast', latitude, longitude))
        if result
          result['list'].each do |item|
            forecast = get_forecast(item.merge({latitude: latitude, longitude: longitude}))
            forecasts << forecast
          end
        end
        return forecasts
      end
      
      def daily(latitude, longitude)
        forecasts = Forecast::Collection.new
        result = Forecast::Utils.get_json(url('forecast/daily', latitude, longitude))
        if result
          result['list'].each do |item|
            forecast = get_forecast(item.merge({latitude: latitude, longitude: longitude}))
            forecasts << forecast
          end
        end
        return forecasts
      end
      
      private
      
        def url(action, latitude, longitude)
          url = "http://api.openweathermap.org/data/2.5/#{action}"
          params = {
            lat: latitude, 
            lon: longitude 
          }
          if options[:api_key]
            params['APPID'] = options[:api_key]
          end
          query_string = URI.encode_www_form(params)
          return url + "?" + query_string
        end
        
        def get_forecast(hash)
          forecast = Forecast.new(hash)
          forecast.time = get_time(hash['dt'])
          forecast.temperature = get_temperature(hash.has_key?('main') ? hash['main']['temp'] : hash['temp']['day'], :kelvin)
          forecast.temperature_min = get_temperature(hash.has_key?('main') ? hash['main']['temp_min'] : hash['temp']['min'], :kelvin)
          forecast.temperature_max = get_temperature(hash.has_key?('main') ? hash['main']['temp_max'] : hash['temp']['max'], :kelvin)
          forecast.temperature = ((forecast.temperature_min + forecast.temperature_max) / 2).round
          hash['weather'].each do |obj|
            condition = get_condition([obj['description'], obj['main']])
            if condition != nil
              forecast.text = get_text(obj['description'])
              forecast.condition = condition
              break
            end
          end
          return forecast
        end
      
    end
  end
end




    