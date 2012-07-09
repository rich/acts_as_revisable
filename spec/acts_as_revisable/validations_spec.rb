require 'spec_helper'

describe WithoutScope::ActsAsRevisable, "with validations" do  
  after(:each) do
    cleanup_db
  end
  
  before(:each) do
    @post = Post.create(:name => 'a post')
    @foo = Foo.create(:name => 'a foo')
    
  end
  
  describe "unique fields" do
    it "should allow revisions" do
      lambda {@post.revise!; @post.revise!}.should_not raise_error
    end    
  end
  
  describe "unique fields with validation scoping off" do
    it "should not allow revisions" do
      lambda {@foo.revise!; @foo.revise!}.should raise_error
    end    
  end
end
