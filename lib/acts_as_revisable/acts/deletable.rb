module WithoutScope
  module ActsAsRevisable
    module Deletable
      def self.included(base)        
      end
      
      def destroy
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