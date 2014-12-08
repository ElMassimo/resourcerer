# This is the base class that is intended to build the DSL for Resourcer
module Resourcerer
  class ResourceConfiguration

    attr_reader :options

    def initialize(options={})
      @options = options || {}
    end

    def method_missing(name, *args)
      super if args.size > 1
      define_option_method(name)
      send(name, args.first)
    end

    def define_option_method(name)
      # We chose not caching the value inside the method because it's more flexible
      self.class.class_eval <<-EVAL
        def #{name}(value=nil)
          options[:#{name}] = value if value
          options[:#{name}]
        end
      EVAL
    end

    # DSL

    def find(&block)
      options[:finder] = block
    end

    def build(&block)
      options[:builder] = block
    end

    def assign(&block)
      options[:attributes] = block
    end

    def collection(proc=nil, &block)
      if proc = (proc || block)
        options[:collection] = proc
      else
        options[:collection]
      end
    end
  end
end
