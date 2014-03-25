require 'active_support/inflector'
require 'active_support/core_ext/string'
require 'active_model/naming'

module Resourcerer
  class Inflector
    attr_reader :original, :model, :finder_attribute

    def initialize(name, model, finder_attribute=:id)
      @original, @model, @finder_attribute = name.to_s, model, finder_attribute
    end

    alias name original

    def model_name
      @model_name ||= model.model_name
    rescue
      @model_name = ActiveModel::Name.new(model)
    end

    def param_key
      model_name.param_key
    end

    def finder_param
      "#{model_name.singular}_#{finder_attribute}"
    end

    def self.class_for(name)
      name.to_s.split('::').map(&:classify).join('::').constantize
    end
  end
end
