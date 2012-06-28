require 'spec_helper'

describe WithoutScope::ActsAsRevisable::Deletable do    
  after(:each) do
    cleanup_db
  end
  
  before(:each) do
    @person = Person.create(:name => "Rich", :notes => "a note")
    @person.update_attribute(:name, "Sam")
  end
  
  it "should store a revision on destroy" do
    lambda{ @person.destroy }.should change(OldPerson, :count).from(1).to(2)
  end
end
