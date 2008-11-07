require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

describe Dataset::SessionBinding do
  before :all do
    @database = Dataset::Database::Sqlite3.new(SQLITE_DATABASE, "#{SPEC_ROOT}/tmp")
  end
  
  before do
    @database.clear
    @binding = Dataset::SessionBinding.new(@database)
  end
  
  it 'should support direct record inserts like classic fixtures' do
    Thing.should_not_receive :new
    lambda do
      return_value = @binding.create_record Thing
      return_value.should be_kind_of(Integer)
    end.should change(Thing, :count).by(1)
  end
  
  it 'should support creating records by instantiating the record class so callbacks work' do
    thing = Thing.new
    Thing.should_receive(:new).and_return(thing)
    lambda do
      return_value = @binding.create_model Thing
      return_value.should be_kind_of(Thing)
    end.should change(Thing, :count).by(1)
  end
  
  describe 'create_record' do
    it 'should accept raw attributes for the insert' do
      @binding.create_record Thing, :name => 'my thing'
      Thing.last.name.should == 'my thing'
    end
    
    it 'should optionally accept a symbolic name for later lookup' do
      @binding.create_record Thing, :my_thing, :name => 'my thing'
      @binding.find_model(Thing, :my_thing).name.should == 'my thing'
    end
    
    it 'should auto-assign _at and _on columns with their respective time types' do
      @binding.create_record Note
      Note.last.created_at.should_not be_nil
      Note.last.updated_at.should_not be_nil
      
      @binding.create_record Thing
      Thing.last.created_on.should_not be_nil
      Thing.last.updated_on.should_not be_nil
    end
  end
  
  describe 'create_model' do
    it 'should accept raw attributes for the insert' do
      @binding.create_model Thing, :name => 'my thing'
      Thing.last.name.should == 'my thing'
    end
    
    it 'should optionally accept a symbolic name for later lookup' do
      @binding.create_model Thing, :my_thing, :name => 'my thing'
      @binding.find_model(Thing, :my_thing).name.should == 'my thing'
    end
    
    it 'should bypass mass assignment restrictions' do
      person = @binding.create_model Person, :first_name => 'Adam', :last_name => 'Williams'
      person.last_name.should == 'Williams'
    end
  end
  
  describe 'nested bindings' do
    before do
      @binding.create_model Thing, :mything, :name => 'my thing'
      @nested_scope = Dataset::SessionBinding.new(@binding)
    end
    
    it 'should walk up the tree to find models' do
      @nested_scope.find_model(Thing, :mything).should == @binding.find_model(Thing, :mything)
    end
  end
end