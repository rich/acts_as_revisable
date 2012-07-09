require 'spec_helper'

describe WithoutScope::ActsAsRevisable do    
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
        
    it "should find current and revisions with the :with_revisions option" do      
      Project.find(:all, :with_revisions => true).size.should == 2
    end
        
    it "should find revisions with conditions" do
      Project.find(:all, :conditions => {:name => "Rich"}, :with_revisions => true).should == [@project1.find_revision(:previous)]
    end

		it "should find last revision" do
			@project1.find_revision(:last).should == @project1.find_revision(:previous)
		end
  end
end
