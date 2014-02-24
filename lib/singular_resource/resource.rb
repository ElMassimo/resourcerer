require 'singular_resource/strategizer'
require 'singular_resource/configuration'

module SingularResource
  module Resource
    def self.extended(base)
      base.class_eval do
        class_attribute :_singular_configurations
        self._singular_configurations ||= Hash.new(Configuration.new)

        def _singular_resources
          @_singular_resources ||= {}
        end
        hide_action :_singular_resources

        protected_instance_variables.push("@_singular_resources")
      end
    end

    def _resource_finders
      @_resource_finders ||= {}
    end

    def singular_configuration(name=:default,&block)
      self._singular_configurations = _singular_configurations.merge(name => Configuration.new(&block))
    end

    def singular_resource(name, options={})
      if ActionController::Base.instance_methods.include?(name.to_sym)
        Kernel.abort "[ERROR] You are adding a singular resource by the `#{name}` method, " \
          "which overrides an existing ActionController method of the same name. " \
          "Consider a different resource name\n" \
          "#{caller.first}"
      end

      config = options[:config] || :default
      options = _singular_configurations[config].merge(options)

      _resource_finders[name] = finder = FinderStrategizer.strategy_for(name, options)

      define_resource_methods(name, finder)
    end

    private

    def define_resource_methods(name, finder)
      define_method(name) do
        return _singular_resources[name] if _singular_resources.has_key?(name)
        _singular_resources[name] = finder.call(self)
      end
      private name
      hide_action name

      define_method("#{name}=") do |value|
        _singular_resources[name] = value
      end
      hide_action "#{name}="
    end
  end
end
