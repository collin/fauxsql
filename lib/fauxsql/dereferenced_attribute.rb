require "active_support/inflector"
require "yajl/json_gem"

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
    # TODO: Ask Sundar for opinion about this.
    DumpFormatMarker = 0x309 # Shows up as 777 in a JSON dump (Lucky Sevens :)
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
      JSON.dump [DumpFormatMarker, @klass.to_s, @lookup_key]
    end
    alias hash dump
    
    def self.get(attribute)
      @@identity_map[attribute] ||= new(attribute)
    end
    
    def self.load(dump)
      args = JSON.load( dump )
      args.shift
      new DereferenceAttributeMockDataMapperResource.new( *args )
    end
    
    def self.is_dump?(candidate)
      data = JSON.load(candidate)
      data.is_a?(Array) and data.first == DumpFormatMarker
    rescue JSON::ParserError
      false
    end
  end
  
  # This class is used by DereferencedAttribute.load(<JSON>)
  # The struct is passed to DereferencedAttribute.initialize mimicking the
  # neccessary methods of DataMapper::Resource
  class DereferenceAttributeMockDataMapperResource
    def initialize(klass, lookup_key)
      @klass, @lookup_key = klass, lookup_key
    end
    
    def key
      [@lookup_key]
    end
    
    def class
      @klass
    end
  end
end