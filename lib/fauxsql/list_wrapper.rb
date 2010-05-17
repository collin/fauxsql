require "active_support/core_ext/module/delegation"
module Fauxsql
  class ListWrapper < AttributeWrapper
    alias list attribute
    delegate :[], :==, :first, :last, :each, :each_with_index, :map, :all, :equals, :to => :list
    
    def <<(item)
      assert_valid_nested_class!(item.class)
      dirty! { list << item }
    end
    
    def collect_nested_errors
      with_errors = all.reject do |item|
        next unless item.is_a?(DataMapper::Resource)
        next if item.valid?
        item.errors.each{|error| record.errors.add(:general, error) }
      end
      
      not with_errors.any?
    end
    
    def get_nested_record(vals)
      record = super || vals[:type].constantize.new
      attributes = vals.dup
      [:id, :type, :_delete].map{ |key| attributes.delete key }
      record.attributes = attributes
      record.save
      record
    end
    
    def clear
      dirty! { list.clear }
    end
  end
end