module FatJam
  module ActsAsRevisable
    # This class provides for a flexible method of setting
    # options and querying them. This is especially useful
    # for giving users flexibility when using your plugin.
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
