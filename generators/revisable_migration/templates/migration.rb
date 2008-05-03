class Make<%= class_name.underscore.camelize %>Revisable < ActiveRecord::Migration
  def self.up
    <% cols.each do |c| -%>
    add_column :<%= class_name.downcase.pluralize %>, :<%= c.first %>, :<%= c.last %>
    <% end -%>
  end

  def self.down
    <% cols.each do |c| -%>
    remove_column :<%= class_name.downcase.pluralize %>, :<%= c.first %>
    <% end -%>
  end
end
