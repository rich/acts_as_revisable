require File.dirname(__FILE__) + '/spec_helper.rb'

describe "the quoted_columns extension" do      
  after(:each) do
    cleanup_db
  end
  
  it "should quote symbols matching column names as columns" do
    Project.send(:quote_bound_value, :name).should == %q{"projects"."name"}
  end
  
  it "should not quote symbols that don't match column names" do
    Project.send(:quote_bound_value, :whatever).should == "'#{:whatever.to_yaml}'"
  end
  
  it "should not quote strings any differently" do
    Project.send(:quote_bound_value, "what").should == Project.send(:quote_bound_value_with_quoted_column, "what")
  end  
end