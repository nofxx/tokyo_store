require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TokyoStore" do
  it "should store fragment cache" do
    Rufus::Tokyo::Tyrant.should_receive(:new).and_return(@mock_tyrant = mock("Tyrant"))
    store = ActiveSupport::Cache.lookup_store :tokyo_store, "data.tch"
    store.should be_kind_of ActiveSupport::Cache::TokyoStore
  end

  it "should fail" do
    tokyo = Rufus::Tokyo::Tyrant.new('localhost', 45001)
    Rufus::Tokyo::Tyrant.should_not_receive(:new)
    store = ActiveSupport::Cache.lookup_store :tokyo_store, tokyo
    store.should be_kind_of ActiveSupport::Cache::TokyoStore
  end

  describe "Similar" do

    before(:all) do
      @cache = ActiveSupport::Cache::TokyoStore.new 'localhost:45001'
    end

    it "test_should_read_and_write_strings" do
      @cache.write('foo', 'bar')
      @cache.read('foo').should eql('bar')
    end

    it "test_should_read_and_write_hash" do
      @cache.write('foo', {:a => "b"})
      @cache.read('foo').should eql({:a => "b"})
    end

    it "should read and write hash" do
      @cache.write('foo', {:a => "b", :c => "d"})
      @cache.read('foo').should eql({:a => "b", :c => "d"})
    end

    it "should read and write array" do
      @cache.write('foo', [1,2,3])
      @cache.read('foo').should eql([1,2,3])
    end

    it "should read and write obj" do
      obj = City.new; obj.name = "Acapulco"; obj.pop = 717766
      @cache.write('foo', obj)
      @cache.read('foo').should be_instance_of City
      @cache.read('foo').name.should eql("Acapulco")
    end

    it "should read multiples" do
      @cache.write('a', 1)
      @cache.write('b', 2)
      @cache.read_multi('a','b').should eql([1,2])
    end

    it "should clear all" do
      @cache.write("erase_me", 1).should be_true
      @cache.delete("erase_me")
      @cache.exist?("erase_me").should be_false
    end

    it "should check if exists" do
      @cache.exist?("new_one").should be_false
      @cache.write("new_one", 1)
      @cache.exist?("new_one").should be_true
    end

    it "should increment value" do
      @cache.write("val", 1)
      @cache.increment("val")
      @cache.read("val").should eql(2)
    end

    it "should decrement value" do
      @cache.write("val", 1)
      @cache.decrement("val")
      @cache.read("val").should eql(0)
    end

    it "should clear all" do
      @cache.exist?("val").should be_true
      @cache.clear
      @cache.exist?("val").should be_false
    end

    it "should show some stats" do
      @cache.stats.should match(hash_including({ :type => "hash"}))
    end

    after(:all) do
      @cache.clear
    end
  end

end
