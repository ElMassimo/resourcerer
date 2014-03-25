require 'resourcerer/inflector'
require 'resourcerer/strategies/strong_parameters_strategy'

module Resourcerer
  class Resource
    attr_reader :name, :strategy, :options, :config_proc

    def self.for(name, options={}, config_proc=nil)
      strategy_class = options.delete(:strategy) || Strategies::StrongParametersStrategy
      new strategy_class, name, options, config_proc
    end

    def initialize(strategy, name, options, config_proc=nil)
      @strategy, @name, @options, @config_proc = strategy, name, options, config_proc
    end

    def call(controller)
      strategy.new(controller, name, options, config_proc).resource
    end
  end
end
