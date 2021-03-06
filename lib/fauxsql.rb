# Libs
require 'active_support/concern'
require 'datamapper'
require 'pathname'

# Internal Libs
root = Pathname.new(__FILE__).dirname.expand_path
require root+'fauxsql/dereferenced_attribute'
require root+'fauxsql/attributes'
require root+'fauxsql/options'
require root+'fauxsql/attribute_list'
require root+'fauxsql/attribute_map'
require root+'fauxsql/attribute_manymany'
require root+'fauxsql/attribute_wrapper'
require root+'fauxsql/map_wrapper'
require root+'fauxsql/list_wrapper'
require root+'fauxsql/manymany_wrapper'
require root+'fauxsql/dsl'
module Fauxsql
  extend ActiveSupport::Concern
  
  included do
    # Property is lazy. Benchmark for lazy loading shows
    # performance is up to 5x slower when accessing fauxsql attributes.
    property :fauxsql_attributes, Object, 
      :default => lambda{|*| Fauxsql::Attributes.new },
      :lazy => false
    extend Fauxsql::DSL
    cattr_accessor :fauxsql_options
    self.fauxsql_options = Fauxsql::Options.new
  end
  
  # Getter method for attributes defined as:
  #   attribute :attribute_name
  def get_fauxsql_attribute(attribute_name)
    attribute = fauxsql_attributes[attribute_name]
    value = Fauxsql.resolve_fauxsql_attribute(attribute)

    options = fauxsql_options[attribute_name]
    options and options[:type] ? value.send(options[:type]) : value
  end

  # Setter method for attributes defined as:
  #   attribute :attribute_name
  def set_fauxsql_attribute(attribute_name, value)
    options = fauxsql_options[attribute_name]
    value = value.send(options[:type]) if options and options[:type]
    
    attribute = Fauxsql.dereference_fauxsql_attribute(value)
    Fauxsql.dirty!(self){ fauxsql_attributes[attribute_name] = attribute }    
  end
  
  # Gets a reference to an AttributeList object. AttributeList quacks like
  # a Ruby Array. Except it uses Fauxsql's dereference and resolve strategy to
  # store members.
  def get_fauxsql_list(attribute_name)
    list = fauxsql_attributes[attribute_name] || AttributeList.new
    ListWrapper.new(list, self, attribute_name, fauxsql_options[attribute_name])
  end

  # Gets a reference to an AttributeMap object. AttributeMap quacks like
  # a Ruby Hash. Except it uses Fauxsql's dereference and resolve strategy to
  # store keys and values.  
  def get_fauxsql_map(attribute_name)
    map = fauxsql_attributes[attribute_name] || AttributeMap.new
    MapWrapper.new(map, self,  attribute_name, fauxsql_options[attribute_name])
  end

  def get_fauxsql_manymany(attribute_name, classes, options)
    manymany = fauxsql_attributes[attribute_name] || AttributeManymany.new
    ManymanyWrapper.new(manymany, self, attribute_name, classes, options)
  end

  # When setting values, all attributes pass through this method.
  # This way we can control how certain classes are serialized by Fauxsql
  # See #resolve_fauxsql_attribute to see how attributes are read.
  def self.dereference_fauxsql_attribute(attribute)
    if attribute.is_a?(DataMapper::Resource)
      DereferencedAttribute.get(attribute)
    else
      attribute
    end
  end
  
  # When reading values, all attributes pass through this method.
  # This way we can control how certain classes are deserialized by Fauxsql
  # See #dereference_fauxsql_attribute to see how attributes are stored.
  def self.resolve_fauxsql_attribute(attribute)
    if attribute.is_a?(DereferencedAttribute)
      attribute.resolve
    else
      attribute
    end
  end
  
  def self.dirty!(record)
    record.attribute_set(:fauxsql_attributes, record.fauxsql_attributes.dup)
    value = yield
    record.attribute_set(:fauxsql_attributes, record.fauxsql_attributes)
    value
  end

  def fauxsql_nested_classes(attribute_name)
    # Find a list of the nested classes that an attribute has and return them as a list
    self.class.fauxsql_options[attribute_name][:nest]   # provides a list of classes  
  end
end