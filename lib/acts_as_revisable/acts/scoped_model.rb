module FatJam
  module ActsAsScopedModel
    def self.included(base)
      base.send(:extend, ClassMethods)
    end
    
    module ClassMethods
      SCOPED_METHODS = %w(construct_calculation_sql construct_finder_sql update_all delete_all destroy_all).freeze
      
      def call_method_with_static_scope(meth, args)
        return send(meth, *args) unless self.scoped_model_enabled
        
        with_scope(self.scoped_model_static_scope) do
          send(meth, *args)
        end
      end
      
      SCOPED_METHODS.each do |m|
        module_eval <<-EVAL
          def #{m}_with_static_scope(*args)
            call_method_with_static_scope(:#{m}_without_static_scope, args)
          end
        EVAL
      end
            
      def without_model_scope
        return unless block_given?
        
        begin
          self.scoped_model_enabled = false
          rv = yield
        ensure
          self.scoped_model_enabled = true
        end
        
        rv
      end
      
      def acts_as_scoped_model(*args)
        class << self
          attr_accessor :scoped_model_static_scope, :scoped_model_enabled   
          SCOPED_METHODS.each do |m|   
            alias_method_chain m.to_sym, :static_scope
          end
        end
        self.scoped_model_enabled = true
        self.scoped_model_static_scope = args.extract_options!
      end
    end
  end
end