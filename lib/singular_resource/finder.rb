require 'singular_resource/inflector'

module SingularResource
  class Finder
    attr_accessor :name, :strategy, :options

    def initialize(name, strategy, options)
      self.name = name.to_s
      self.strategy = strategy
      self.options = options
    end

    def call(controller)
      strategy.new(controller, name, options).resource
    end
  end
end
