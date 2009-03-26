# This module is more about the pretty than anything else. This allows
# you to use symbols for column names in a conditions hash.
#
#   User.find(:all, :conditions => ["? = ?", :name, "sam"])
# 
# Would generate:
# 
#   select * from users where "users"."name" = 'sam'
# 
# This is consistent with Rails and Ruby where symbols are used to
# represent methods. Only a symbol matching a column name will 
# trigger this beavior.
module WithoutScope::QuotedColumnConditions
  def self.included(base)
    base.send(:extend, ClassMethods)
  end
  
  module ClassMethods
    def quote_bound_value(value)
      if value.is_a?(Symbol) && column_names.member?(value.to_s)
        # code borrowed from sanitize_sql_hash_for_conditions
        attr = value.to_s
        table_name = quoted_table_name
        
        return "#{table_name}.#{connection.quote_column_name(attr)}"
      end
      
      super(value)
    end
  end
end