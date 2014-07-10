require "json"
require "redis"
class Forecast
  
  class Cache
    
    attr_accessor :host, :port, :url, :password, :expire, :namespace, :model, :collection
    
    def initialize(object_attribute_hash = {})
      options = {
        host: "127.0.0.1", 
        port: "6379", 
        expire: 10, 
        namespace: "", 
        model: Forecast, # must respond to to_json and from_json
        collection: Forecast::Collection
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
      puts "WRITE TO CACHE... " + qkey.to_s
      redis.set(qkey, data.to_json)
      redis.expire(qkey, expire)
    end
  
    def read(key)
      qkey = qualified_key(key)
      puts "READ FROM CACHE: " + qkey.to_s
      cached_result = redis.get(qkey)
      result = nil
      if cached_result != nil
        json = JSON.parse(cached_result)
        if json.is_a?(Array)
          result = collection.new
          json.each do |hash|
            object = model.new
            object.from_json(hash)
            result << object
          end
        elsif json.is_a?(Object)
          result = model.new
          result.from_json(json)
        end
      end
      return result
    end
    
      
    private
    
      def qualified_key(key)
        if namespace != nil && namespace.length > 0
          "#{namespace}:#{key}"
        else
          "#{key}"
        end
      end
    
      def connect
        puts "connect: " + host.to_s + ", " + port.to_s
        redis = nil
        if url != nil
          uri = URI.parse(url)
          puts "connecting to redis with url #{url}..."
          redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
        elsif host != nil && port != nil
          puts "connecting to redis on host #{host} at port #{port}..."
          redis = Redis.new(host: host, port: port)
        end
        return redis
      end

  end
end