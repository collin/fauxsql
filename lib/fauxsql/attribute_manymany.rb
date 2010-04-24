module Fauxsql
  # AttributeMap is an Hash that dereferences and resolves fauxsql attributes
  # when setting/reading members in the Hash
  class AttributeManymany < AttributeList
    # Always being not eql is expensive
    # TODO make this work without this hack
    def eql?(other)
      return false
    end
  end
end