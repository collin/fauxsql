require "active_support/dependencies"
require "active_support/core_ext/module/delegation"
module Fauxsql
  class ListWrapper < AttributeWrapper
    alias list attribute
    delegate :[], :==, :<<, :first, :last, :each, :each_with_index, :equals, :map_resolved, :to => :list
    
    def <<(item)
      dirty! { list << item }
    end
  end
end