require 'ostruct'
require "forecast/version"
require "forecast/config"
require "forecast/utils"
require "forecast/collection"
require "forecast/adapter"
require "forecast/adapters/yahoo_adapter"
require "forecast/adapters/open_weather_map_adapter"
require "forecast/adapters/wunderground_adapter"
require "forecast/adapters/forecast_io_adapter"
require "forecast/cache"

class Forecast
  
  PROVIDERS = Dir.glob(File.expand_path(File.dirname(__FILE__) + '/forecast/adapters/*.*')).map{ |f| File.basename(f, '_adapter.rb') };
  
  def method_missing(method, *args, &block)
    @source.send(method, *args, &block)
  end
  
  def initialize(attrs = {})
    @source = OpenStruct.new
    hash = Forecast::Utils.underscore(attrs)
    hash.each do |k, v|
      @source.send("#{k}=", v)
    end
  end
  
  def to_json *a
    to_h.to_json a
  end
  
  def icon
    # Pick icon from theme
    if self.condition != nil && Forecast.config.theme.is_a?(Hash)
      icon_prefix = Forecast.config.theme.has_key?('prefix') ? Forecast.config.theme['prefix'] : ''
      icon_suffix = Forecast.config.theme.has_key?('suffix') ? Forecast.config.theme['suffix'] : ''
      icon_name = Forecast.config.theme['conditions'].has_key?(self.condition) ? Forecast.config.theme['conditions'][self.condition] : self.condition
      # Dasherize
      icon_name = icon_name.to_s.gsub(/(.)([A-Z])/,'\1-\2').gsub(/\s*/, '').downcase
      icon = icon_prefix + icon_name + icon_suffix
      return icon != nil ? icon : self.icon
    end
    # Slugified condition as icon name
    self.condition.is_a?(String) && self.condition.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  end
  
  # class
  class << self
  
    def current(latitude, longitude)
      result = nil
      if cache != nil
        result = cache.read("current:#{latitude},#{longitude}")
        if result != nil
          puts 'get from cache'
        end
      end
      if result == nil && adapter.respond_to?(:current)
        result = adapter.current(latitude, longitude)
        cache.write("current:#{latitude},#{longitude}", result)
      end
      return result
    end
    
    def hourly(latitude, longitude)
      result = nil
      if cache != nil
        result = cache.read("hourly:#{latitude},#{longitude}")
        if result != nil
          puts 'get from cache'
        end
      end
      if result == nil && adapter.respond_to?(:hourly)
        result = adapter.hourly(latitude, longitude)
        cache.write("hourly:#{latitude},#{longitude}", result)
      end
      return result
    end
    
    def daily(latitude, longitude)
      result = nil
      if cache != nil
        result = cache.read("daily:#{latitude},#{longitude}")
        if result != nil
          puts 'get from cache'
        end
      end
      if result == nil && adapter.respond_to?(:daily)
        result = adapter.daily(latitude, longitude)
        cache.write("daily:#{latitude},#{longitude}", result)
      end
      return result
    end
    
    
    private
    
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
    
      def adapter
        if @adapter == nil
          @adapter = Forecast::Adapter.instance
        end
        return @adapter
      end
    
  end
  
end
