module FatJam
  module ActsAsRevisable
    class Options      
      def initialize(*options, &block)
        @options = options.extract_options!
        instance_eval(&block) if block_given?
      end

      def method_missing(key, *args)
        return (@options[key.to_s.gsub(/\?$/, '').to_sym].eql?(true)) if key.to_s.match(/\?$/)
        if args.blank?
          @options[key.to_sym]
        else
          @options[key.to_sym] = args.size == 1 ? args.first : args
        end
      end
    end
  end
end
