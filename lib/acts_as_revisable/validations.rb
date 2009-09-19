module WithoutScope
  module ActsAsRevisable
    module Validations
      def validates_uniqueness_of(*args)
        options = args.extract_options!
        (options[:scope] ||= []) << :revisable_is_current
        super(*(args << options))
      end
    end
  end
end