class Forecast
  module Adapters
    class WundergroundAdapter
      
      include Forecast::Adapter
      
      def current(latitude, longitude)
        forecast = nil
        result = get_json(get_action('conditions', latitude, longitude))
        if result.has_key?('current_observation')
          forecast = get_current_forecast(result['current_observation'].merge({latitude: latitude, longitude: longitude}))
        end
        return forecast
      end
      
      def hourly(latitude, longitude)
        forecasts = Forecast::Collection.new
        result = get_json(get_action('hourly', latitude, longitude))
        if result.has_key?('hourly_forecast')
          items = result['hourly_forecast']
          items.each do |hash|
            forecast = get_hourly_forecast(hash.merge({latitude: latitude, longitude: longitude}))
            forecasts << forecast
           end
        end
        return forecasts
      end
      
      def daily(latitude, longitude)
        forecasts = Forecast::Collection.new
        result = get_json(get_action('forecast', latitude, longitude))
        if result.has_key?('forecast')
          items = result['forecast']['simpleforecast']['forecastday']
          items.each do |hash|
            forecast = get_daily_forecast(hash.merge({latitude: latitude, longitude: longitude}))
            forecasts << forecast
           end
        end
        return forecasts
      end
      
      private 
        
        def get_action(action, latitude, longitude)
          url = "http://api.wunderground.com/api/#{options[:api_key]}/#{action}/q/#{latitude},#{longitude}.json"
        end
        
        def get_current_forecast(hash = {})
          puts 'forecast hash: ' + hash.to_s
          forecast = Forecast.new()
          forecast.latitude = hash[:latitude]
          forecast.longitude = hash[:longitude]
          forecast.time = get_time(hash['observation_epoch'])
          forecast.temperature = get_temperature(hash['temp_f'], :fahrenheit)
          forecast.condition = get_condition(hash['weather'])
          forecast.text = get_text(hash['weather'])
          return forecast
        end
        
        def get_hourly_forecast(hash = {})
          puts 'forecast hash: ' + hash.to_s
          forecast = Forecast.new()
          forecast.latitude = hash[:latitude]
          forecast.longitude = hash[:longitude]
          forecast.time = get_time(hash['FCTTIME']['epoch'])
          forecast.temperature = get_temperature(hash['temp']['english'], :fahrenheit)
          forecast.condition = get_condition([hash['condition']])
          forecast.text = get_text(hash['condition'])
          return forecast
        end
        
        def get_daily_forecast(hash = {})
          puts 'forecast hash: ' + hash.to_s
          forecast = Forecast.new()
          forecast.latitude = hash[:latitude]
          forecast.longitude = hash[:longitude]
          forecast.time = get_time(hash['date']['epoch'])
          forecast.temperature_min = get_temperature(hash['low']['fahrenheit'], :fahrenheit)
          forecast.temperature_max = get_temperature(hash['high']['fahrenheit'], :fahrenheit)
          forecast.temperature = get_temperature([hash['low']['fahrenheit'], hash['high']['fahrenheit']], :fahrenheit)
          forecast.condition = get_condition(hash['conditions'])
          forecast.text = get_text(hash['conditions'])
          return forecast
        end
        
      
    end
  end
end




    