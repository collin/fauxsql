require "active_support/core_ext/module/delegation"
module Fauxsql
  class MapWrapper < AttributeWrapper
    alias map attribute
    delegate :[], :each, :each_with_index, :keys, :resolve_key, :resolve_value, :to => :map
    
    def []=(key, value)
      value = value.send(options[:value_type]) if options[:value_type]
      dirty! { map[key] = value }
    end
    
    def [](key)
      options[:value_type] ? map[key].send(options[:value_type]) : map[key]
    end
    
    def delete(key)
      dirty! { map.delete(key) }
    end
  end
end