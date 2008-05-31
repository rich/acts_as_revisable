module FatJam
  module ActsAsRevisable
    module Common
      def self.included(base) #:nodoc:
        base.send(:extend, ClassMethods)
        
        base.class_inheritable_hash :revisable_after_callback_blocks
        base.revisable_after_callback_blocks = {}
        
        base.class_inheritable_hash :revisable_current_states
        base.revisable_current_states = {}
        
        class << base
          alias_method_chain :instantiate, :revisable
        end

        base.instance_eval do
          define_callbacks :before_branch, :after_branch      
          has_many :branches, :class_name => base.class_name, :foreign_key => :revisable_branched_from_id
          belongs_to :branch_source, :class_name => base.class_name, :foreign_key => :revisable_branched_from_id
          after_save :execute_blocks_after_save
        end
        base.alias_method_chain :branch_source, :open_scope  
      end
      
      def execute_blocks_after_save
        return unless revisable_after_callback_blocks[:save]
        revisable_after_callback_blocks[:save].each do |block|
          block.call
        end
        revisable_after_callback_blocks.delete(:save)
      end
      
      def execute_after(key, &block)
        return unless block_given?
        revisable_after_callback_blocks[key] ||= []
        revisable_after_callback_blocks[key] << block
      end
      
      def branch_source_with_open_scope(*args, &block) #:nodoc:
        self.class.without_model_scope do
          branch_source_without_open_scope(*args, &block)
        end
      end
      
      # Branch the +Revisable+ or +Revision+ and return the new 
      # +revisable+ instance. The instance has not been saved yet.
      # 
      # This method triggers three callbacks:
      # * +before_branch+ is called on the +Revisable+ or +Revision+ that is 
      #   being branched
      # * +after_branch+ is called on the +Revisable+ or +Revision+ that is 
      #   being branched
      # * +after_branch_created+ is called on the newly created +Revisable+ instance.
      def branch(*args, &block)
        is_branching!
        
        unless run_callbacks(:before_branch) { |r, o| r == false}
          raise ActiveRecord::RecordNotSaved
        end

        options = args.extract_options!
        options[:revisable_branched_from_id] = self.id
        self.class.column_names.each do |col|
          next unless self.class.revisable_should_clone_column? col
          options[col.to_sym] = self[col] unless options.has_key?(col.to_sym)
        end
        
        br = self.class.revisable_class.new(options)
        br.is_branching!
        
        br.execute_after(:save) do
          begin
            run_callbacks(:after_branch)
            br.run_callbacks(:after_branch_created)
          ensure
            br.is_branching!(false)
            is_branching!(false)
          end
        end
        
        block.call(br) if block_given?
        
        br
      end
      
      # Same as #branch except it calls #save! on the new +Revisable+ instance.
      def branch!(*args)
        branch(*args) do |br|
          br.save!
        end
      end
      
      def is_branching!(value=true)
        set_revisable_state(:branching, value)
      end
      
      def is_branching?
        get_revisable_state(:branching)
      end
      
      # When called on a +Revision+ it returns the original id. When
      # called on a +Revisable+ it returns the id.
      def original_id
        self[:revisable_original_id] || self[:id]
      end
      
      def set_revisable_state(type, value)
        key = self.read_attribute(self.class.primary_key)
        key = object_id if key.nil?
        revisable_current_states[type] ||= {}
        revisable_current_states[type][key] = value
        revisable_current_states[type].delete(key) unless value
      end
      
      def get_revisable_state(type)
        key = self.read_attribute(self.class.primary_key)
        revisable_current_states[type] ||= {}
        revisable_current_states[type][key] || revisable_current_states[type][object_id] || false
      end
      
      module ClassMethods      
        def revisable_should_clone_column?(col)
          return false if (REVISABLE_SYSTEM_COLUMNS + REVISABLE_UNREVISABLE_COLUMNS).member? col
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