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
    def attribute(attribute_name)
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
    def list(attribute_name)
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
    def map(attribute_name)
      class_eval <<EORUBY                                                    
        def #{attribute_name}                                                   
          get_fauxsql_map(:#{attribute_name})                                   
        end                                                                     
EORUBY
    end
  end
end