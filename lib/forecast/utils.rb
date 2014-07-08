require 'net/http'
require 'rexml/document'
require 'open-uri'
require 'json'

class Forecast
  module Utils
    class << self
      
      def get_json(url, params)
        query_string = URI.encode_www_form(params)
        url = url + "?" + query_string
        resp = Net::HTTP.get_response(URI.parse(url))
        data = resp.body
        result = JSON.parse(data)
        if result && result['cod'] != "404"
          return result
        end
        return nil
      end
      
      def get_doc(url, params)
        query_string = URI.encode_www_form(params)
        url = url + "?" + query_string
        xml_data = Net::HTTP.get_response(URI.parse(url)).body
        doc = REXML::Document.new(xml_data)
        return doc
      end
      
    end
  end
end