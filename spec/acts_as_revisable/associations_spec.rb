require 'spec_helper'

describe WithoutScope::ActsAsRevisable do  
  after(:each) do
    cleanup_db
  end

  before(:each) do
    @project = Project.create(:name => "Rich", :notes => "this plugin's author")
    @project.update_attribute(:name, "one")
    @project.update_attribute(:name, "two")
    @project.update_attribute(:name, "three")
  end

  it "should have a pretty named association" do
    lambda { @project.sessions }.should_not raise_error
  end

  it "should return all the revisions" do
    @project.revisions.size.should == 3
  end
end
