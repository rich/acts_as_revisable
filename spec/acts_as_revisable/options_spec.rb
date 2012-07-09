require 'spec_helper'

shared_examples_for "common Options usage" do
  it "should return a set value" do
    @options.one.should == 1
  end
  
  it "should return nil for an unset value" do
    @options.two.should be_nil
  end
  
  it "should return false for unset query option" do
    @options.should_not be_unset_value
  end
  
  it "should return true for a query option set to true" do
    @options.should be_yes
  end
  
  it "should return false for a query option set to false" do
    @options.should_not be_no
  end
  
  it "should return false for a query on a non-boolean value" do
    @options.should_not be_one
  end
  
  it "should return an array when passed one" do
    @options.arr.should be_a_kind_of(Array)
  end
  
  it "should not return an array when not passed one" do
    @options.one.should_not be_a_kind_of(Array)
  end
  
  it "should have the right number of elements in an array" do
    @options.arr.size.should == 3
  end
end

describe WithoutScope::ActsAsRevisable::Options do
  describe "with hash options" do
    before(:each) do
      @options = WithoutScope::ActsAsRevisable::Options.new :one => 1, :yes => true, :no => false, :arr => [1,2,3]
    end
    
    it_should_behave_like "common Options usage"
  end
  
  describe "with block options" do
    before(:each) do
      @options = WithoutScope::ActsAsRevisable::Options.new do
        one 1
        yes true
        arr [1,2,3]
      end
    end
    
    it_should_behave_like "common Options usage"
  end
  
  describe "with both block and hash options" do
    before(:each) do
      @options = WithoutScope::ActsAsRevisable::Options.new(:yes => true, :arr => [1,2,3]) do
        one 1
      end
    end
    
    it_should_behave_like "common Options usage"
    
    describe "the block should override the hash" do
      before(:each) do
        @options = WithoutScope::ActsAsRevisable::Options.new(:yes => false, :one => 10, :arr => [1,2,3,4,5]) do
          one 1
          yes true
          arr [1,2,3]
        end
      end
      
      it_should_behave_like "common Options usage"      
    end
  end
end
