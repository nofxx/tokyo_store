require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

if ENV['CABINET']
describe "TokyoStore" do
  it "should store fragment cache" do
    HDB.should_receive(:new).and_return(@mock_hdb = mock("HDB"))
      @mock_hdb.should_receive(:open).with('data.tch', 6).and_return(true)
    store = ActiveSupport::Cache.lookup_store :tokyo_store, "data.tch"
    store.should be_kind_of ActiveSupport::Cache::TokyoStore
  end

  it "should fail" do
    tokyo =  HDB.new
    tokyo.open('data.tch')
    HDB.should_not_receive(:new)
    store = ActiveSupport::Cache.lookup_store :tokyo_store, tokyo
    store.should be_kind_of ActiveSupport::Cache::TokyoStore
  end

  describe "Similar" do

    before(:all) do
      @cache = ActiveSupport::Cache::TokyoStore.new 'data.tcb'
    end

    it "test_should_read_and_write_strings" do
      @cache.write('foo', 'bar')
      @cache.read('foo').should eql('bar')
    end

    it "test_should_read_and_write_hash" do
      @cache.write('foo', {:a => "b"})
      @cache.read('foo').should eql({:a => "b"})
    end

    it "test_should_read_and_write_hash" do
      @cache.write('foo', {:a => "b", :c => "d"})
      @cache.read('foo').should eql({:a => "b", :c => "d"})
    end
  end

end
end
