require "active_support/inflector"
module Fauxsql
  class DereferencingIllegalAttribute < ArgumentError
    def initialize(attribute)
      super "#{attribute} has a nil lookup key. I do not know how to dereference attributes without keys."
    end
  end
  # DereferencedAttribute stores objects that quack like DataMapper::Resource
  # This is the object that Fauxsql stores in the database when a 
  # DataMapper::Resource object is given. This way only the class and the 
  # primary key are stored.
  class DereferencedAttribute
    @@identity_map = {}
    def initialize(attribute)
      raise DereferencingIllegalAttribute.new(attribute) if attribute.key.nil?
      @klass      = attribute.class.to_s
      @lookup_key = attribute.key
    end
    
    def resolve
      ActiveSupport::Inflector.constantize(@klass.to_s).get(*@lookup_key)
    end
    
    def dump
      Marshal.dump(self)
    end
    alias hash dump
    
    def self.get(attribute)
      @@identity_map[attribute] ||= new(attribute)
    end
    
    def self.load(dump)
      Marshal.load(dump)
    end
  end
end