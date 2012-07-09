require 'spec_helper'

describe WithoutScope::ActsAsRevisable do  
  after(:each) do
    cleanup_db
  end
    
  before(:each) do
    @project = Project.create(:name => "Rich", :notes => "this plugin's author")
    @post = Post.create(:name => 'a name')
  end
  
  describe "with auto-detected revision class" do
    it "should find the revision class" do
      Post.revision_class.should == PostRevision
    end
    
    it "should find the revisable class" do
      PostRevision.revisable_class.should == Post
    end
    
    it "should use the revision class" do
      @post.update_attribute(:name, 'another name')
      @post.revisions(true).first.class.should == PostRevision
    end
  end
  
  describe "with auto-generated revision class" do
    it "should have a revision class" do
      Foo.revision_class.should == FooRevision
    end
  end
  
  describe "without revisions" do
    it "should have a revision_number of zero" do
      @project.revision_number.should be_zero
    end

    it "should be the current revision" do
      @project.revisable_is_current.should be_true
    end
    
    it "should respond to current_revision? positively" do
      @project.current_revision?.should be_true
    end
    
    it "should not have any revisions in the generic association" do
      @project.revisions.should be_empty
    end
    
    it "should not have any revisions in the pretty named association" do
      @project.sessions.should be_empty
    end
  end
  
  describe "with revisions" do
    before(:each) do
      @project.update_attribute(:name, "Stephen")
    end
    
    it "should have a revision_number of one" do
      @project.revision_number.should == 1
    end
    
    it "should have a single revision in the generic association" do
      @project.revisions.size.should == 1
    end
    
    it "should have a single revision in the pretty named association" do
      @project.sessions.size.should == 1
    end
    
    it "should have a single revision with a revision_number of zero" do
      @project.revisions.collect{ |rev| rev.revision_number }.should == [0]
    end
    
    it "should return an instance of the revision class" do
      @project.revisions.first.should be_an_instance_of(Session)
    end
    
    it "should have the original revision's data" do
      @project.revisions.first.name.should == "Rich"
    end    
  end
  
  describe "with multiple revisions" do
    before(:each) do
      @project.update_attribute(:name, "Stephen")
      @project.update_attribute(:name, "Michael")
    end
    
    it "should have a revision_number of two" do
      @project.revision_number.should == 2
    end
    
    it "should have revisions with revision_number values of zero and one" do
      @project.revisions.collect{ |rev| rev.revision_number }.should == [1,0]
    end
  end
      
  
  describe "with excluded columns modified" do
    before(:each) do
      @project.update_attribute(:unimportant, "a new value")
    end
    
    it "should maintain the revision_number at zero" do
      @project.revision_number.should be_zero
    end
    
    it "should not have any revisions" do
      @project.revisions.should be_empty
    end
  end
end
