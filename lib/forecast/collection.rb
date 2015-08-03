class Forecast
  class Collection < Array
    def select_time(time)
      result = nil
      date_forecasts = self.select do |obj|
        obj.time.to_date == time.to_date
      end
      if date_forecasts.length == 0
        return nil
      else
        hour_forecasts = date_forecasts.select do |obj|
          obj.time.hour == obj.time.hour
        end
        if hour_forecasts.length > 0
          return hour_forecasts.first
        end
        return date_forecasts.first
      end
      return nil
    end
    
    private 
      # Unused
      def seconds_between(date1, date2)
        ((Time.parse(date1.to_s) - Time.parse(date2.to_s)) / 3600).abs
      end
  end
end