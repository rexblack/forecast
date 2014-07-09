class Forecast
  class Config
      
    attr_accessor :adapters, :provider, :temp_scale, :conditions, :cache, :themes, :theme
    
    def initialize
      
      @config_file = nil 
      #File.dirname(File.dirname(File.dirname(__FILE__))) + "/config/forecast.yml"
      
      self.load(File.dirname(__FILE__) + '/**/*.yml')
      
      def theme
        if @theme != nil 
          if @theme.is_a?(Hash)
            return @theme
          end
          if themes[@theme] != nil
            return themes[@theme]
          end
        end
        return @theme
      end
      
    end
    
    def load(pattern)
      Dir.glob(pattern).sort{ |a, b| a.split(/\//).length <=> b.split(/\//).length}.reverse.each do |f|
        obj = YAML.load_file(f)
        puts 'load forecast config ' + f.to_s
        if obj['forecast'] != nil
          obj['forecast'].each do |k, v|
            if respond_to?("#{k}")
              o = send("#{k}")
              if o.is_a?(Hash)
                v = deep_merge(o, v)
              end
            end
            send("#{k}=", v) if respond_to?("#{k}=")
          end
        end
      end
    end
    
    private 
      
      def deep_merge(hash, other_hash, &block)
        other_hash.each_pair do |k,v|
          tv = hash[k]
          if tv.is_a?(Hash) && v.is_a?(Hash)
            hash[k] = deep_merge(tv, v, &block)
          else
            hash[k] = block && tv ? block.call(k, tv, v) : v
          end
        end
        hash
      end
    
  end
  
  def self.config
    @@config ||= Config.new
  end
  
  def self.configure
    yield self.config
    # puts 'configured'
    if self.config.config_file != nil
      puts '**** load config from file'
      self.config.load(self.config.config_file)
    end
  end
  
  
end