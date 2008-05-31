module FatJam
  module ActsAsRevisable
    module Deletable
      def self.included(base)        
        base.instance_eval do
          alias_method_chain :destroy, :revisable
        end
      end
      
      def destroy_with_revisable
        now = Time.now
        
        prev = self.revisions.first
        self.revisable_deleted_at = now
        self.revisable_is_current = false
                
        self.revisable_current_at = if prev
          prev.update_attribute(:revisable_revised_at, now)
          prev.revisable_revised_at + 1.second
        else
          self.created_at
        end
        
        self.revisable_revised_at = self.revisable_deleted_at
        self.save(:without_revision => true)
      end
    end
  end
end