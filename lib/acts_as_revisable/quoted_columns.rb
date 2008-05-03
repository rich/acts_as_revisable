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

        # Extract table name from qualified attribute names.
        if attr.include?('.')
          table_name, attr = attr.split('.', 2)
          table_name = connection.quote_table_name(table_name)
        else
          table_name = quoted_table_name
        end
        
        return "#{table_name}.#{connection.quote_column_name(attr)}"
      end
      
      quote_bound_value_without_quoted_column(value)
    end
  end
end