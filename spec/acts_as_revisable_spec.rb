require File.dirname(__FILE__) + '/spec_helper.rb'

class Project < ActiveRecord::Base
  acts_as_revisable do
    revision_class_name "Session"
    except :unimportant
  end
end

class Session < ActiveRecord::Base
  acts_as_revision do
    revisable_class_name "Project"
  end
end

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
      @project.name = "Stephen"
      @project.save
    end
    
    it "should have a revision_number of one" do
      @project.revision_number.should == 1
    end
    
    it "should have a single revision" do
      @project.revisions.size.should == 1
    end
    
    it "should have the original revision's data" do
      @project.revisions.first.name.should == "Rich"
    end
  end
end
