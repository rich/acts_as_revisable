require File.dirname(__FILE__) + '/spec_helper.rb'

describe FatJam::ActsAsRevisable do
  before(:all) do
    setup_db
  end
  
  after(:each) do
    cleanup_db
  end
  
  after(:all) do
    teardown_db
  end
  
  before(:each) do
    @project = Project.create(:name => "Rich", :notes => "this plugin's author")
  end
  
  describe "without revisions" do
    it "should have a revision_number of zero" do
      @project.revision_number.should == 0
    end

    it "should have no revisions" do
      @project.revisions.should be_empty
    end
  end
  
  describe "with revisions" do
    before(:each) do
      @project.update_attribute(:name, "Stephen")
    end
    
    it "should have a revision_number of one" do
      @project.revision_number.should == 1
    end
    
    it "should have a single revision" do
      @project.revisions.size.should == 1
    end
    
    it "should return an instance of the revision class" do
      @project.revisions.first.should be_an_instance_of(Session)
    end
    
    it "should have the original revision's data" do
      @project.revisions.first.name.should == "Rich"
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
