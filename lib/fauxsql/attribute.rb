module Fauxsql
  # Attribute is a mixin for AttributeList and AttributeMap classes.
  # It should be mixed into classes that inherit standard Ruby data structures
  module Attribute
    def initialize(record, name)
      super() # explicitly super without arguments to preserve base behavior
      record.fauxsql_attributes[name] = self
    end
  end
end