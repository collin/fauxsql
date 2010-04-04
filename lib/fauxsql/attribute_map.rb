module Fauxsql
  # AttributeMap is an Hash that dereferences and resolves fauxsql attributes
  # when setting/reading members in the Hash
  class AttributeMap < Hash
    include Attribute
    
    # We dereference and resolve the key because in Ruby _any_ object
    # can be a hash key. Even a DataMapper record.
    def []= key, value
      real_key   = Fauxsql.dereference_fauxsql_attribute(key)
      real_value = Fauxsql.dereference_fauxsql_attribute(value)
      super real_key.hash, real_value
    end

    def [] key
      real_key = Fauxsql.dereference_fauxsql_attribute(key)
      Fauxsql.resolve_fauxsql_attribute super(real_key.hash)
    end    
  end
end