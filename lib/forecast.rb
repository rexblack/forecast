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
require "forecast/http"

class Forecast
  
  PROVIDERS = Dir.glob(File.expand_path(File.dirname(__FILE__) + '/forecast/adapters/*.*')).map{ |f| File.basename(f, '_adapter.rb') };
  
  def method_missing(method, *args, &block)
    @source.send(method, *args, &block)
  end
  
  def initialize(attrs = {})
    @source = OpenStruct.new(attrs)
  end
  
  def as_json(options = nil)
    @source.table.as_json(options)
  end
  
  def to_json *a
    self.marshal_dump.to_json a
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
      return adapter.current(latitude, longitude)
    end
    
    def hourly(latitude, longitude)
      return adapter.hourly(latitude, longitude)
    end
    
    def daily(latitude, longitude)
      return adapter.daily(latitude, longitude)
    end
    
    private
    
      def adapter
        if @adapter == nil
          @adapter = Forecast::Adapter.instance
        end
        return @adapter
      end
    
  end
  
end
