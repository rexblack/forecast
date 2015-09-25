require 'net/http'
require 'rexml/document'
require 'open-uri'
require 'json'

require 'forecast/http.rb'

class Forecast
  module Adapter
    
    attr_reader :options
    
    module ClassMethods
    end
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    def self.instance
      options = {}
      provider = Forecast.config.provider
      if provider.is_a?(String) || provider.is_a?(Symbol)
        adapter_name = provider.to_sym
      elsif provider.is_a?(Hash)
        adapter_name = provider[:adapter].to_s
        options = provider.clone
        options.delete('adapter')
      end
      if adapter_name
        if Forecast.config.adapters != nil && Forecast.config.adapters.has_key?(adapter_name)
          options = options.merge(Forecast.config.adapters[adapter_name])
        end
        adapter_classname = (adapter_name.to_s << "_adapter").split('_').collect!{ |w| w.capitalize }.join
        adapter_class = Object.const_get('Forecast').const_get("Adapters").const_get(adapter_classname)
        adapter_class.new(options)
      else 
        puts 'Adapter not found'
      end
    end
    
    def initialize(options = {})
      @options = ({cache: Forecast.config.cache}).merge(options)
      @http = Http.new({cache: @options[:cache]})
    end
    
    def current(latitude, longitude)
    end
    
    def hourly(latitude, longitude)
    end
    
    def daily(latitude, longitude)
    end
    
    protected
    
      def options
        @options
      end
    
      def get_json(url)
        @http.get_json(url)
      end
      
      def get_dom(url)
        @http.get_dom(url)
      end
      
      def get_temperature(value, input = :fahrenheit )
        if value == nil
          value = 0
        elsif value.is_a?(Array)
          value = value.inject{ |sum, v| sum.to_f + get_temperature(v) }.to_f / value.size
        elsif value.is_a?(String) || value.is_a?(Numeric)
          value = value.to_f
          if input == :fahrenheit && Forecast.config.scale.to_sym == :kelvin
            value = Forecast::Utils.fahrenheit_to_kelvin(value)
          elsif input == :fahrenheit && Forecast.config.scale.to_sym == :celsius
            value = Forecast::Utils.fahrenheit_to_celsius(value)
          elsif input == :kelvin && Forecast.config.scale.to_sym == :fahrenheit
            value = Forecast::Utils.kelvin_to_fahrenheit(value)
          elsif input == :kelvin && Forecast.config.scale.to_sym == :celsius
            value = Forecast::Utils.kelvin_to_celsius(value)
          elsif input == :celsius && Forecast.config.scale.to_sym == :fahrenheit
            value = Forecast::Utils.celsius_to_fahrenheit(value)
          elsif input == :celsius && Forecast.config.scale.to_sym == :kelvin
            value = Forecast::Utils.celsius_to_kelvin(value)
          end
        end
        value.round
      end
      
      def get_time(value)
        if value.is_a?(Time) || value.is_a?(Date)
          value.to_datetime
        elsif value.is_a?(String) && value =~ /\A\d+\Z/ || value.is_a?(Numeric)
          Time.at(value.to_i).to_datetime
        elsif value.is_a?(String)
          DateTime.parse(value.to_s)
        elsif value.is_a?(DateTime)
          value
        end
      end
      
      def get_text(value)
        value.capitalize
      end
      
      def get_condition_synonyms(name)
        result = []
        synonyms = Forecast.config.synonyms
        synonym_values = synonyms.flatten.select { |v|
          Forecast::Utils.word_similarity(name, v) > 0.6
        }
        if synonym_values.size > 0
          c = synonym_values.sort { |a, b| 
            as = Forecast::Utils.word_similarity(name, a)
            bs = Forecast::Utils.word_similarity(name, b)
            as <=> bs
          }.reverse
          match = c.first
          result = synonyms.select do |v|
           v.include?(match)
          end.first
        end
        return result
      end
      
      
      def get_similar_condition(name)
        conditions = Forecast.config.conditions
        condition_synonyms = {}
        conditions.each do |k, v|
          condition_synonyms[v] = get_condition_synonyms(v) - [v]
        end
        condition_synonym_similarity = {}
        conditions.each do |k, v|
          synonyms = [v] + get_condition_synonyms(v)
          condition_synonym_similarity[v] = get_condition_synonyms(v) - [v]
          similarity = 0
          synonyms.each do |synonym|
            similarity = [similarity, Forecast::Utils.word_similarity(name, synonym)].max
          end
          condition_synonym_similarity[v] = similarity
        end
        c = conditions.values.select { |condition|
          condition_synonym_similarity[condition] > 0.1
        }
        c = c.sort { |a, b|
          a_similarity = condition_synonym_similarity[a]
          b_similarity = condition_synonym_similarity[b]
          a_similarity <=> b_similarity
        }.reverse
        if c.first != nil
          return {
            condition: c.first,
            similarity: condition_synonym_similarity[c.first] || 0
          }
        end
      end
      
      def get_condition_name(match)
        if match == nil 
          return nil
        end
        conditions = Forecast.config.conditions
        condition = nil
        if conditions.keys.include?(match)
          condition = conditions[match]
        elsif conditions.values.include?(match)
          condition = match
        end
        return condition
      end
      
      def get_condition(api_conditions)
        if !api_conditions.is_a?(Array)
          api_conditions = [api_conditions]
        end
        condition = nil
        if api_conditions.length > 0
          similar_conditions = api_conditions.map { |api_condition|
            get_similar_condition(api_condition)
          }.select {|v|
            v != nil  
          }
          similar_condition = similar_conditions.sort { |a,b|
            a[:similarity] <=> b[:similarity]
          }.reverse.first
          if similar_condition
            condition = similar_condition[:condition]
            condition_name = get_condition_name(condition)
            if condition_name == nil
              condition_name = api_conditions[0]
            end
          end
          if condition_name != nil
            return condition_name
          end
        end
        return "Unknown"
      end
      
      
  end
end