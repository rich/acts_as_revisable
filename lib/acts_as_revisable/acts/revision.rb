require 'acts_as_revisable/clone_associations'

module FatJam
  module ActsAsRevisable
    # This module is mixed into the revision classes.
    # 
    # ==== Callbacks
    # 
    # * +before_restore+ is called on the revision class before it is 
    #   restored as the current record.
    # * +after_restore+ is called on the revision class after it is 
    #   restored as the current record.
    module Revision
      def self.included(base) #:nodoc:
        base.send(:extend, ClassMethods)
        
        class << base
          attr_accessor :revisable_revisable_class, :revisable_cloned_associations
        end
        
        base.instance_eval do
          set_table_name(revisable_class.table_name)
          acts_as_scoped_model :find => {:conditions => {:revisable_is_current => false}}
          
          CloneAssociations.clone_associations(revisable_class, self)
        
          define_callbacks :before_restore, :after_restore
          before_create :revision_setup
          after_create :grab_my_branches
          
          [:current_revision, revisable_association_name.to_sym].each do |a|
            belongs_to a, :class_name => revisable_class_name, :foreign_key => :revisable_original_id
          end
          
          [[:ancestors, "<"], [:descendants, ">"]].each do |a|
            # Jumping through hoops here to try and make sure the
            # :finder_sql is cross-database compatible. :finder_sql
            # in a plugin is evil but, I see no other option.
            has_many a.first, :class_name => revision_class_name, :finder_sql => "select * from #{quoted_table_name} where #{quote_bound_value(:revisable_original_id)} = \#{revisable_original_id} and #{quote_bound_value(:revisable_number)} #{a.last} \#{revisable_number} and #{quote_bound_value(:revisable_is_current)} = #{quote_value(false)} order by #{quote_bound_value(:revisable_number)} #{(a.last.eql?("<") ? "DESC" : "ASC")}"
          end
        end
      end
      
      def find_revision(*args)
        current_revision.find_revision(*args)
      end
      
      # Return the revision prior to this one.
      def previous_revision
        self.class.find(:first, :conditions => {:revisable_original_id => revisable_original_id, :revisable_number => revisable_number - 1})
      end
      
      # Return the revision after this one.
      def next_revision
        self.class.find(:first, :conditions => {:revisable_original_id => revisable_original_id, :revisable_number => revisable_number + 1})
      end
      
      # Setter for revisable_name just to make external API more pleasant.
      def revision_name=(val) #:nodoc:
        self[:revisable_name] = val
      end
    
      # Accessor for revisable_name just to make external API more pleasant.
      def revision_name #:nodoc:
        self[:revisable_name]
      end
      
      # Sets some initial values for a new revision.
      def revision_setup #:nodoc:
        now = Time.now
        prev = current_revision.revisions.first
        prev.update_attribute(:revisable_revised_at, now) if prev
        self[:revisable_current_at] = now + 1.second
        self[:revisable_is_current] = false
        self[:revisable_branched_from_id] = current_revision[:revisable_branched_from_id]
        self[:revisable_type] = current_revision[:type]
        self[:revisable_number] = (self.class.maximum(:revisable_number, :conditions => {:revisable_original_id => self[:revisable_original_id]}) || 0) + 1
      end
      
      def grab_my_branches
        self.class.revisable_class.update_all(["revisable_branched_from_id = ?", self[:id]], ["revisable_branched_from_id = ?", self[:revisable_original_id]])
      end
      
      def from_revisable
        current_revision.for_revision
      end
      
      def reverting_from
        from_revisable[:reverting_from]
      end
      
      def reverting_from=(val)
        from_revisable[:reverting_from] = val
      end

      def reverting_to
        from_revisable[:reverting_to]
      end
      
      def reverting_to=(val)
        from_revisable[:reverting_to] = val
      end

      module ClassMethods
        # Returns the +revisable_class_name+ as configured in
        # +acts_as_revisable+.
        def revisable_class_name #:nodoc:
          self.revisable_options.revisable_class_name || self.class_name.gsub(/Revision/, '')
        end
      
        # Returns the actual +Revisable+ class based on the 
        # #revisable_class_name.
        def revisable_class #:nodoc:
          self.revisable_revisable_class ||= revisable_class_name.constantize
        end
        
        # Returns the revision_class which in this case is simply +self+.
        def revision_class #:nodoc:
          self
        end
        
        def revision_class_name #:nodoc:
          self.name
        end
        
        # Returns the name of the association acts_as_revision
        # creates.
        def revisable_association_name #:nodoc:
          revisable_class_name.downcase
        end
        
        # Returns an array of the associations that should be cloned.
        def revision_cloned_associations #:nodoc:
          clone_associations = self.revisable_options.clone_associations
        
          self.revisable_cloned_associations ||= if clone_associations.blank?
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