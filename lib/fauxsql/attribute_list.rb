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
  end
end