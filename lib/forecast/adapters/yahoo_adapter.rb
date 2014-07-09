class Forecast
  module Adapters
    class YahooAdapter
      
      include Forecast::Adapter
      
      URL_YQL = 'http://query.yahooapis.com/v1/public/yql'
      URL_RSS = 'http://weather.yahooapis.com/forecastrss'
      
      def current(latitude, longitude)
        forecast = nil
        doc = get_rss(latitude, longitude)
        if doc
          forecast = Forecast.new
          doc.elements.each('rss/channel/item/yweather:condition') do |elem|
            elem.attributes.each() do |attr|
              name = attr[0]
              value = attr[1]
              case name
                when 'date'
                  forecast.date = DateTime.parse(value)
                when 'temp'
                  forecast.temp = value.to_i
                when 'text'
                  forecast.condition = get_condition(value)
              end
            end
          end
        end
        return forecast
      end
      
      def hourly(latitude, longitude)
        # not supported
        return []
      end
      
      def daily(latitude, longitude)
        doc = get_rss(latitude, longitude)
        forecasts = Forecast::Collection.new
        if doc
          doc.elements.each('rss/channel/item/yweather:forecast') do |elem|
            forecast = Forecast.new
            elem.attributes.each() do |attr|
              puts 'attr' + attr.to_s
              name = attr[0]
              value = attr[1]
              case name
                when 'date'
                  forecast.date = DateTime.parse(value)
                when 'low'
                  forecast.temp_min = get_temp(value)
                when 'high'
                  forecast.temp_max = get_temp(value)
                when 'text'
                  forecast.condition = get_condition(value)
              end
            end
            forecast.temp = (forecast.temp_min + forecast.temp_max) / 2
            forecasts << forecast
          end
        end
        return forecasts
      end
      
      private 
      
        def get_woeid(latitude, longitude)
          woeid = nil
          query = "SELECT * FROM geo.placefinder WHERE text='#{latitude}, #{longitude}' and gflags='R'"
          url = URL_YQL + "?q=" + URI::encode(query)
          doc = get_doc(url)
          doc.elements.each('query/results/Result/woeid') do |elem|
            woeid = elem.text
          end
          return woeid
        end
        
        def get_rss(latitude, longitude)
          woeid = get_woeid(latitude, longitude)
          if woeid
            doc = get_doc(URL_RSS, {w: woeid})
            return doc
          end
          return nil
        end
        
    end
  end
end