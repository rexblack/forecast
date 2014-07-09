require "forecast/version"
require "forecast/config"
require "forecast/model"
require "forecast/collection"
require "forecast/adapter"
require "forecast/adapters/yahoo_adapter"
require "forecast/adapters/open_weather_map_adapter"
require "forecast/adapters/wunderground_adapter"
require "yaml"
require "redis"

class Forecast
  
  # instance
  
  include Forecast::Model
  
  attr_accessor :latitude, :longitude, :date, :temp, :temp_min, :temp_max, :condition, :orig_condition
  
  # class
  class << self
  
    def current(latitude, longitude)
      cache_key = "current:#{latitude},#{longitude}"
      forecast = read_cache(cache_key)
      if forecast == nil
        forecast = adapter.current(latitude, longitude)
        write_cache(cache_key, forecast)
      end
      return forecast
    end
    
    def hourly(latitude, longitude)
      cache_key = "hourly:#{latitude},#{longitude}"
      forecasts = read_cache(cache_key)
      if forecasts == nil
        forecasts = adapter.hourly(latitude, longitude)
        write_cache(cache_key, forecasts)
      end
      return forecasts
    end
    
    def daily(latitude, longitude)
      cache_key = "daily:#{latitude},#{longitude}"
      forecasts = read_cache(cache_key)
      if forecasts == nil
        forecasts = adapter.daily(latitude, longitude)
        write_cache(cache_key, forecasts)
      end
      return forecasts
    end
    
    private 

      @adapter = nil
      
      def adapter
        if @adapter == nil
          @adapter = Forecast::Adapter.instance
        end
        return @adapter
      end
      
          
      @cache = nil
      
      def cache
        cache = Forecast.config.cache
        if @cache == nil && ( cache != nil || (!!cache == cache) && cache == true )
          if !!cache == cache
            Forecast.config.cache = {
              expire: 5, 
              prefix: :forecast, 
              host: "127.0.0.1", 
              port: "6379", 
              url: nil
            }
          end
          cache_config = Forecast.config.cache
          begin
            if cache_config['url'] != nil
              redis_url = cache_config['url']
              uri = URI.parse(redis_url)
              @cache = Redis.new(host: uri.host, port: uri.port, password: uri.password)
            else
              @cache = Redis.new(host: cache_config['host'], port: cache_config['port'])
            end
            @cache.ping
          rescue
            puts "error connecting to redis"
          end
        end
        return @cache
      end
      
      def cache_key(key)
        cache_prefix = Forecast.config.cache[:prefix]
        return "#{cache_prefix.to_s}:#{key}"
      end
      
      def cache_expire
        cache_expire = Forecast.config.cache[:expire]
      end
    
      def write_cache(key, data)
        if cache == nil
          return;
        end
        puts "WRITE TO CACHE... " + cache_key(key).to_s + ", cache_expire: " + cache_expire.to_s
        cache.set(cache_key(key), data.to_json)
        cache.expire(cache_key(key), cache_expire)
      end
    
      def read_cache(key)
        if cache == nil
          return nil;
        end
        cached_result = cache.get(cache_key(key))
        result = nil
        if cached_result != nil
          puts "READ FROM CACHE: " + cache_key(key).to_s + ", cache_expire: " + cache_expire.to_s
          json = JSON.parse(cached_result)
          if json.is_a?(Array)
            result = Forecast::Collection.new
            json.each do |obj|
              forecast = Forecast.new
              forecast.from_json(obj)
              result << forecast
            end
          elsif json.is_a?(Object)
            result = Forecast.new
            result.from_json(json)
          end
        end
        return result
      end
    
      
    
  end
  
end
