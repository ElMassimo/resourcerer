require 'resourcerer/resource'
require 'resourcerer/strategies/optional_strategy'
require 'pakiderm'

module Resourcerer
  module Resourceable
    extend ActiveSupport::Concern

    included do
      extend Pakiderm
    end

    def resource(name, options={}, &block)
      Resource.for(name, options.merge(strategy: Strategies::OptionalStrategy), block).call(self)
    end

    module ClassMethods

      def _resources
        @_resources ||= {}
      end

      def resource(name, options={}, &block)
        check_method_available(name)
        _resources[name] = resource = Resource.for(name, options, block)
        define_resource_method(name, resource)
      end

      private

      def define_resource_method(name, resource)
        define_method(name) { resource.call(self) }
        memoize name, assignable: true
        hide_action name, "#{name}="
      end

      def check_method_available(name)
        if self.respond_to?(name.to_sym)
          Kernel.warn "[Resourcerer] Overriding #{name} method."
        end
      end
    end
  end
end
