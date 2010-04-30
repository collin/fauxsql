require "active_support/inflector"
module Fauxsql
  module DSL
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
      fauxsql_options[attribute_name] = options
      class_eval <<EORUBY
        def #{attribute_name}
          get_fauxsql_attribute(:#{attribute_name})
        end

        def #{attribute_name}=(value)
          set_fauxsql_attribute(:#{attribute_name}, value)
        end
EORUBY
    end

    # DSL method to define a named Fauxsql list
    #
    # calling with 'squad_members' is like writing:
    #   def squad_members
    #     get_fauxsql_list(:squad_members)
    #   end
    def list(attribute_name, options={})
      fauxsql_options[attribute_name] = options
      class_eval <<EORUBY
        def #{attribute_name}
          get_fauxsql_list(:#{attribute_name})
        end
EORUBY
    end

    # DSL method to define a named Fauxsql map
    #
    # calling with 'mitigates' is like writing:
    #   def mitigates
    #     get_fauxsql_map(:mitigates)
    #   end
    def map(attribute_name, options={})
      fauxsql_options[attribute_name] = options
      class_eval <<EORUBY
        def #{attribute_name}
          get_fauxsql_map(:#{attribute_name})
        end
EORUBY
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

    def accept_nested_list_attrs_for model, map_name
      class_eval <<EORUBY
        def #{map_name}=(attrs)
          #{map_name}.clear
          attrs.each do |index, vals|
            record = #{model.to_s}.get(vals["#{model.name.split("::").underscore}_id"])
            #{map_name} << record if record unless vals[:_delete] == "1" # Rails forms spit out 1 or 0 :)
          end
        end
EORUBY
    end

    def accept_nested_map_attrs_for model, map_name
      basename = ActiveSupport::Inflector.underscore(model.to_s.split("::").last)
      class_eval <<EORUBY
        def #{map_name}=(attrs)
          deletes = []
          attrs.each do |index, vals|
            key = #{model.to_s}.get(vals["#{model.name.split("::").underscore}_id"])
            #{map_name}[key] = vals[:value]
            deletes << key if vals[:_delete] == "1" # Rails forms spit out 1 or 0 :)
          end
          deletes.each{ |key| #{map_name}.delete(key) }
        end
EORUBY
    end    
  end
end