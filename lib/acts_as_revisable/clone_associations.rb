# This module encapsulates the methods used by ActsAsRevisable
# for cloning associations from one model to another.
module FatJam
  module ActsAsRevisable
    module CloneAssociations
      class << self
        def clone_associations(from, to)
          return unless from.descends_from_active_record? && to.descends_from_active_record?

          to.revision_cloned_associations.each do |key|
            assoc = from.reflect_on_association(key)
            meth = "clone_#{assoc.macro.to_s}_association"
            meth = "clone_association" unless respond_to? meth
            send(meth, assoc, to)
          end
        end
        
        def clone_association(association, to)
          options = association.options.clone
          options[:foreign_key] ||= "revisable_original_id"
          to.send(association.macro, association.name, options)
        end
        
        def clone_belongs_to_association(association, to)
          to.send(association.macro, association.name, association.options.clone)
        end
        
        def clone_has_many_association(association, to)
          options = association.options.clone
          options[:association_foreign_key] ||= "revisable_original_id"
          to.send(association.macro, association.name, options)
        end
      end
    end
  end
end