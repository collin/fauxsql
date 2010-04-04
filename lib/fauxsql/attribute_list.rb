module Fauxsql
  # AttributeList is an Array that dereferences and resolves fauxsql attributes
  # when setting/reading members in the Array
  class AttributeList < Array
    include Attribute
    
    def <<(attribute)
      super Fauxsql.dereference_fauxsql_attribute(attribute)
    end
    
    def [] index
      Fauxsql.resolve_fauxsql_attribute super(index)
    end
    
    def equals list
      map_resolved == list
    end
    
    def map_resolved
      map = []
      each_with_index do |item, index| 
        map[index] = self[index]
      end
      map
    end    
  end
end