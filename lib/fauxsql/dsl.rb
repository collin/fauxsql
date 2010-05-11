require "active_support/inflector"
module Fauxsql
  module DSL
    class InvalidNesting < StandardError; end
    # DSL method to define a named Fauxsql attribute
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
      fauxsql_options[attribute_name] = normalize_options!(options)
      class_eval <<EORUBY, __FILE__, __LINE__
        def #{attribute_name}
          get_fauxsql_attribute(:#{attribute_name})
        end

        def #{attribute_name}=(value)
          set_fauxsql_attribute(:#{attribute_name}, value)
        end
EORUBY

      if options[:nest]
        class_eval <<EORUBY, __FILE__, __LINE__
          def #{attribute_name}_attributes=(vals)
            vals = Fauxsql::DSL.normalize_nested_vals!(vals)
            #{attribute_name} = #{attribute_name}.get_nested_record(vals)
          end
EORUBY
      end
    end

    # DSL method to define a named Fauxsql list
    #
    # calling with 'squad_members' is like writing:
    #   def squad_members
    #     get_fauxsql_list(:squad_members)
    #   end
    def list(attribute_name, options={})
      fauxsql_options[attribute_name] = normalize_options!(options)
      class_eval <<EORUBY, __FILE__, __LINE__
        def #{attribute_name}
          get_fauxsql_list(:#{attribute_name})
        end
EORUBY

      if options[:nest]
        class_eval <<EORUBY, __FILE__, __LINE__
          def #{attribute_name}=(attrs)
            #{attribute_name}.clear
            attrs.each do |index, vals|
              vals = Fauxsql::DSL.normalize_nested_vals!(vals)
              record = #{attribute_name}.get_nested_record(vals)
              #{attribute_name} << record if record unless vals[:_delete]
            end
          end
EORUBY
      end
    end

    # DSL method to define a named Fauxsql map
    #
    # calling with 'mitigates' is like writing:
    #   def mitigates
    #     get_fauxsql_map(:mitigates)
    #   end
    def map(attribute_name, options={})
      fauxsql_options[attribute_name] = normalize_options!(options)
      class_eval <<EORUBY, __FILE__, __LINE__
        def #{attribute_name}
          get_fauxsql_map(:#{attribute_name})
        end
EORUBY

      if options[:nest]
        class_eval <<EORUBY, __FILE__, __LINE__
          def #{attribute_name}=(attrs)
            deletes = []
            attrs.each do |index, vals|
              vals = Fauxsql::DSL.normalize_nested_vals!(vals)
              key = #{attribute_name}.get_nested_record(vals)
              #{attribute_name}[key] = vals[:value]
              deletes << key if vals[:_delete]
            end
            deletes.each{ |key| #{attribute_name}.delete(key) }
          end
EORUBY
      end
    end

    # DSL method to define a named Fauxsql manymany relationship
    #
    # calling with 'friends' is like writing:
    #   def friends
    #     get_fauxsql_manymany(:friends, Other, :through => :friends)
    #   end
    def manymany(attribute_name, classes, options)
      define_method attribute_name do
        get_fauxsql_manymany(attribute_name, classes, options)
      end
    end

  private
  
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