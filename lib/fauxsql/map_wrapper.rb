require "active_support/core_ext/module/delegation"
module Fauxsql
  class MapWrapper < AttributeWrapper
    alias map attribute
    delegate :[], :each, :each_with_index, :keys, :resolve_key, :resolve_value, :to => :map
    
    def []=(key, value)
      dirty! { map[key] = value }
    end
    
    def delete(key)
      dirty! { map.delete(key) }
    end
  end
end