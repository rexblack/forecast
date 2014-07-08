require 'net/http'
require 'rexml/document'
require 'open-uri'
require 'json'

class Forecast
  module Adapter
    
    @options = nil
    
    module ClassMethods
      def slug
        self.name.split('::').last.gsub(/Adapter$/, '').gsub(/(.)([A-Z])/,'\1_\2').downcase
      end
    end
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    def self.instance
      provider = Forecast.config.provider
      if provider.is_a?(Hash)
        adapter_name = provider['adapter'].to_s
        options = provider.clone
        options.delete('adapter')
      else
        adapter_name = provider
        options = {}
      end
      if adapter_name
        adapter_classname = (adapter_name.to_s << "_adapter").split('_').collect!{ |w| w.capitalize }.join
        adapter_class = Object.const_get('Forecast').const_get("Adapters").const_get(adapter_classname)
        adapter_class.new(options)
      else 
        puts 'no adapter provided'
      end
    end
    
    def initialize(options = {})
      @options = options
    end
    
    def options
      @options
    end
    
    def config
      Forecast.config.adapters[self.class.slug] || {}
    end
    
    protected
    
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
      
      def metric(fahrenheit)
        ((fahrenheit - 32) / 1.800).round()
      end
      
      def get_temp(fahrenheit)
        fahrenheit = fahrenheit.to_i.round()
        Forecast.config.temp_scale.to_sym == :metric ? metric(fahrenheit) : fahrenheit
      end
      
      def similar_words(first, second)
        similar_words = 0.0
        first_words = first.downcase.split(/\s+/)
        second_words = second.downcase.split(/\s+/)
        first_words.each do |first_word|
          second_words.each do |second_word|
            similar = 0.0
            if first_word == second_word
              similar = 1.0
            else
              l1 = levenshtein(first_word, second_word)
              if l1 > 0 && l1 < 3
                similar = 1.0
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
      
      def get_condition_by_similarity(name)
        conditions = Forecast.config.conditions
          c = conditions.values.sort { |a, b| similar_words(name, a) <=> similar_words(name, b) }.reverse
          if c.first && similar_words(name, c.first) > 0
            return c.first
          end
      end
      
      def get_condition_name(match)
        if match == nil 
          return nil
        end
        conditions = Forecast.config.conditions
        condition = "Unknown"
        if conditions.keys.include?(match)
          condition = conditions[match]
        elsif conditions.values.include?(match)
          condition = match
        end
        return condition
      end
      
      def match_adapter_condition(api_condition)
        match = nil
        conditions = config['conditions']
        if conditions != nil
          conditions.each do |key, value|
            # puts "match key #{api_condition} -> #{key.to_s}, #{value.to_s}"
            if is_numeric?(api_condition) && key.is_a?(String)
              if key.include? ".."
                range = key.split(/\.{2}/)
                if api_condition.to_i >= range[0].to_i && api_condition.to_i <= range[1].to_i
                  match = value
                end
              end
            elsif key.to_s == api_condition.to_s
              match = value;
            end
          end
        end
        return match
      end
      
      def get_condition(api_conditions)
        if !api_conditions.is_a?(Array)
          api_conditions = [api_conditions]
        end
        condition = nil
        api_conditions.each do |api_condition|
          match = match_adapter_condition(api_condition)
          if condition == nil
            condition = get_condition_by_similarity(api_condition)
          end
          if condition
            break
          end
        end
        get_condition_name(condition)
      end
      
      private 
      
        def is_numeric?(s)
          begin
            Float(s)
          rescue
            false # not numeric
          else
            true # numeric
          end
        end
      
  end
end