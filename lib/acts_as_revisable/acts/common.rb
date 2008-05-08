module FatJam
  module ActsAsRevisable
    module Common
      def self.included(base)
        base.send(:extend, ClassMethods)

        class << base
          alias_method_chain :instantiate, :revisable
        end

        base.instance_eval do
          define_callbacks :before_branch, :after_branch      
          has_many :branches, :class_name => base.class_name, :foreign_key => :revisable_branched_from_id
          belongs_to :branch_source, :class_name => base.class_name, :foreign_key => :revisable_branched_from_id

        end
        base.alias_method_chain :branch_source, :open_scope  
      end

      def branch_source_with_open_scope(*args, &block)
        self.class.without_model_scope do
          branch_source_without_open_scope(*args, &block)
        end
      end

      def branch(*args)
        unless run_callbacks(:before_branch) { |r, o| r == false}
          raise ActiveRecord::RecordNotSaved
        end

        options = args.extract_options!
        options[:revisable_branched_from_id] = self.id
        self.class.column_names.each do |col|
          next unless self.class.revisable_should_clone_column? col
          options[col.to_sym] ||= self[col]
        end

        returning(self.class.revisable_class.create!(options)) do |br|
          run_callbacks(:after_branch)
          br.run_callbacks(:after_branch_created)
        end
      end

      def original_id
        self[:revisable_original_id] || self[:id]
      end
      
      module ClassMethods      
        def revisable_should_clone_column?(col)
          return false if (FatJam::REVISABLE_SYSTEM_COLUMNS + FatJam::REVISABLE_UNREVISABLE_COLUMNS).member? col
          true
        end

        def instantiate_with_revisable(record)
          is_current = columns_hash["revisable_is_current"].type_cast(
                record["revisable_is_current"])

          if (is_current && self == self.revisable_class) || (is_current && self == self.revision_class)
            return instantiate_without_revisable(record)
          end

          object = if is_current
            self.revisable_class
          else
            self.revision_class
          end.allocate

          object.instance_variable_set("@attributes", record)
          object.instance_variable_set("@attributes_cache", Hash.new)

          if object.respond_to_without_attributes?(:after_find)
            object.send(:callback, :after_find)
          end

          if object.respond_to_without_attributes?(:after_initialize)
            object.send(:callback, :after_initialize)
          end

          object      
        end
      end
    end
  end
end