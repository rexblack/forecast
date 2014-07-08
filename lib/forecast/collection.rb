class Forecast
  class Collection < Array
    def select_date(date)
      result = nil
      date_forecasts = self.select do |obj|
        obj.date.to_date == date.to_date
      end
      if date_forecasts.length == 0
        return nil
      else
        hour_forecasts = date_forecasts.select do |obj|
          obj.date.hour == obj.date.hour
        end
        if hour_forecasts.length > 0
          return hour_forecasts.first
        end
        return date_forecasts.first
      end
      return nil
      
    end
    
    private 
      def seconds_between(date1, date2)
        ((Time.parse(date1.to_s) - Time.parse(date2.to_s)) / 3600).abs
      end
  end
end