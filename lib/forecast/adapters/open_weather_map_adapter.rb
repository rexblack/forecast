class Forecast
  module Adapters
    class OpenWeatherMapAdapter
      
      include Forecast::Adapter
      
      def current(latitude, longitude)
        hash = get_json(get_action('weather', latitude, longitude))
        if hash
          result = get_forecast({latitude: latitude, longitude: longitude}.merge(hash))
          return result
        end
      end
      
      def hourly(latitude, longitude)
        json = get_json(get_action('forecast', latitude, longitude))
        result = Forecast::Collection.new
        if json && json.has_key?('list')
          json['list'].each do |hash|
            result << get_forecast({latitude: latitude, longitude: longitude}.merge(hash))
          end
        end
        return result
      end
      
      def daily(latitude, longitude)
        json = get_json(get_action('forecast/daily', latitude, longitude))
        result = Forecast::Collection.new
        if json && json.has_key?('list')
          result = Forecast::Collection.new
          json['list'].each do |hash|
            result << get_forecast({latitude: latitude, longitude: longitude}.merge(hash))
          end
        end
        return result
      end
      
      protected
      
        def get_forecast(hash = {})
          forecast = Forecast.new()
          forecast.latitude = hash[:latitude]
          forecast.longitude = hash[:longitude]
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
        
        
      private
      
        def get_action(action, latitude, longitude)
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
        
    end
  end
end