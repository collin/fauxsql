module Fauxsql
  class AttributeWrapper
    extend ActiveSupport::Concern
    attr_reader:attribute
    attr_reader:record
    attr_reader:name
    attr_reader:options
    
    def initialize(attribute, record, name, options={})
      @attribute, @record, @name, @options = attribute, record, name, options
      @record.fauxsql_attributes[name] ||= attribute
    end

    def dirty!
      Fauxsql.dirty!(record){ yield }
    end
  end
end