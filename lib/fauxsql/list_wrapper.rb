require "active_support/dependencies"
require "active_support/core_ext/module/delegation"
module Fauxsql
  class ListWrapper < AttributeWrapper
    alias list attribute
    delegate :[], :==, :<<, :first, :last, :each, :each_with_index, :map, :all, :equals, :to => :list
    
    def <<(item)
      dirty! { list << item }
    end
    
    def clear
      dirty! { list.clear }
    end
  end
end