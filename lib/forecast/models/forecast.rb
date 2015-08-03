class Forecast
  module Model
    
    def initialize(object_attribute_hash = {})
      object_attribute_hash.map do |(k, v)| 
        send("#{k}=", v) if respond_to?("#{k}=")
      end
    end
    
    def self.included(base)
      base.extend(ClassMethods)
    end
  
    def as_json options = {}
      serialized = Hash.new
      if self.class.attributes != nil
        self.class.attributes.each do |attribute|
          serialized[attribute] = self.public_send attribute
        end
      end
      serialized
    end
  
    def to_json *a
      as_json.to_json a
    end
    
    def from_json(json)
      self.class.attributes.each do |attribute|
        writer_m = "#{attribute}="
        value = json[attribute.to_s]
        if attribute == :date
          value = DateTime.parse(value)
        end
        send(writer_m, value) if respond_to?(writer_m)
      end
    end
    
    # end
    
      
      module ClassMethods
        
        @attributes = []
        
        def attributes
          @attributes
        end
        
        def attr_accessor *attrs
          @attributes = Array attrs
          super
        end
        
      end
    
  end
end