require 'resourcerer/inflector'
require 'resourcerer/resource_configuration'

module Resourcerer
  class Strategy
    attr_reader :controller, :name, :options, :config_proc
    attr_writer :model, :inflector

    def initialize(controller, name, options={}, config_proc=nil)
      @controller, @name, @options, @config_proc = controller, name.to_s, options, config_proc
    end

    def resource
      raise 'Implement in subclass'
    end

    protected

    # Subclasses may provide an extended version of ResourceConfiguration to extend the DSL
    def build_configuration(options)
      ResourceConfiguration.new(options)
    end

    def config
      @config ||= build_configuration(options).tap do |rc|
        rc.instance_eval(&config_proc) if config_proc # This evaluates the configuration in the DSL block
      end
    end

    def inflector
      @inflector ||= Resourcerer::Inflector.new(name, model, finder_attribute)
    end

    def model
      @model ||= case config.model
        when Class, Module
          config.model
        else
          Resourcerer::Inflector.class_for(config.model || name)
      end
    end

    def finder_attribute
      config.find_by || :id
    end

    def params
      controller.params
    end

    def request
      controller.request
    end
  end
end
