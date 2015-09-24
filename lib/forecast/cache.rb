require "json"
require "redis"
class Forecast
  
  class Cache
    
    attr_accessor :host, :port, :url, :password, :expire, :name, :invalidate
    
    def initialize(object_attribute_hash = {})
      options = {
        invalidate: false,
        host: "127.0.0.1", 
        port: "6379", 
        expire: 10, 
        name: ""
      }.merge!(object_attribute_hash)
      options.map do |(k, v)| 
        send("#{k}=", v) if respond_to?("#{k}=")
      end
    end
    
    def redis
      @redis||=connect()
    end
    
    def write(key, data)
      qkey = qualified_key(key)
      redis.set(qkey, data.to_json)
      redis.expire(qkey, expire)
    end
  
    def read(key)
      if !invalidate
        qkey = qualified_key(key)
        cached_result = redis.get(qkey)
        result = nil
        if cached_result != nil
          json = JSON.parse(cached_result)
          if json.is_a?(Array)
            result = Forecast::Collection.new
            json.each do |hash|
              result << get_forecast(hash)
            end
          elsif json.is_a?(Object)
            result = get_forecast(json)
          end
        end
        return result
      end
    end
      
    private
    
      def qualified_key(key)
        if name != nil && name.length > 0
          "Forecast:#{Forecast::VERSION}:#{name}:#{key}"
        else
          "#{key}"
        end
      end
      
      def get_forecast(hash)
        if hash.has_key?('time')
          hash['time'] = DateTime.parse(hash['time'])
        end
        Forecast.new(hash)
      end
    
      def connect
        redis = nil
        if url != nil
          uri = URI.parse(url)
          #puts "Connecting to redis with url #{url}..."
          redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
        elsif host != nil && port != nil
          #puts "Connecting to redis on host #{host} at port #{port}..."
          redis = Redis.new(host: host, port: port)
        end
        return redis
      end

  end
end