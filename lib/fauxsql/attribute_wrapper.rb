module Fauxsql
  class AttributeWrapper
    class MissingOptions < ArgumentError
      def initialize(missing, options)
        super "Missing option :#{missing} in #{options.inspect}"
      end
    end
    class InvalidNesting < StandardError
      def initialize(record, name, type, klass, klasses)
        super "Invalid nested class #{klass} on #{record.class}'s fauxsql #{type} :#{name}. Should be one of #{klasses.inspect}"
      end
    end
    
    extend ActiveSupport::Concern
    attr_reader:attribute
    attr_reader:record
    attr_reader:name
    attr_reader:options
    
    def initialize(attribute, record, name, options)
      @attribute, @record, @name, @options = attribute, record, name, options
      @record.fauxsql_attributes[name] ||= attribute
    end

    def collect_nested_errors
      raise "Unimplemented method Fauxsql::AttributeWrapper#collect_nested_errors. Implement it in subclass #{self.class}"
    end

    def get_nested_record(vals)
      # todo: raise specific error when :id and :type are nil
      model = vals[:type].constantize
      assert_valid_nested_class!(model)
      model.get(vals[:id])
    end

    def assert_valid_nested_class!(model)
      return true if options[:nest].empty?
      return true if options[:nest].detect{|klass| model == klass or model < klass }
      raise InvalidNesting.new(record, name, options[:attribute_type], model, options[:nest])
    end

    def reset!
      raise "Unimplemented method Fauxsql::AttributeWrapper#reset! Implement it in subclass #{self.class}"      
    end
    
    def dirty!
      Fauxsql.dirty!(record){ yield }
    end
  end
end