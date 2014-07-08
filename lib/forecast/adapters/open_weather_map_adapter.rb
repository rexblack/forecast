class Forecast
  module Adapters
    class OpenWeatherMapAdapter
      
      include Forecast::Adapter
      
      def current(latitude, longitude)
        forecast = nil
        result = get_json(api_url('weather', latitude, longitude))
        if result
          forecast = Forecast.new(latitude: latitude, longitude: longitude)
          forecast.date = Time.at(result['dt']).to_datetime
          forecast.temp = get_temp(kelvin_to_fahrenheit(result['main']['temp'])) 
          result['weather'].each do |obj|
            condition = get_condition(obj['description'])
            if condition != nil
              forecast.condition = condition
              break
            end 
          end
        end
        return forecast
      end
      
      def hourly(latitude, longitude)
        forecasts = Forecast::Collection.new
        result = get_json(api_url('forecast', latitude, longitude))
        if result
          result['list'].each do |item|
            forecast = Forecast.new(latitude: latitude, longitude:longitude)
            forecast.date = Time.at(item['dt']).to_datetime
            forecast.temp = get_temp(kelvin_to_fahrenheit(item['main']['temp']))
            item['weather'].each do |obj|
              condition = get_condition([obj['description'], obj['id']])
              if condition != nil
                forecast.condition = condition
                break
              end 
            end
            # forecast.temp_min = item['main']['temp_min']
            # forecast.temp_max = item['main']['temp_max']
            forecasts << forecast
          end
        end
        return forecasts
      end
      
      def daily(latitude, longitude)
        forecasts = Forecast::Collection.new
        result = get_json(api_url('forecast/daily', latitude, longitude))
        result['list'].each do |item|
          forecast = Forecast.new(latitude: latitude, longitude:longitude)
          forecast.date = Time.at(item['dt'])
          forecast.temp_min = get_temp(kelvin_to_fahrenheit(item['temp']['min']))
          forecast.temp_max = get_temp(kelvin_to_fahrenheit(item['temp']['max']))
          forecast.temp = (forecast.temp_min + forecast.temp_max) / 2
          item['weather'].each do |obj|
            condition = get_condition(obj['description'])
            if condition != nil
              forecast.condition = condition
              break
            end 
          end
          forecasts << forecast
        end
        return forecasts
      end
      
      private
      
        def api_url(action, latitude, longitude)
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
        
        def kelvin_to_fahrenheit(kelvin)
          return ((kelvin - 273.15) * 1.8000 + 32).round
        end
      
    end
  end
end




    