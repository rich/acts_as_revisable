module WithoutScope
  module ActsAsRevisable
    module Deletable
      def self.included(base)        
        base.instance_eval do
          define_callbacks :before_revise_on_destroy, :after_revise_on_destroy
        end
      end
      
      def destroy
        now = Time.current
        
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
        
        return false unless run_callbacks(:before_revise_on_destroy)
        returning(self.save(:without_revision => true)) do
          run_callbacks(:after_revise_on_destroy)
        end
      end
    end
  end
end
