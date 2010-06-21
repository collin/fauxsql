module Fauxsql::DataMapper
  module FauxsqlAccessor
    extend ActiveSupport::Memoizable
    def fauxsql_attributes
      unless attributes = attribute_get(:fauxsql_attributes)
        attributes = Fauxsql::Attributes.new
        attribute_set(:fauxsql_attributes, attributes)
      end
      attributes
    end
    memoize :fauxsql_attributes
  end
  
  extend ActiveSupport::Concern
  included do
    include Fauxsql
    # Benchmark shows performance is up to 5x slower when accessing fauxsql attributes lazily.
    property :fauxsql_attributes, Object, :lazy => false

    # Let dm define this first, then we can swoop in.
    include FauxsqlAccessor
    
    validates_with_method :fauxsql_collect_nested_errors
  end
end