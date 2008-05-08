require 'acts_as_revisable/options'
require 'acts_as_revisable/acts/common'
require 'acts_as_revisable/acts/revision'
require 'acts_as_revisable/acts/revisable'

module FatJam
  REVISABLE_SYSTEM_COLUMNS = %w(revisable_original_id revisable_branched_from_id revisable_number revisable_name revisable_type revisable_current_at revisable_revised_at revisable_deleted_at revisable_is_current)
  REVISABLE_UNREVISABLE_COLUMNS = %w(id type)
  
  module ActsAsRevisable
    def self.included(base)
      base.send(:extend, ClassMethods)
    end
    
    module ClassMethods
      
      #
      def acts_as_revisable(*args, &block)
        revisable_shared_setup(args, block)
        self.send(:include, FatJam::ActsAsRevisable::Revisable)
      end
      
      def acts_as_revision(*args, &block)
        revisable_shared_setup(args, block)
        self.send(:include, FatJam::ActsAsRevisable::Revision)
      end
      
      def revisable_shared_setup(args, block)
        self.send(:include, FatJam::ActsAsRevisable::Common)
        class<<self
          attr_accessor :revisable_options
        end
        options = args.grep(Hash).first || {}
        @revisable_options = FatJam::ActsAsRevisable::Options.new(options, &block)
      end
    end
  end
end
