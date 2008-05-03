module FatJam
  module ActsAsRevisable
    class Options
      def initialize(options, &block)
        @options = options
        instance_eval(&block) if block_given?
      end

      def method_missing(key, *args)
        if args.blank?
          @options[key.to_sym]
        else
          @options[key.to_sym] = args.size == 1 ? args.first : args
        end
      end
    end
  end
end
