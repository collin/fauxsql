require "active_support/core_ext/module/delegation"
require 'active_support/core_ext/array/extract_options'
module Fauxsql
  class ManymanyWrapper < AttributeWrapper
    class InvalidManymanyAssociationClass < StandardError
      def initialize(klass, through)
        super "#{klass} does not have a corresponding manymany attribute named #{through}."
      end
    end
    
    alias list attribute
    delegate :-, :[], :==, :first, :last, :each, :each_with_index, :map, :all, :equals, :to => :list
    
    def initialize(attribute, record, name, options)
      super(attribute, record, name, options)
      raise MissingOptions.new(:through, options) unless options[:through]
      raise MissingOptions.new(:nest, options) unless options[:nest].any?
      @through = options[:through]
      options[:nest].each do |klass|
        raise InvalidManymanyAssociationClass.new(klass, @through) unless klass.has_fauxsql_attribute?(@through, :manymany)
      end
    end
    
    def collect_nested_errors
      true
    end
    
    def <<(other)
      assert_valid_nested_class!(other.class)
      other.send(@through).clean_push(record)
      clean_push(other)
    end
        
    def delete(*others)
      clean_subtract(others)
      others.each{ |other| other.send(@through).clean_subtract([record]) }
      # # DataMapper.transaction do # TODO the transaction?
        others.each{|other| other.save}
        record.save
      # end
    end
    
  protected
    def clean_push(other)
      dirty! { list << other }
    end
    
    def clean_subtract(others)
      dirty! { @attribute = list - others }
    end
  end
end