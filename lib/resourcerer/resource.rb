# frozen_string_literal: true

module Resourcerer
  # Public: Representation of a model that can be found, built, and assigned
  # attributes.
  class Resource
    attr_reader :name, :options, :controller

    # Public: Defines a Resource and makes it accessible to a controller.
    # For each Resource, a getter and setter is defined in the controller.
    #
    # klass   - The Controller class where the Resource getter will be defined.
    # name    - The name of the generated Resource.
    # options - Config Hash for the new Resource. See Configuration::OPTIONS.
    # block   - If supplied, the block is executed to provide options.
    #
    # Returns nothing.
    def self.define(klass, name, **options, &block)
      resource = new(klass, name, **options, &block)

      klass.instance_eval do
        ivar = "@resourcerer_#{ name.to_s.gsub('?', '_question_mark') }"

        private define_method(name) {
          if instance_variable_defined?(ivar)
            instance_variable_get(ivar)
          else
            instance_variable_set(ivar, resource.clone.get(self))
          end
        }

        private define_method("#{ name }=") { |value|
          instance_variable_set(ivar, value)
        }
      end
    end

    # Public: Initalize a Resource with configuration options.
    #
    # klass       - The Controller class where the Resource is executed.
    # name        - The Symbol name of the Resource instance.
    # options     - Hash of options for the Configuration of the methods.
    # block       - If supplied, the block is executed to provide options.
    #
    # Returns a normalized options Hash.
    def initialize(klass, name, using: [], **options, &block)
      @name = name
      @options = Configuration.new(options, &block).options

      Array.wrap(using).each do |preset|
        klass.resourcerer_configuration.fetch(preset).apply(options)
      end
    end

    # Public: Returns an object using the specified Resource configuration.
    # The object will be built or found, and might be assigned attributes.
    #
    # controller - The instance of the controller where the resource is fetched.
    #
    # Returns the resource object.
    def get(controller)
      @controller = controller
      collection = call(:collection, call(:model))

      if id = call(:id)
        call(:find, id, collection)
      else
        call(:build, safe_attrs, collection)
      end.tap do |object|
        call(:assign, object, safe_attrs) if object && call(:assign?, object)
      end
    end

  protected

    # Strategy: A query or table. Designed to be overridden.
    #
    # model - The Class to be scoped or queried.
    #
    # Returns the object collection.
    def collection(model = name.to_s.classify.constantize)
      model
    end

    # Strategy: Converts a name into a standard Class name.
    #
    # Examples
    #   'egg_and_hams'.model # => EggAndHam
    #
    # Returns a standard Class name.
    def model
      options.key?(:collection) ? call(:collection).klass : collection
    end

    # Strategy: Checks controller params to retrieve an id value.
    #
    # Returns the id parameter, if any, or nil.
    def id
      ["#{name}_id", "#{model_name}_id", 'id'].uniq.
        map { |id| controller.params[id] }.find(&:present?)
    end

    # Strategy: Find an object on the supplied scope.
    #
    # id    - The Integer id attribute of the desired object
    # scope - The collection that will be searched.
    #
    # Returns the found object.
    def find(id, collection)
      collection.find(id)
    end

    # Strategy: Builds a new object on the passed-in scope.
    #
    # params - A Hash of attributes for the object to-be built.
    # scope  - The collection where the object will be built from.
    #
    # Returns the new object.
    def build(attrs, collection)
      collection.new(attrs)
    end

    # Strategy: Assigns attributes to the found or built object.
    #
    # attrs  - A Hash of attributes to be assigned.
    # object - The Resource object.
    #
    # Returns nothing.
    def assign(object, attrs)
      object.assign_attributes(attrs)
    end

    # Strategy: Whether the attributes should be assigned.
    #
    # object - The Resource object.
    #
    # Returns true if attributes should be assigned, or false otherwise.
    def assign?(object)
      controller.action_name == 'update'
    end

    # Strategy: Get all the parameters of the current request.
    #
    # Returns the controller's parameters for the current request.
    def attrs
      if options[:permit]
        controller.params.require(model_name).permit(*call(:permit))
      else
        params_method = "#{name}_params"
        if controller.respond_to?(params_method, true)
          controller.send(params_method)
        else
          {}
        end
      end
    end

  private

    # Internal: Avoids assigning attributes when the request is a GET request.
    #
    # Returns the controller's parameters for the current request.
    def safe_attrs
      controller.request.get? ? {} : call(:attrs)
    end

    # Internal: Returns a Symbol name that follows the parameter convention.
    def model_name
      @model_name ||= if defined?(ActiveModel::Name)
        ActiveModel::Name.new(call(:model)).param_key
      else
        call(:model).name.underscore
      end.to_sym
    end

    # Internal: Invokes a Proc that was passed as an option, or the default
    # strategy for that function.
    def call(name, *args)
      memoize(name) {
        if options.key?(name)
          execute_option_function(options[name], *args)
        else
          send(name, *args)
        end
      }
    end

    # Internal: Invokes a Proc that was passed as an option. The Proc executes
    # within the context of the controller.
    def execute_option_function(function, *args)
      args = args.first(function.parameters.length)
      controller.instance_exec(*args, &function)
    end

    # Internal: Helper method to perform simple memoization.
    def memoize(name)
      ivar = "@#{ name.to_s.gsub('?', '_question_mark') }"

      if instance_variable_defined?(ivar)
        instance_variable_get(ivar)
      else
        instance_variable_set(ivar, yield)
      end
    end
  end
end
