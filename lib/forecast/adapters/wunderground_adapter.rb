class Forecast
  module Adapters
    class WundergroundAdapter
      
      include Forecast::Adapter
      
      def current(latitude, longitude)
        forecast = nil
        result = get_json(api_url('conditions', latitude, longitude))
        if result
          item = result['current_observation']
          forecast = Forecast.new(latitude: latitude, longitude: longitude)
          forecast.date = Time.rfc822(item['observation_time_rfc822'])
          forecast.temp = get_temp(item['temp_f'])
          forecast.condition = get_condition([item['weather']])
          forecast.orig_condition = item['weather']
        end
        return forecast
      end
      
      def hourly(latitude, longitude)
        forecasts = Forecast::Collection.new
        result = get_json(api_url('hourly', latitude, longitude))
        if result
          items = result['hourly_forecast']
          items.each do |item|
            forecast = Forecast.new(latitude: latitude, longitude:longitude)
            forecast.date = Time.at(item['FCTTIME']['epoch'].to_i).to_datetime
            forecast.temp = get_temp(item['temp']['english'])
            forecast.condition = get_condition([item['condition']])
            forecast.orig_condition = item['condition']
            forecasts << forecast
           end
        end
        return forecasts
      end
      
      def daily(latitude, longitude)
        forecasts = Forecast::Collection.new
        result = get_json(api_url('forecast', latitude, longitude))
        if result
          items = result['forecast']['simpleforecast']['forecastday']
          items.each do |item|
            forecast = Forecast.new(latitude: latitude, longitude:longitude)
            forecast.date = Time.at(item['date']['epoch'].to_i).to_datetime
            forecast.temp_min = get_temp(item['low']['fahrenheit'])
            forecast.temp_max = get_temp(item['high']['fahrenheit'])
            forecast.temp = (forecast.temp_min + forecast.temp_max) / 2
            forecast.condition = get_condition([item['conditions']])
            forecast.orig_condition = item['conditions']
            forecasts << forecast
           end
        end
        return forecasts
      end
      
      private 
          
        def api_url(action, latitude, longitude)
          url = "http://api.wunderground.com/api/#{options['api_key']}/#{action}/q/#{latitude},#{longitude}.json"
        end
      
    end
  end
end




    