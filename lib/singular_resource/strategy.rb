require 'singular_resource/inflector'

module SingularResource
  class Strategy
    attr_reader :controller, :name, :options
    attr_writer :model, :inflector

    def initialize(controller, name, options={})
      @controller, @name, @options = controller, name.to_s, options
    end

    def resource
      raise 'Implement in subclass'
    end

    protected

    def inflector
      @inflector ||= SingularResource::Inflector.new(name, model)
    end

    def model
      @model ||= case options[:model]
                 when Class, Module
                   options[:model]
                 else
                   name_or_model = options[:model] || name
                   inflector.class_for(name_or_model)
                 end
    end

    def params
      controller.params
    end

    def request
      controller.request
    end
  end
end
