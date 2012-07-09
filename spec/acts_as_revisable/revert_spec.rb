require 'spec_helper'

describe WithoutScope::ActsAsRevisable, "with reverting" do  
  after(:each) do
    cleanup_db
  end
  
  before(:each) do
    @project = Project.create(:name => "Rich", :notes => "a note")
    @project.update_attribute(:name, "Sam")
  end
  
  it "should let you revert to previous versions" do
    @project.revert_to!(:first)
    @project.name.should == "Rich"
  end
  
  it "should accept the :without_revision hash option" do
    lambda { @project.revert_to!(:first, :without_revision => true) }.should_not raise_error
    @project.name.should == "Rich"
  end
  
  it "should support the revert_to_without_revision method" do
    lambda { @project.revert_to_without_revision(:first).save }.should_not raise_error
    @project.name.should == "Rich"
  end
  
  it "should support the revert_to_without_revision! method" do
    lambda { @project.revert_to_without_revision!(:first) }.should_not raise_error
    @project.name.should == "Rich"
  end
  
  it "should let you revert to previous versions without a new revision" do
    @project.revert_to!(:first, :without_revision => true)
    @project.revisions.size.should == 1
  end
  
  it "should support the revert_to method" do
    lambda{ @project.revert_to(:first) }.should_not raise_error
    @project.should be_changed
  end
end
