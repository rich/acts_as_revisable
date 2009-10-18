require File.dirname(__FILE__) + '/spec_helper.rb'

class Project
  validates_presence_of :name
end

describe WithoutScope::ActsAsRevisable, "with branching" do    
  after(:each) do
    cleanup_db
  end
  
  before(:each) do
    @project = Project.create(:name => "Rich", :notes => "a note")
    @project.update_attribute(:name, "Sam")
  end
  
  it "should allow for branch creation" do
    @project.should == @project.branch.branch_source
  end
  
  it "should always tie the branch to the correct version" do
    b = @project.branch!
    @project.revise!
    prev = @project.find_revision(:last)
    b.reload.branch_source.should == prev
  end
  
  it "should have branches" do
    b = @project.branch!
    @project.branches.size.should == 1
  end
  
  it "should branch without saving" do
    @project.branch.should be_new_record
  end
  
  it "should branch and save" do
    @project.branch!.should_not be_new_record
  end
  
  it "should not raise an error for a valid branch" do
    lambda { @project.branch!(:name => "A New User") }.should_not raise_error
  end
  
  it "should raise an error for invalid records" do
    lambda { @project.branch!(:name => nil) }.should raise_error
  end
  
  it "should not save an invalid record" do
    @branch = @project.branch(:name => nil)
    @branch.save.should be_false
    @branch.should be_new_record
  end
end