module Fauxsql
  # AttributeList is an Array that dereferences and resolves fauxsql attributes
  # when setting/reading members in the Array
  class AttributeList < Array
    def <<(attribute)
      super Fauxsql.dereference_fauxsql_attribute(attribute)
    end

    def [] index
      Fauxsql.resolve_fauxsql_attribute super(index)
    end

    def include?(an_item)
      detect { |item| Fauxsql.resolve_fauxsql_attribute(item) == item }
    end

    def first
      self[0]
    end

    def last
      self[length - 1]
    end

    def all
      map{ |item| Fauxsql.resolve_fauxsql_attribute item }
    end

    def equals list
      map_resolved == list
    end
    
    def each
      super{|item| yield(Fauxsql.resolve_fauxsql_attribute(item)) }
    end
    
    def each_with_index
      super{|item, index| yield(Fauxsql.resolve_fauxsql_attribute(item), index) }
    end

    def delete(item)
      real_item = Fauxsql.dereference_fauxsql_attribute(item)
      super(real_item)
    end

    def -(others)
      others = others.map{|other| Fauxsql.dereference_fauxsql_attribute(other).hash }
      reject!{|one| others.include?(one.hash) }
      self
    end

    # Always being not eql is expensive
    # TODO make this work without this hack
    def eql?(other)
      return false
    end

  end
end