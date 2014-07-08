class Forecast
  class Config
      
    attr_accessor :adapters, :provider, :temp_scale, :conditions, :cache, :themes, :theme
    
    def initialize
      
      # puts 'init config: ' + File.dirname(__FILE__) + '*.rb'
      
      #@provider = :open_weather_map
      
      #@conditions = {}
      
      #@provider = :open_weather_map
      # @provider = :yahoo
      # @provider = {
        # adapter: :wunderground, 
        # api_key: "bb502261bc5a7dfd"
      # }
      
      #@temp_scale = :metric
      
      # @cache = {
        # expire: 10, 
        # prefix: 'forecast'
      # }
      
      # @cache = false
#       
      # @theme = :weather_icons
      
      config = {}
      Dir.glob(File.dirname(__FILE__) + '/**/*.yml').sort{ |a, b| a.split(/\//).length <=> b.split(/\//).length}.reverse.each do |f|
        obj = YAML.load_file(f)
        if obj['forecast'] != nil
          config.merge!(obj['forecast'])
        end
      end
      
      config.each do |k, v|
        # puts 'init config: ' + k + " -> " + v.to_s
        send("#{k}=", v) if respond_to?("#{k}=")
      end
      
      def theme
        if @theme && themes[@theme]
          return themes[@theme]
        end
        return @theme
      end
      
    end
    
    
  end
  
  def self.config
    @@config ||= Config.new
  end
  
  def self.configure
    yield self.config
  end
end