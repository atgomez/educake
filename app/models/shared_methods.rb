# This module contains shared methods that can be included or used across models
module SharedMethods
  module Paging
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:extend, ClassMethods)
    end
    
    module InstanceMethods
    
    end 
    
    module ClassMethods
      def paging_options(options, default_opts = {})
        info = PagingInfo.new
        
        options ||= {}
        options.to_options!
        
        if default_opts.blank?
          default_opts = {
            :sort_criteria => {:id => "DESC"},
            :page_id => 1
          }
        end
        
        page_id = default_opts[:page_id]

        if options[:page_id] && options[:page_id].to_i > 0
          info.page_id = options[:page_id]
        end

        if options[:page_size] && options[:page_size].to_i > 0
          info.page_size = options[:page_size]
        end
        
        if options[:sort_field]
          sort_field = options[:sort_field]
          sort_direction = options[:sort_direction] || "ASC"
          info.sort_string = "#{sort_field} #{sort_direction}"
          info.sort_criteria = {sort_field => sort_direction}
        else
          if default_opts[:sort_criteria].is_a?(String)
            info.sort_string = default_opts[:sort_criteria]
            info.sort_criteria = parse_sort_param(info.sort_string)
          elsif default_opts[:sort_criteria].is_a?(Hash)
            info.sort_string = sort_param_to_string(default_opts[:sort_criteria])
            info.sort_criteria = default_opts[:sort_criteria]
          else
            raise ArgumentError.new("Invalid options[:sort_criteria]. It should be a string or a hash.")
          end
        end

        return info
      end
      
      # Parse the input string with the format "sort_field1 sort_direction1, sort_field2 sort_direction2, ..." to a hash.
      def parse_sort_param(sort_param = "")
        params = sort_param.split(",")
        if params.blank?
          params = [sort_param]
        end
        result = {}
        params.each do |p|
          p.strip! # get the string "sort_field1 sort_direction1"
          criteria = p.split(" ")
          if criteria.blank?
            criteria = [p]
          end
          if criteria.length == 1
            result[criteria[0]] = "ASC" # default sort direction
          elsif criteria.length == 2
            result[criteria[0]] = criteria[1]
          end
        end
        return result
      end
      
      # Parse the input hash with the format {:sort_field1 => "sort_direction1", :sort_field2 => "sort_direction2""", ...} to a string.
      # This is the inverse method of parse_sort_param() method.
      def sort_param_to_string(sort_param = {})
        sort_param.collect{|k,v| "#{k} #{v}"}.join(",")
      end
      
    end # End ClassMethods.
  
  end # End Paging.
  
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
        self.class.except_attributes
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
  
end # End SharedMethods.
