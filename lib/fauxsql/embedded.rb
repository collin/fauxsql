module Fauxsql::Embedded
  extend ActiveSupport::Concern

  included do
    include Fauxsql    
    # validates_with_method :fauxsql_collect_nested_errors
  end
  
  def fauxsql_attributes
    @fauxsql_attributes ||= {}
  end
  
  def attribute_set(name, value)
    @fauxsql_attributes[name] = value
  end
  
  def attribute_get(name)
    @fauxsql_attributes[name]
  end
end