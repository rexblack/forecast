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
          hash = {}
          doc.elements.each('rss/channel/item/yweather:condition') do |elem|
            elem.attributes.each() do |attr|
              hash[attr[0].to_sym] = attr[1]
            end
          end
          forecast = get_forecast(hash)
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
            hash = {}
            elem.attributes.each() do |attr|
              hash[attr[0].to_sym] = attr[1]
            end
            forecasts << get_forecast(hash)
          end
        end
        return forecasts
      end
      
      private 
      
        def get_woeid(latitude, longitude)
          woeid = nil
          query = "SELECT * FROM geo.placefinder WHERE text='#{latitude}, #{longitude}' and gflags='R'"
          url = URL_YQL + "?q=" + URI::encode(query)
          doc = get_dom(url)
          doc.elements.each('query/results/Result/woeid') do |elem|
            woeid = elem.text
          end
          return woeid
        end
        
        def get_rss(latitude, longitude)
          woeid = get_woeid(latitude, longitude)
          if woeid
            doc = Forecast::Utils.get_doc(URL_RSS, {w: woeid})
            return doc
          end
          return nil
        end
        
        def get_forecast(hash)
          forecast = Forecast.new
          forecast.time = get_time(hash[:date])
          forecast.condition = get_condition(hash[:text])
          forecast.text = get_text(hash[:text])
          forecast.temperature_min = get_temperature(hash[:low])
          forecast.temperature_max = get_temperature(hash[:high])
          forecast.temperature = get_temperature(hash.has_key?(:temp) ? hash[:temp] : [hash[:low], hash[:high]])
          return forecast
        end
        
    end
  end
end