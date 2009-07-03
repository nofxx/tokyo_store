require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TokyoStore" do
  it "should store fragment cache" do
    Rufus::Tokyo::Tyrant.should_receive(:new).and_return(@mock_tyrant = mock("Tyrant"))
    store = ActiveSupport::Cache.lookup_store :tokyo_store, "data.tch"
    store.should be_kind_of ActiveSupport::Cache::TokyoStore
  end

  it "should fail" do
    tokyo = Rufus::Tokyo::Tyrant.new('localhost', 1978)
    Rufus::Tokyo::Tyrant.should_not_receive(:new)
    store = ActiveSupport::Cache.lookup_store :tokyo_store, tokyo
    store.should be_kind_of ActiveSupport::Cache::TokyoStore
  end

  describe "Similar" do

    before(:each) do
      @cache = ActiveSupport::Cache::TokyoStore.new 'localhost:1978'
      @cache.clear
    end

    it "should return true on success" do
      @cache.write('foo', 'bar').should be_true
    end

    it "should read and write strings" do
      @cache.write('foo', 'bar')
      @cache.read('foo').should eql('bar')
    end

    it "should read and write hash" do
      @cache.write('foo', {:a => "b"})
      @cache.read('foo').should eql({:a => "b"})
    end

    it "should write integers" do
      @cache.write('foo', 1)
      @cache.read('foo').should eql(1)
    end

    it "should write nil" do
      @cache.write('foo', nil)
      @cache.read('foo').should eql(nil)
    end

    it "should have a cache miss block" do
      @cache.write('foo', 'bar')
      @cache.fetch('foo') { 'baz' }.should eql('bar')
    end

    it "should have a cache miss block" do
      @cache.fetch('foo') { 'baz' }.should eql('baz')
    end

    it "should have a forced cache miss block" do
      @cache.fetch('foo', :force => true).should be_nil
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
      @cache.read_multi('a','b').should eql({ 'a' => 1, 'b' => 2})
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
      @cache.write('val', 1, :raw => true)
      @cache.read("val", :raw => true).to_i.should eql 1
      @cache.increment('val')
      @cache.read("val", :raw => true).to_i.should eql 2
      @cache.increment('val')
      @cache.read("val", :raw => true).to_i.should eql 3
    end

    it "should decrement value" do
      @cache.write('val', 3, :raw => true)
      @cache.read("val", :raw => true).to_i.should eql 3
      @cache.decrement('val')
      @cache.read("val", :raw => true).to_i.should eql 2
      @cache.decrement('val')
      @cache.read("val", :raw => true).to_i.should eql 1
    end

    it "should clear all" do
      @cache.increment("val")
      @cache.exist?("val").should be_true
      @cache.clear
      @cache.exist?("val").should be_false
    end

    it "should show some stats" do
      @cache.stats.should be_instance_of Hash #== hash_including({ :type => "hash"})
    end

    it "store objects should be immutable" do
      @cache.with_local_cache do
        @cache.write('foo', 'bar')
        @cache.read('foo').gsub!(/.*/, 'baz')# }.should raise_error(ActiveSupport::FrozenObjectError)
        @cache.read('foo').should ==  'bar'
      end
    end

    it "stored objects should not be frozen" do
      @cache.with_local_cache do
        @cache.write('foo', 'bar')
      end
      @cache.with_local_cache do
        @cache.read('foo').should_not be_frozen
      end
    end

    it "should delete matched" do
      @cache.write("val", 1)
      @cache.write("value", 1)
      @cache.write("not", 1)
      @cache.delete_matched('val')
    end

  end

  describe "backed store" do
    before(:each) do
      @cache = ActiveSupport::Cache.lookup_store(:tokyo_store)
      @data = @cache.instance_variable_get(:@data)
      @cache.clear
    end

    it "local_writes_are_persistent_on_the_remote_cache" do
      @cache.with_local_cache do
        @cache.write('foo', 'bar')
      end

      @cache.read('foo').should eql('bar')
    end

    it "test_clear_also_clears_local_cache" do
      @cache.with_local_cache do
        @cache.write('foo', 'bar')
        @cache.clear
        @cache.read('foo').should be_nil
      end
    end

    it "test_local_cache_of_read_and_write" do
      @cache.with_local_cache do
        @cache.write('foo', 'bar')
        @data.clear # Clear remote cache
        @cache.read('foo').should eql('bar')
      end
    end

    it "test_local_cache_should_read_and_write_integer" do
      @cache.with_local_cache do
        @cache.write('foo', 1)
        @cache.read('foo').should eql(1)
      end
    end

    it "test_local_cache_of_delete" do
      @cache.with_local_cache do
        @cache.write('foo', 'bar')
        @cache.delete('foo')
        @data.clear # Clear remote cache
        @cache.read('foo').should be_nil
      end
    end

    it "test_local_cache_of_exist" do
      @cache.with_local_cache do
        @cache.write('foo', 'bar')
        @cache.instance_variable_set(:@data, nil)
        @data.clear # Clear remote cache
        @cache.exist?('foo').should be_true
      end
    end

    it "test_local_cache_of_increment" do
      @cache.with_local_cache do
        @cache.write('foo', 1, :raw => true)
        @cache.increment('foo')
        @data.clear # Clear remote cache
        @cache.read('foo', :raw => true).to_i.should eql(2)
      end
    end

    it "test_local_cache_of_decrement" do
      @cache.with_local_cache do
        @cache.write('foo', 1, :raw => true)
        @cache.decrement('foo')
        @data.clear # Clear remote cache
        @cache.read('foo', :raw => true).to_i.should be_zero
      end
    end

    it "test_exist_with_nulls_cached_locally" do
      @cache.with_local_cache do
        @cache.write('foo', 'bar')
        @cache.delete('foo')
        @cache.exist?('foo').should be_false
      end
    end

    it "test_multi_get" do
      @cache.with_local_cache do
        @cache.write('foo', 1)
        @cache.write('goo', 2)
        @cache.read_multi('foo', 'goo').should eql({'foo' => 1, 'goo' => 2})
      end
    end

    it "test_middleware" do
      app = lambda { |env|
        result = @cache.write('foo', 'bar')
        @cache.read('foo').should eql('bar') # make sure 'foo' was written
      }
      app = @cache.middleware.new(app)
      app.call({})
    end

  end

end
