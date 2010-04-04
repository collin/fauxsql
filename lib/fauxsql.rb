# Libs
require 'active_support/concern'
require 'datamapper'
require 'pathname'

# Internal Libs
root = Pathname.new(__FILE__).dirname.expand_path
require root+'fauxsql/dereferenced_attribute'
require root+'fauxsql/attribute'
require root+'fauxsql/attribute_list'
require root+'fauxsql/attribute_map'
require root+'fauxsql/dsl'
module Fauxsql
  extend ActiveSupport::Concern
  
  included do
    property :fauxsql_attributes, Object, :default => {}
    extend Fauxsql::DSL
  end
  
  # Getter method for attributes defined as:
  #   attribute :attribute_name
  def get_fauxsql_attribute(attribute_name)
    attribute = fauxsql_attributes[attribute_name]
    Fauxsql.resolve_fauxsql_attribute(attribute)
  end

  # Setter method for attributes defined as:
  #   attribute :attribute_name
  def set_fauxsql_attribute(attribute_name, value)
    attribute = Fauxsql.dereference_fauxsql_attribute(value)
    fauxsql_attributes[attribute_name] = attribute
  end
  
  # Gets a reference to an AttributeList object. AttributeList quacks like
  # a Ruby Array. Except it uses Fauxsql's dereference and resolve strategy to
  # store members.
  def get_fauxsql_list(list_name)
    fauxsql_attributes[list_name] or AttributeList.new(self, list_name)
  end

  # Gets a reference to an AttributeMap object. AttributeMap quacks like
  # a Ruby Hash. Except it uses Fauxsql's dereference and resolve strategy to
  # store keys and values.  
  def get_fauxsql_map(map_name)
    fauxsql_attributes[map_name] or AttributeMap.new(self, map_name)
  end

  # When setting values, all attributes pass through this method.
  # This way we can control how certain classes are serialized by Fauxsql
  # See #resolve_fauxsql_attribute to see how attributes are read.
  def self.dereference_fauxsql_attribute(attribute)
    if attribute.is_a?(DataMapper::Resource)
      DereferencedAttribute.new(attribute)
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
end