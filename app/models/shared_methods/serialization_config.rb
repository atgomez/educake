module SharedMethods
  module SerializationConfig
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:extend, ClassMethods)
    end
    
    module InstanceMethods
      # Override Rails as_json method
      def as_json(options={})
        if (!options.blank?)
          super(self.default_serializable_options.merge(options))
        else
          super(self.default_serializable_options)
        end
      end
      
      def exposed_methods
        self.class.exposed_methods
      end
        
      def exposed_attributes
        self.class.exposed_attributes
      end
      
      def exposed_associations
        self.class.exposed_associations
      end
      
      def except_attributes
        self.class.except_attributes
      end
      
      def default_serializable_options
        self.class.default_serializable_options
      end
      
      def to_hash
        self.serializable_hash(self.default_serializable_options)
      end
    end # End InstanceMethods.
    
    module ClassMethods
      def exposed_methods
        []
      end
      
      def exposed_attributes
        []
      end
      
      def exposed_associations
        []
      end
      
      def except_attributes
        attrs = []
        self.attribute_names.each do |n|
          if !exposed_attributes.include?(n.to_sym)
            attrs << n
          end
        end
        attrs
      end
      
      def default_serializable_options
        { :except => self.except_attributes,
          :methods => self.exposed_methods, 
          :include => self.exposed_associations
        }
      end
      
    end # End ClassMethods.
  
  end # End SerializationConfig.
  
end # SharedMethods.
