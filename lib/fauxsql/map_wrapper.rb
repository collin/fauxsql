require "active_support/core_ext/module/delegation"
module Fauxsql
  class MapWrapper < AttributeWrapper
    alias map attribute
    delegate :[], :each, :clear, :each_with_index, :size, :keys, :resolve_key, :resolve_value, :to => :map
    
    def []=(key, value)
      assert_valid_nested_class!(key.class)
      value = value.send(options[:value_type]) if options[:value_type]
      dirty! { map[key] = value }
    end
    
    def [](key)
      options[:value_type] ? map[key].send(options[:value_type]) : map[key]
    end
    
    def collect_nested_errors
      true # Not yet creating/saving full objects in mappings.
    end

    def reset!
      dirty! do
        old = map.dup
        map.clear
        old.each do |key, value|
          map[key] = value
        end
      end
    end
        
    def delete(key)
      dirty! { map.delete(key) }
    end
  end
end