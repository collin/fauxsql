module Fauxsql
  class AttributeWrapper
    class MissingOptions < ArgumentError
      def initialize(missing, options)
        super "Missing option :#{missing} in #{options.inspect}"
      end
    end
    class InvalidNesting < StandardError
      def initialize(klass, klasses)
        super "Invalid nested class #{klass}. Should be one of #{klasses.inspect}"
      end
    end
    
    extend ActiveSupport::Concern
    attr_reader:attribute
    attr_reader:record
    attr_reader:name
    attr_reader:options
    
    def initialize(attribute, record, name, options)
      raise MissingOptions if options.nil?
      @attribute, @record, @name, @options = attribute, record, name, options
      @record.fauxsql_attributes[name] ||= attribute
    end

    def get_nested_record(vals)
      model = vals[:type].constantize
      raise MissingOptions.new(:nest, options) unless options[:nest]
      raise InvalidNesting.new(model, options[:nest]) unless valid_nested_class?(model)
      model.get(vals[:id])
    end

    def valid_nested_class?(model)
      return true if options[:nest].empty?
      options[:nest].detect{|klass| model == klass or model < klass }
    end

    def dirty!
      Fauxsql.dirty!(record){ yield }
    end
  end
end