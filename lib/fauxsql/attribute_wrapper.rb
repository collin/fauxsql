module Fauxsql
  class AttributeWrapper
    class MissingOptions < ArgumentError
      def initialize(missing, options)
        super "Missing option :#{missing} in #{options.inspect}"
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
      raise InvalidNesting unless options[:nest].include?(model)
      model.get(vals["#{model.name}_id".to_sym])
    end

    def dirty!
      Fauxsql.dirty!(record){ yield }
    end
  end
end