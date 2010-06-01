require "pathname"
root = Pathname.new(__FILE__).dirname.expand_path + ".."
require (root + "test/helper").to_s

class SimpleKey
  include DataMapper::Resource  
  property :id, Serial
end

class ComplexKey
  include DataMapper::Resource
  property :string, String, :key => true
  property :integer, Integer, :key => true
end

class RequiringField
  include DataMapper::Resource  
  property :id, Serial
  property :name, String, :required => true
end

class FauxObject
  include DataMapper::Resource
  include Fauxsql
  
  property :id, Serial
  property :type, Discriminator
  attribute :name
  attribute :record, :nest => [FauxObject, String, Symbol]
  attribute :number, :type => :to_i
  list :things, :nest => [FauxObject, RequiringField, Symbol, SimpleKey]
  map :dictionary, :nest => [FauxObject, String, Symbol, SimpleKey]
  map :numbers, :value_type => :to_i
  
  manymany :others, :nest => [FauxObject], :through => :others#, :nest => true TODO implement nesting on manymany
end

class OtherFauxObject < FauxObject
  list :childs_things
end

class TestFauxsql < Test::Unit::TestCase
  def pending(message)
    raise "Pending: #{message}"
  end
  context "A FauxObject" do
    setup do
      DataMapper.auto_migrate!
      @faux = FauxObject.new
    end
    
    should "have reflection for fauxsql maps" do
      assert_same_elements [:dictionary, :numbers], FauxObject.fauxsql_attribute_names(:map)
    end
    
    should "have reflection for fauxsql manymanys" do
      assert_same_elements [:others], FauxObject.fauxsql_attribute_names(:manymany)      
    end
    
    should "have reflection for fauxsql lists" do
      assert_same_elements [:things], FauxObject.fauxsql_attribute_names(:list)
    end
    
    should "have reflection for fauxsql attributes" do
      assert_same_elements [:name, :record, :number], FauxObject.fauxsql_attribute_names(:attribute)
    end
        
    should "reflect all attributes" do
      assert_same_elements [:name, :record, :number, :things, :others, :dictionary, :numbers], FauxObject.fauxsql_attribute_names
    end
    
    should "mix reflections" do
      assert_same_elements [:things, :name, :record, :number], FauxObject.fauxsql_attribute_names(:list, :attribute)
    end
    
    should "have reflection for attributes of specific types on a single record" do
      @faux.things << :one
      @faux.things << :two
      @faux.numbers[:a] = 1
      @faux.numbers[:b] = 1

      assert_same_elements [:things, :numbers, :dictionary], @faux.get_fauxsql_attributes(:map, :list).map(&:name)
    end
    
    should "have reflection on all fauxsql attrs of indeterminate type" do
      pending "Fails because :attribute type is NOT wrapped. TODO: wrap it"
      # Fauxsql attributes are lazy. So to test this we need to load them all first. Othewise they do not exist when we call map
      # @faux.get_fauxsql_attributes
      # raise @faux.get_fauxsql_attributes.inspect
      # assert_same_elements [:things, :dictionary, :numbers], @faux.get_fauxsql_attributes(:map, :list, :ma).map(&:name)
    end
    
    should "have reflection for named fauxsql attributes" do
      assert FauxObject.has_fauxsql_attribute?(:name)
    end
    
    should "have reflection for fauxsql attributes by type" do
      assert FauxObject.has_fauxsql_attribute?(:things, :list)
      assert !(FauxObject.has_fauxsql_attribute?(:things, :manymany))
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
    
    should "update attributes" do
      @faux.name = "AName"
      checkpoint!
      @faux.name = "OtherName"
      checkpoint!
      assert_equal "OtherName", @faux.name
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

    should "reset! maps" do
      @faux.dictionary[:a] = 1
      @faux.dictionary[:b] = 2
      checkpoint!
      @faux.dictionary.reset!
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
      assert_same_elements [:hello, simple, :goodbye], @faux.things.all
    end

    should "reset! lists" do
      has_fauxsql = OtherFauxObject.create
      @faux.things << :hello
      @faux.things << has_fauxsql
      @faux.things << :goodbye
      checkpoint!
      assert_same_elements [:hello, has_fauxsql, :goodbye], @faux.things.all
    end

    should "derefencenc and resolve fauxsql objects in lists" do
      has_fauxsql = OtherFauxObject.create
      @faux.things << :hello
      @faux.things << has_fauxsql
      @faux.things << :goodbye
      checkpoint!
      @faux.things.reset!
      checkpoint!
      assert_same_elements [:hello, has_fauxsql, :goodbye], @faux.things.all
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
      assert_same_elements [], @faux.things.all
    end
  
    should "delete items from maps" do
      simple1 = SimpleKey.create
      @faux.dictionary[simple1] = 33
      checkpoint!
      @faux.dictionary.delete(simple1)
      checkpoint!
      assert_equal nil, @faux.dictionary[simple1]
    end
    
    should "obey typecasting directives for attributes" do
      @faux.number = "33"
      checkpoint!
      assert_equal 33, @faux.number
    end
    
    should "obey typecasting directives for map values" do
      @faux.numbers[:a] = "400"
      checkpoint!
      assert_equal 400, @faux.numbers[:a]
    end
    
    should "obey typecasting directives for map keys" do
      pending "have no need for this currently"
    end
    
    should "obey typecasting directives for list items" do
      pending "hove no need for this currently"
    end
    
    context "with :nested => *" do
      
      should "allow reflection on nested classes" do
        assert_same_elements [FauxObject, RequiringField, Symbol, SimpleKey], @faux.fauxsql_nested_classes(:things)
      end
      
      should "allow reflection on nested classes when there are none" do
        assert_same_elements [], @faux.fauxsql_nested_classes(:number)
      end
      
      should "agree that subclasses are valid nestable classes" do
        assert @faux.things.assert_valid_nested_class!(OtherFauxObject)
      end
      
      context "on a map" do
        should "accept nested attributes" do
          other = FauxObject.create
          @faux.dictionary = { "0" => {
            :type => other.class.name,
            :id => other.id,
            :value => "Nested"
          }}
          checkpoint!
          assert_equal "Nested", @faux.dictionary[other]
        end
        
        should "update nested attributes" do
          other = FauxObject.create
          @faux.dictionary = { "0" => {
            :type => other.class.name,
            :id => other.id,
            :value => "Nested"
          }}
          checkpoint!
          assert_equal "Nested", @faux.dictionary[other]
          @faux.dictionary = { "0" => {
            :type => other.class.name,
            :id => other.id,
            :value => "WOAH"
          }}
          checkpoint!
          assert_equal "WOAH", @faux.dictionary[other]
          assert_equal 1, @faux.dictionary.size
        end
        
        should "delete nested attributes" do
          other = FauxObject.create
          @faux.dictionary = { "0" => {
            :type => other.class.name,
            :id => other.id,
            :value => "Nested"
          }}
          checkpoint!
          @faux.dictionary = { "0" => {
            :type => other.class.name,
            :id => other.id,
            :_delete => true
          }}
          checkpoint!
          assert_same_elements [], @faux.dictionary.keys
        end
      end

      context "on a list" do
        should "accept nested attributes" do
          other = FauxObject.create
          @faux.things = { "0" => {
            :type => other.class.name,
            :id => other.id
          }}
          checkpoint!
          assert_same_elements [other], @faux.things.all
        end
        
        should  "create new records when there is no id" do
          @faux.things = { "0" => {
            :type => FauxObject.name,
            :name => "WHATUP!!"
          }}
          checkpoint!
          assert @faux.things.first.id
          assert_equal "WHATUP!!", @faux.things.first.name
        end
        
        should "preserve validation errors across checkpoints, but not save" do
          @faux.things = { "0" => {
            :type => RequiringField.name
          }}
          checkpoint!
          assert !(@faux.things.empty?)
          bad_thing = @faux.things.first
          assert bad_thing.new?
          assert !(@faux.valid?)
          assert bad_thing.errors.on(:name).any?
        end
        
        should "update nested attributes" do
          other = FauxObject.create
          @faux.things = { "0" => {
            :type => other.class.name,
            :id => other.id,
            :name => "WHATUP!!"
          }}
          checkpoint!
          assert_equal "WHATUP!!", @faux.things.first.name

          @faux.things = { "0" => {
            :type => other.class.name,
            :id => other.id,
            :name => "HOLLA"
          }}
          checkpoint!
          assert_equal "HOLLA", @faux.things.first.name
        end

        should "delete nested attributes" do
          other = FauxObject.create
          @faux.things = { "0" => {
            :type => other.class.name,
            :id => other.id
          }}
          checkpoint!
          @faux.things = { "0" => {
            :type => other.class.name,
            :id => other.id,
            :_delete => true
          }}
          checkpoint!
          assert_same_elements [], @faux.things.all
        end        
      end
      
      context "on an attribute" do
        should "accept nested attribute" do
        pending "have no need for this currently"
        #   other = FauxObject.create
        #   @faux.record = {
        #     :type => other.class.name,
        #     :id => other.id
        #   }
        #   checkpoint!
        #   assert_equal other, @faux.record
        end
        
        should "delete nested attribute" do
          pending "have no need for this currently"
          # other = FauxObject.create
          # @faux.record = {
          #   :type => other.class.name,
          #   :id => other.id
          # }
          # checkpoint!
          # other = FauxObject.create
          # @faux.record = {
          #   :type => other.class.name,
          #   :id => other.id,
          #   :_delete => true
          # }
          # checkpoint!
          # assert_equal nil, @faux.record
        end
      end
    end
        
    context "with a manymany relationship" do
      setup do
        @faux  = FauxObject.create!
        @other = FauxObject.create!
        @faux.others << @other
        checkpoint!
      end
      
      should "associate manymany relationships" do
        assert_same_elements [@faux], @other.others.all # LOL "LOST" JOKE
        assert_same_elements [@other], @faux.others.all
      end
    
      should "delete from manymany relationships" do
        third = FauxObject.create
        @faux.others << third
        checkpoint!
        @faux.others.delete(@other)
        checkpoint!
        third.save; third.reload
        assert_same_elements [third], @faux.others.all
        assert_same_elements [], @other.others.all
      end
      
      # TODO think about paranoid deletion
    end
    
    should "return keys for dictionary stores" do
      @faux.dictionary['a'] = 1
      @faux.dictionary['b'] = 1
      @faux.dictionary['c'] = 1
      checkpoint!
      assert_same_elements ['a', 'b', 'c'], @faux.dictionary.keys
    end
  end
end
