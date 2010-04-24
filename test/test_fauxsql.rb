require 'test/helper'

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
  property :type, Discriminator
  attribute :name
  attribute :record
  list :things
  map :dictionary
  
  manymany :others, FauxObject, :through => :others
end

class OtherFauxObject < FauxObject; end

class TestFauxsql < Test::Unit::TestCase
  context "A FauxObject" do
    setup do
      DataMapper.auto_migrate!
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
      checkpoint!
      assert_equal "MyName", @faux.name
    end
    
    should "persist lists" do
      @faux.things << :hello
      @faux.things << :goodbye
      checkpoint!
      assert @faux.things == [:hello, :goodbye]
    end
    
    should "persist maps" do
      @faux.dictionary[:a] = 1
      @faux.dictionary[:b] = 2
      checkpoint!
      assert_equal 1, @faux.dictionary[:a]
      assert_equal 2, @faux.dictionary[:b]
    end
    
    should "dereference and resolve objects that include Fauxsql" do
      has_fauxsql = OtherFauxObject.create
      @faux.record = has_fauxsql
      checkpoint!
      assert_equal has_fauxsql, @faux.record
    end
    
    should "dereference and resolve dm objects with simple keys" do
      simple_key = SimpleKey.create
      @faux.record = simple_key
      checkpoint!
      assert @faux.fauxsql_attributes[:record].is_a?(Fauxsql::DereferencedAttribute)
      assert_equal simple_key, @faux.record
    end
    
    should "deference and resolve dm objects with complex keys" do
      complex_key = ComplexKey.create(:string => "string", :integer => 1)
      @faux.record = complex_key
      checkpoint!
      assert @faux.fauxsql_attributes[:record].is_a?(Fauxsql::DereferencedAttribute)
      assert_equal complex_key, @faux.record
    end
    
    should "derefencenc and resolve dm objects in lists" do
      simple = SimpleKey.create
      @faux.things << :hello
      @faux.things << simple
      @faux.things << :goodbye
      checkpoint!
      assert_equal [:hello, simple, :goodbye], @faux.things.all
    end

    should "derefencenc and resolve fauxsql objects in lists" do
      has_fauxsql = OtherFauxObject.create
      @faux.things << :hello
      @faux.things << has_fauxsql
      @faux.things << :goodbye
      checkpoint!
      assert_equal [:hello, has_fauxsql, :goodbye], @faux.things.all
    end

    should "derefencenc and resolve fauxsql objects in lists when calling each/each_with_index" do
      has_fauxsql = OtherFauxObject.create
      @faux.things << has_fauxsql
      checkpoint!
      @faux.things.each_with_index do |thing, index|
        assert_equal has_fauxsql, thing
      end
      @faux.things.each do |thing|
        assert_equal has_fauxsql, thing
      end
    end

    should "derference and resolve dm objects with fauxsql in maps" do
      has_fauxsql1 = OtherFauxObject.create
      has_fauxsql2 = OtherFauxObject.create
      @faux.dictionary[has_fauxsql1] = has_fauxsql2
      checkpoint!
      assert_equal has_fauxsql2, @faux.dictionary[has_fauxsql1]
    end

    should "derference and resolve dm objects in maps" do
      simple1 = SimpleKey.create
      simple2 = SimpleKey.create
      @faux.dictionary[simple1] = simple2
      assert_equal SimpleKey, @faux.dictionary.keys.first.class
      checkpoint!
      assert_equal simple2, @faux.dictionary[simple1]
    end
    
    should "give records as keys/values when calling #each" do
      simple1 = SimpleKey.create
      simple2 = SimpleKey.create
      @faux.dictionary[simple1] = simple2
      checkpoint!
      @faux.dictionary.each do |key, value|
        assert_equal simple1, key
        assert_equal simple2, value
      end
    end
    
    should "not choke on normal values in hash when calling #each" do
      simple1 = SimpleKey.create
      @faux.dictionary[simple1] = 33
      checkpoint!
      @faux.dictionary.each{|key, value| }
      assert true, "choked on normal values in #each"
    end

    should "persist changes to maps" do
      simple1 = SimpleKey.create
      @faux.dictionary[simple1] = 33
      checkpoint!
      @faux.dictionary[simple1] = 50
      checkpoint!
      assert_equal 50, @faux.dictionary[simple1]
    end

    should "persist changes to lists" do
      has_fauxsql = OtherFauxObject.create
      @faux.things << :hello
      @faux.things << has_fauxsql
      @faux.things << :goodbye
      checkpoint!
      @faux.things.clear
      checkpoint!
      assert_equal [], @faux.things.all
    end
  
    should "delete items from maps" do
      simple1 = SimpleKey.create
      @faux.dictionary[simple1] = 33
      checkpoint!
      @faux.dictionary.delete(simple1)
      checkpoint!
      assert_equal nil, @faux.dictionary[simple1]
    end
    
    context "with a manymany relationship" do
      setup do
        @faux =  FauxObject.create!
        @other = FauxObject.create!
        @faux.others << @other
        checkpoint!
      end
      
      should "associate manymany relationships" do
        assert_equal [@faux], @other.others.all # LOL "LOST" JOKE
        assert_equal [@other], @faux.others.all
      end
    
      should "delete from manymany relationships" do
        third = FauxObject.create
        @faux.others << third
        checkpoint!
        @faux.others.delete(@other)
        checkpoint!
        third.save; third.reload
        assert_equal [third], @faux.others.all
        assert_equal [], @other.others.all
      end
      
      # TODO think about paranoid deletion
    end
  end
end
