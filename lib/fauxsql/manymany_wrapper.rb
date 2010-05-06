require "active_support/core_ext/module/delegation"
require 'active_support/core_ext/array/extract_options'
module Fauxsql
  class ManymanyWrapper < AttributeWrapper
    class ThroughOptionMissing < StandardError; end
    class InvalidManymanyAssociationClass < StandardError; end
    
    alias list attribute
    delegate :-, :[], :==, :first, :last, :each, :each_with_index, :map, :all, :equals, :to => :list
    
    def initialize(attribute, record, name, *classes)
      super(attribute, record, name, {})
      options = classes.extract_options!
      raise ThroughOptionMissing unless options[:through]
      @classes, @through = classes, options[:through]
    end
    
    def <<(other)
      raise InvalidManymanyAssociationClass unless @classes.include?(other.class)
      other.send(@through).clean_push(record)
      clean_push(other)
    end
    
    def delete(*others)
      raise InvalidManymanyAssociationClass if (@classes - others.map{|other| other.class }).any?
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