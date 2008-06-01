require File.dirname(__FILE__) + '/spec_helper.rb'

describe FatJam::ActsAsRevisable do    
  after(:each) do
    cleanup_db
  end
  
  describe "with a single revision" do
    before(:each) do
      @project1 = Project.create(:name => "Rich", :notes => "a note")
      @project1.update_attribute(:name, "Sam")
    end
  
    it "should just find the current revision by default" do
      Project.find(:first).name.should == "Sam"
    end
    
    it "should accept the :with_revisions options" do
      lambda { Project.find(:all, :with_revisions => true) }.should_not raise_error
    end
    
    it "should provide find_with_revisions" do
      lambda { Project.find_with_revisions(:all) }.should_not raise_error
    end
    
    it "should find current and revisions with the :with_revisions option" do      
      Project.find(:all, :with_revisions => true).size.should == 2
    end
    
    it "should find current and revisions with the find_with_revisions method" do
      Project.find_with_revisions(:all).size.should == 2
    end
    
    it "should find revisions with conditions" do
      Project.find_with_revisions(:all, :conditions => {:name => "Rich"}).should == [@project1.find_revision(:previous)]
    end
  end
end