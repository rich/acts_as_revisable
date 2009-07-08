<% table_name = class_name.underscore.pluralize -%>
class Make<%= class_name.underscore.pluralize.camelize %>Revisable < ActiveRecord::Migration
  def self.up
    <% cols.each do |column_name,column_type,default| -%>
    add_column :<%= table_name %>, :<%= column_name %>, :<%= column_type %><%= ", :default => #{default}" unless default.blank? %>
    <% end -%>
  end

  def self.down
    <% cols.each do |column_name,_| -%>
    remove_column :<%= table_name %>, :<%= column_name %>
    <% end -%>
  end
end
