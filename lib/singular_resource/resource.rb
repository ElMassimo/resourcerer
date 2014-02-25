require 'singular_resource/finder_strategizer'
require 'singular_resource/configuration'
require 'simple_memoizer'

module SingularResource
  module Resource
    extend ActiveSupport::Concern
    include SimpleMemoizer

    included do
      class_attribute :_singular_configurations
      self._singular_configurations ||= Hash.new(Configuration.new)
    end

    module ClassMethods
      def singular_configuration(name=:default,&block)
        self._singular_configurations = _singular_configurations.merge(name => Configuration.new(&block))
      end

      def singular_resource(name, options={})
        enforce_method_name_not_used!(name)

        config = options[:config] || :default
        options = _singular_configurations[config].merge(options)

        _resource_finders[name] = finder = FinderStrategizer.strategy_for(name, options)

        define_resource_method(name, finder)
      end

      private

      def _resource_finders
        @_resource_finders ||= {}
      end

      def define_resource_method(name, finder)
        define_method(name) do
          finder.call(self)
        end
        memoize name
        hide_action name
      end

      def enforce_method_name_not_used!(name)
        if ActionController::Base.instance_methods.include?(name.to_sym)
          Kernel.abort "[ERROR] You are adding a singular resource by the `#{name}` method, " \
            "which overrides an existing ActionController method of the same name. " \
            "Consider a different resource name\n" \
            "#{caller.first}"
        end
      end
    end
  end
end
