module Fauxsql
  # AttributeMap is an Hash that dereferences and resolves fauxsql attributes
  # when setting/reading members in the Hash
  def self.dereference_fauxsql_key(key)
    real_key   = Fauxsql.dereference_fauxsql_attribute(key)
    if (real_key.is_a? Fauxsql::DereferencedAttribute)
      real_key = real_key.hash
    end
    real_key
  end
  
  class AttributeMap < Hash
    # We dereference and resolve the key because in Ruby not _any_ object
    # can be a hash key. Even a DataMapper record.
    def []= key, value
      real_key   = Fauxsql.dereference_fauxsql_key(key)
      real_value = Fauxsql.dereference_fauxsql_attribute(value)
      super real_key, real_value
    end

    def [] key
      real_key = Fauxsql.dereference_fauxsql_key(key)
      Fauxsql.resolve_fauxsql_attribute super(real_key)
    end
    
    def delete key
      real_key = Fauxsql.dereference_fauxsql_key(key)
      super(real_key)
    end
    
    def each(&block)
      super do |key, value|
        yield(resolve_key(key), resolve_value(value))
      end
    end

    def keys
      super.map do |key|
        resolve_key(key)
      end
    end
        
    def resolve_key(key)
      if Fauxsql::DereferencedAttribute.is_dump?(key)
        Fauxsql.resolve_fauxsql_attribute Fauxsql::DereferencedAttribute.load(key)
      else
        key
      end
    end
    
    def resolve_value(value)
      Fauxsql.resolve_fauxsql_attribute value
    end
    
    # Always being not eql is expensive
    # TODO make this work without this hack
    def eql?(other)
      return false
    end
  end
end