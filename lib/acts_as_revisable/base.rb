require 'acts_as_revisable/options'
require 'acts_as_revisable/acts/common'
require 'acts_as_revisable/acts/revision'
require 'acts_as_revisable/acts/revisable'
require 'acts_as_revisable/acts/deletable'

module FatJam
  # define the columns used internall by AAR
  REVISABLE_SYSTEM_COLUMNS = %w(revisable_original_id revisable_branched_from_id revisable_number revisable_name revisable_type revisable_current_at revisable_revised_at revisable_deleted_at revisable_is_current)
  
  # define the ActiveRecord magic columns that should not be monitored
  REVISABLE_UNREVISABLE_COLUMNS = %w(id type created_at updated_at)
  
  module ActsAsRevisable
    def self.included(base)
      base.send(:extend, ClassMethods)
    end
    
    module ClassMethods
      
      # This +acts_as+ extension provides for making a model the 
      # revisable model in an acts_as_revisable pair.
      def acts_as_revisable(*args, &block)
        revisable_shared_setup(args, block)
        self.send(:include, Revisable)
        self.send(:include, Deletable) if self.revisable_options.on_delete == :revise
      end
      
      # This +acts_as+ extension provides for making a model the 
      # revision model in an acts_as_revisable pair.
      def acts_as_revision(*args, &block)
        revisable_shared_setup(args, block)
        self.send(:include, Revision)        
      end
      
      private
        # Performs the setup needed for both kinds of acts_as_revisable
        # models.
        def revisable_shared_setup(args, block)
          class << self
            attr_accessor :revisable_options
          end
          options = args.extract_options!
          self.revisable_options = Options.new(options, &block)
          
          self.send(:include, Common)
        end
    end
  end
end
