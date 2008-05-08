module FatJam
  module ActsAsRevisable
    module CloneAssociations
      class << self
        def clone(from, to)
          return unless from.is_a?(ActiveRecord::Base) && to.is_a?(ActiveRecord::Base)
          
          from.revision_cloned_associations.each do |key|
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
      end
    end
  end
end