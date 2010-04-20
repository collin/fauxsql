require "active_support/dependencies"
require "active_support/core_ext/module/delegation"
module Fauxsql
  class MapWrapper < AttributeWrapper
    alias map attribute
    delegate :[], :each, :keys, :resolve_key, :resolve_value, :to => :map
    
    def []=(key, value)
      dirty! { map[key] = value }
    end
  end
end