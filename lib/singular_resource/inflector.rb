require 'active_support/inflector'
require 'active_support/core_ext/string'

module SingularResource
  class Inflector
    attr_reader :original, :model

    def initialize(name, model)
      @original = name.to_s
      @model = model
    end

    alias name original

    def param_key
      model.name.param_key
    end

    def parameter
      "#{model.name.singularize}_id"
    end

    def self.class_for(name)
      name.to_s.classify.constantize
    end
  end
end
