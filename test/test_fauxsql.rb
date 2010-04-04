require 'helper'

class SimpleKey
  include DataMapper::Resource  
  property :id, Serial
end

class ComplexKey
  include DataMapper::Resource
  property :string, String, :key => true
  property :integer, Integer, :key => true
end

class FauxObject
  include DataMapper::Resource
  include Fauxsql
  
  property :id, Serial
  
  attribute :name
  attribute :record
  list :things
  map :dictionary
end

DataMapper.auto_migrate!

class TestFauxsql < Test::Unit::TestCase
  context "A FauxObject" do
    setup do
      @faux = FauxObject.new
    end
    
    should "have getters and setters for attributes" do
      assert @faux.respond_to?(:name)
      assert @faux.respond_to?(:name=)
    end
    
    should "have getter for lists" do
      assert @faux.respond_to?(:things)
    end
    
    should "have getters and setters for maps" do
      assert @faux.respond_to?(:dictionary)
    end
    
    should "persist attributes" do
      @faux.name = "MyName"
      reload
      assert_equal "MyName", @faux.name
    end
    
    should "persist lists" do
      @faux.things << :hello
      @faux.things << :goodbye
      reload
      assert_equal [:hello, :goodbye], @faux.things
    end
    
    should "persist maps" do
      @faux.dictionary[:a] = 1
      @faux.dictionary[:b] = 2
      reload
      assert_equal 1, @faux.dictionary[:a]
      assert_equal 2, @faux.dictionary[:b]
    end
    
    should "deference and resolve dm objects with simple keys" do
      simple_key = SimpleKey.create
      @faux.record = simple_key
      reload
      assert @faux.fauxsql_attributes[:record].is_a?(Fauxsql::DereferencedAttribute)
      assert_equal simple_key, @faux.record
    end
    
    should "deference and resolve dm objects with complex keys" do
      complex_key = ComplexKey.create(:string => "string", :integer => 1)
      @faux.record = complex_key
      reload
      assert @faux.fauxsql_attributes[:record].is_a?(Fauxsql::DereferencedAttribute)
      assert_equal complex_key, @faux.record
    end
    
    should "derefencenc and resolve dm objects in lists" do
      simple = SimpleKey.create
      @faux.things << :hello
      @faux.things << simple
      @faux.things << :goodbye
      reload
      assert_equal [:hello, simple, :goodbye], @faux.things.map_resolved
    end
    
    should "derference and resolve dm objects in maps" do
      simple1 = SimpleKey.create
      simple2 = SimpleKey.create
      @faux.dictionary[simple1] = simple2
      assert_equal simple2, @faux.dictionary[simple1]
      reload
      assert_equal simple2, @faux.dictionary[simple1]
    end
  end
  
end
