module FatJam
  module ActsAsRevisable
    module Revision
      def self.included(base)
        base.send(:extend, ClassMethods)
      
        base.instance_eval do
          set_table_name(revisable_class.table_name)
          acts_as_scoped_model :find => {:conditions => {:revisable_is_current => false}}
          revision_cloned_associations.each do |key|
            assoc = revisable_class.reflect_on_association(key)
            options = assoc.options.clone
            options[:foreign_key] ||= "revisable_original_id"
            send(assoc.macro, assoc.name, options)
          end
        
          define_callbacks :before_restore, :after_restore
        
          belongs_to :current_revision, :class_name => revisable_class_name, :foreign_key => :revisable_original_id
          belongs_to revisable_class_name.downcase.to_sym, :class_name  => revisable_class_name, :foreign_key => :revisable_original_id
          
          before_create :revision_setup
        end
      end
    
      def revision_name=(val)
        self[:revisable_name] = val
      end
    
      def revision_name
        self[:revisable_name]
      end
    
      def revision_number
        self[:revisable_number]
      end
      
      def revision_setup
        now = Time.now
        prev = current_revision.revisions.first
        prev.update_attribute(:revisable_revised_at, now) if prev
        self[:revisable_current_at] = now + 1.second
        self[:revisable_is_current] = false
        self[:revisable_branched_from_id] = current_revision[:revisable_branched_from_id]
        self[:revisable_type] = current_revision[:type]
        self[:revisable_number] = (self.class.maximum(:revisable_number, :conditions => {:revisable_original_id => self[:revisable_original_id]}) || 0) + 1
      end
            
      module ClassMethods
        def revisable_class_name
          self.revisable_options.revisable_class_name || self.class_name.gsub(/Revision/, '')
        end
      
        def revisable_class
          @revisable_class ||= revisable_class_name.constantize
        end
        
        def revision_class
          self
        end
        
        def revision_cloned_associations
          clone_associations = self.revisable_options.clone_associations
        
          @aa_revisable_cloned_associations ||= if clone_associations.blank?
            []
          elsif clone_associations.eql? :all
            revisable_class.reflect_on_all_associations.map(&:name)
          elsif clone_associations.is_a? [].class
            clone_associations
          elsif clone_associations[:only]
            [clone_associations[:only]].flatten
          elsif clone_associations[:except]
            revisable_class.reflect_on_all_associations.map(&:name) - [clone_associations[:except]].flatten
          end        
        end
      end
    end
  end
end