require 'net/http'
require 'rexml/document'
require 'open-uri'
require 'json'
require "redis"

class Forecast
  
  class Http
    
    def initialize(options = {})
      @options = {cache: nil}.merge options
      if @options[:cache]
        cache_options = @options[:cache].merge({
          host: "127.0.0.1", 
          port: "6379"
        })
        if cache_options.has_key?(:url)
          url = cache_options[:url]
          uri = URI.parse(url)
          #puts "Connecting to redis with url #{url}..."
          @cache = Redis.new(host: uri.host, port: uri.port, password: uri.password)
        elsif host != nil && port != nil
          #puts "Connecting to redis on host #{host} at port #{port}..."
          @cache = Redis.new(host: cache_options[:host], port: cache_options[:port])
        end
      end
    end
    
    def get(url, params = {})
      if @cache && (!@options[:cache].has_key?(:invalidate) || !@options[:cache][:invalidate])
        data = @cache.get(url)
        if data
          #puts 'Read from cache... ' + url
          return data
        end
      end
      if params.keys.count > 0
        query_string = URI.encode_www_form(params)
        url = url + "?" + query_string
      end
      #puts 'Get url... ' + url
      resp = Net::HTTP.get_response(URI.parse(url))
      data = resp.body
      if data
        if @cache
          #puts 'Write to cache... ' + url
          @cache.set(url, data)
          if @options[:cache] && @options[:cache].has_key?(:expire)
            @cache.expire(url, @options[:cache][:expire])
          end
        end
        return data
      end
    end
    
    def get_json(url, params = {})
      data = get(url, params)
      if data != nil
        return JSON.parse(data)
      end
    end
    
    def get_dom(url, params = {})
      data = get(url, params)
      if data != nil
        return REXML::Document.new(data)
      end
    end
    
  end
end