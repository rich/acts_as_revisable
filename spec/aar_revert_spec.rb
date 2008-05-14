require File.dirname(__FILE__) + '/spec_helper.rb'

describe FatJam::ActsAsRevisable, "with reverting" do
  before(:all) do
    setup_db
  end
  
  after(:all) do
    teardown_db
  end
  
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
  
  it "should let you revert to previous versions without a new revision" do
    @project.revert_to!(:first, :without_revision => true)
    @project.revisions.size.should == 1
  end
end