module Fauxsql
  # DereferencedAttribute stores objects that quack like DataMapper::Resource
  # This is the object that Fauxsql stores in the database when a 
  # DataMapper::Resource object is given. This way only the class and the 
  # primary key are stored.
  class DereferencedAttribute
    def initialize(attribute)
      @klass      = attribute.class
      @lookup_key = attribute.key
    end
    
    def resolve
      @klass.get(*@lookup_key)
    end
    
    def dump
      Marshal.dump(self)
    end
    alias hash dump
    
    def self.load(dump)
      Marshal.load(dump)
    end
  end
end