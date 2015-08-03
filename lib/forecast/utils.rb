require 'net/http'
require 'rexml/document'
require 'open-uri'
require 'json'

class Forecast
  module Utils
    class << self
      
      
      def underscore(string)
        if string.is_a?(String)
          return string.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
        elsif string.is_a?(Hash)
          return Hash[string.map { |k, v| [Forecast::Utils.underscore(k.to_s).to_sym, v.is_a?(Hash) ? Forecast::Utils.underscore(v) : v] }]
        else
          string
        end
      end
      
      def fahrenheit_to_kelvin(fahrenheit)
        ((fahrenheit - 32) / 1.8) - 273.15
      end
      
      def fahrenheit_to_celsius(fahrenheit)
        ((fahrenheit - 32) / 1.8)
      end
      
      def kelvin_to_fahrenheit(kelvin)
        return ((kelvin - 273.15) * 1.8 + 32)
      end
      
      def kelvin_to_celsius(kelvin)
        kelvin - 273.15
      end
      
      def celsius_to_fahrenheit(celsius)
        celsius * 1.8 + 32 
      end
      
      def celsius_to_kelvin(celsius)
        celsius + 273.15
      end
      
      def get_json(url, params = {})
        if params.keys.count > 0
          query_string = URI.encode_www_form(params)
          url = url + "?" + query_string
        end
        resp = Net::HTTP.get_response(URI.parse(url))
        data = resp.body
        result = JSON.parse(data)
        if result && result['cod'] != "404"
          return result
        end
        return nil
      end
      
      def get_doc(url, params = {})
        if params.keys.count > 0
          query_string = URI.encode_www_form(params)
          url = url + "?" + query_string
        end
        xml_data = Net::HTTP.get_response(URI.parse(url)).body
        doc = REXML::Document.new(xml_data)
        return doc
      end
      
      def word_similarity(first, second)
        
        if !first.is_a?(String) || !second.is_a?(String)
          return 0
        end
        similar_words = 0.0
        first_words = first.downcase.split(/\W+/)
        second_words = second.downcase.split(/\W+/)
        
        first_words.each do |first_word|
          second_words.each do |second_word|
            similar = 0.0
            if first_word == second_word
              similar = 1.0
            else
              l1 = levenshtein(first_word, second_word)
              l = 1 - (l1.to_f / ([first_word.length, second_word.length].max))
              l = [0, similar].max
              l = [similar, 1].min
              if l1 > 0.6
                similar = 0.1
              end
            end
            similar_words+= similar
          end
        end
        count = first_words.concat(second_words).uniq.length
        similarity = similar_words / count
        return similarity
      end
      
      def levenshtein(first, second)
        matrix = [(0..first.length).to_a]
        (1..second.length).each do |j|
          matrix << [j] + [0] * (first.length)
        end
        (1..second.length).each do |i|
          (1..first.length).each do |j|
            if first[j-1] == second[i-1]
              matrix[i][j] = matrix[i-1][j-1]
            else
              matrix[i][j] = [
                matrix[i-1][j],
                matrix[i][j-1],
                matrix[i-1][j-1],
              ].min + 1
            end
          end
        end
        return matrix.last.last
      end
      
    end
  end
end