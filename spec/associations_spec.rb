require File.dirname(__FILE__) + '/spec_helper.rb'

describe FatJam::ActsAsRevisable do  
  after(:each) do
    cleanup_db
  end
    
  before(:each) do
    @project = Project.create(:name => "Rich", :notes => "this plugin's author")
    @project.update_attribute(:name => "one")
    @project.update_attribute(:name => "two")
    @project.update_attribute(:name => "three")
  end
end