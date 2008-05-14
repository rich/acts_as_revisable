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
module FatJam::QuotedColumnConditions
  def self.included(base)
    base.send(:extend, ClassMethods)

    class << base
      alias_method_chain :quote_bound_value, :quoted_column
    end
  end
  
  module ClassMethods
    def quote_bound_value_with_quoted_column(value)
      if value.is_a?(Symbol) && column_names.member?(value.to_s)
        # code borrowed from sanitize_sql_hash_for_conditions
        attr = value.to_s
        table_name = quoted_table_name
        
        return "#{table_name}.#{connection.quote_column_name(attr)}"
      end
      
      quote_bound_value_without_quoted_column(value)
    end
  end
end