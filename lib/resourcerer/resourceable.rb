require 'resourcerer/resource'
require 'simple_memoizer'

module Resourcerer
  module Resourceable
    extend ActiveSupport::Concern
    include SimpleMemoizer

    module ClassMethods

      def _resources
        @_resources ||= {}
      end

      def resource(name, options={}, &block)
        check_method_available!(name)
        _resources[name] = resource = Resource.for(name, options, block)
        define_resource_method(name, resource)
      end

      private

      def define_resource_method(name, resource)
        define_method(name) { resource.call(self) }
        memoize name
        hide_action name, "#{name}="
      end

      def check_method_available!(name)
        if self.respond_to?(name.to_sym)
          Kernel.abort "[ERROR] You are adding a singular resource by the `#{name}` method, " \
            "which overrides an existing method of the same name. " \
            "Consider a different resource name\n" \
            "#{caller.first}"
        end
      end
    end
  end
end
