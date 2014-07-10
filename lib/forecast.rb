require "forecast/version"
require "forecast/config"
require "forecast/model"
require "forecast/collection"
require "forecast/adapter"
require "forecast/adapters/yahoo_adapter"
require "forecast/adapters/open_weather_map_adapter"
require "forecast/adapters/wunderground_adapter"
require "forecast/cache"

class Forecast
  
  # instance
  
  include Forecast::Model
  
  attr_accessor :latitude, :longitude, :date, :temp, :temp_min, :temp_max, :condition, :orig_condition
  
  def icon
    if Forecast.config.theme.is_a? Hash
      icon = Forecast.config.theme[self.condition]
      return icon unless icon == nil 
    end
    return slugify(self.condition)
  end
  
  private 

    def slugify(string)
      string.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end
  
  # class
  class << self
  
    def current(latitude, longitude)
      result = nil
      puts 'SELF: ' + self.adapter.to_s
      if self.cache != nil
        result = self.cache.read("current:#{latitude},#{longitude}")
      end
      if result == nil
        result = adapter.current(latitude, longitude)
        if self.cache != nil
          self.cache.write("current:#{latitude},#{longitude}", result)
        end
      end
      return result
    end
    
    def hourly(latitude, longitude)
      result = nil
      if cache != nil
        result = cache.read("hourly:#{latitude},#{longitude}")
      end
      if result == nil
        puts 'forecast api call'
        result = adapter.hourly(latitude, longitude)
        if cache != nil
          cache.write("hourly:#{latitude},#{longitude}", result)
        end
      end
      return result
    end
    
    def daily(latitude, longitude)
      result = nil
      if cache != nil
        result = cache.read("daily:#{latitude},#{longitude}")
      end
      if result == nil
        result = adapter.daily(latitude, longitude)
        if cache != nil
          cache.write("daily:#{latitude},#{longitude}", result)
        end
      end
      return result
    end
#     
# 
    # @adapter = nil
    # @cache = nil
    
    def adapter
      if @adapter == nil
        @adapter = Forecast::Adapter.instance
      end
      return @adapter
    end
    
    def cache
      cache_config = Forecast.config.cache
      if @cache == nil && (!!cache_config == cache_config && cache_config == true || cache_config.is_a?(Hash))
        if !!cache_config == cache_config
          @cache = Forecast::Cache.new
        else
          @cache = Forecast::Cache.new(cache_config)
        end
      end
      return @cache
    end
    
  end
  
end
