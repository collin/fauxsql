require "active_support/inflector"
module Fauxsql
  module DSL
    # DSL method to define a named Fauxsql attribute
    #
    # See all those get_fauxsql_attribute(:#{attribute_name})'s?
    # That's to deal with situations where an attribute/map-key/list-value 
    # is a ruby reserved keyword.
    # Eg. attribute :yield
    #
    # calling with 'power' is like writing:
    #   def power
    #     get_fauxsql_attribute(:power)
    #   end
    #
    #   def power=(value)
    #     set_fauxsql_attribute(:power, value)
    #   end
    def attribute(attribute_name, options={})
      options[:attribute_type] = :attribute
      fauxsql_options[attribute_name] = normalize_options!(options)
      define_fauxsql_getter(attribute_name)
      
      class_eval <<EORUBY, __FILE__, __LINE__ + 1
        def #{attribute_name}=(value)
          set_fauxsql_attribute(:#{attribute_name}, value)
        end
EORUBY

      if options[:nest]
        class_eval <<EORUBY, __FILE__, __LINE__ + 1
          def #{attribute_name}_attributes=(vals)
            vals = Fauxsql::DSL.normalize_nested_vals!(vals)
            __send__(:#{attribute_name}=, get_fauxsql_attribute(:#{attribute_name}).get_nested_record(vals))
          end
EORUBY
      end
    end

    # DSL method to define a named Fauxsql list
    #
    # calling with 'squad_members' is like writing:
    #   def squad_members
    #     get_fauxsql_attribute(:squad_members)
    #   end
    def list(attribute_name, options={})
      options[:attribute_type] = :list
      fauxsql_options[attribute_name] = normalize_options!(options)
      define_fauxsql_getter(attribute_name)

      if options[:nest]
        class_eval <<EORUBY, __FILE__, __LINE__ + 1
          def #{attribute_name}=(attrs)
            get_fauxsql_attribute(:#{attribute_name}).clear
            attrs.each do |index, vals|
              vals = Fauxsql::DSL.normalize_nested_vals!(vals)
              record = get_fauxsql_attribute(:#{attribute_name}).get_nested_record(vals)
              get_fauxsql_attribute(:#{attribute_name}) << record if record unless vals[:_delete]
            end
          end
EORUBY
      end
    end

    # DSL method to define a named Fauxsql map
    #
    # calling with 'mitigates' is like writing:
    #   def mitigates
    #     get_fauxsql_attribute(:mitigates)
    #   end
    def map(attribute_name, options={})
      options[:attribute_type] = :map
      fauxsql_options[attribute_name] = normalize_options!(options)
      define_fauxsql_getter(attribute_name)

      if options[:nest]
        class_eval <<EORUBY, __FILE__, __LINE__ + 1
          def #{attribute_name}=(attrs)
            deletes = []
            attrs.each do |index, vals|
              vals = Fauxsql::DSL.normalize_nested_vals!(vals)
              key = get_fauxsql_attribute(:#{attribute_name}).get_nested_record(vals)
              get_fauxsql_attribute(:#{attribute_name})[key] = vals[:value]
              deletes << key if vals[:_delete]
            end
            deletes.each{ |key| get_fauxsql_attribute(:#{attribute_name}).delete(key) }
          end
EORUBY
      end
    end

    # DSL method to define a named Fauxsql manymany relationship
    #
    # calling with 'friends' is like writing:
    #   def friends
    #     get_fauxsql_attribute(:friends, :nest => Other, :through => :friends)
    #   end
    def manymany(attribute_name, options)
      options[:attribute_type] = :manymany
      fauxsql_options[attribute_name] = normalize_options!(options)
      define_fauxsql_getter(attribute_name)
    end

    def has_fauxsql_attribute?(name, type=nil)
      return false unless options = fauxsql_options[name]
      case type
      when nil
        true
      else
        options[:attribute_type] == type
      end
    end
    
  private
  
    def define_fauxsql_getter(attribute_name)
      class_eval <<EORUBY, __FILE__, __LINE__ + 1
        def #{attribute_name}
          get_fauxsql_attribute(:#{attribute_name})
        end
EORUBY
    end
  
    def normalize_options!(options)
      options[:nest] = [options[:nest]] if options[:nest] unless options[:nest].is_a?(Array)
      options[:nest] ||= []
      options.freeze
    end
    
    def self.normalize_nested_vals!(vals)
      vals[:_delete] = true if vals[:_delete] == "1" # Rails forms return "1" for nested attributes deletion.
      vals[:_delete] = false unless vals[:_delete] == true
      vals.freeze
    end
  end
end