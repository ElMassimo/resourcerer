# frozen_string_literal: true

module Resourcerer
  # Public: Provides two `resource` helper methods to simplify the definition
  # and usage of Resources.
  #
  # It's also possible to define presets, which can then be reused by providing
  # the :using option when using or defining a Resource.
  module Controller
    extend ActiveSupport::Concern

    included do
      # Public: Available configuration presets that can be used when defining
      # a resource.
      class_attribute :resourcerer_configuration,
        instance_accessor: false, instance_predicate: false
    end

    def resource(name, **options)
      Resource.new(self, name, **options).get(self)
    end

    module ClassMethods
      # Public: Defines a Resource in a controller Class.
      #
      # name - The name of the method to define.
      # **options - See Resource#initialize for details.
      # block - If supplied, the block is executed to provide options.
      #
      # Returns the name of the defined resource.
      def resource(name, **options, &block)
        Resource.define(self, name, **options, &block)
      end

      # Public: Defines a Configuration preset that can be reused in different
      # Resources by providing the :using option.
      #
      # name    - The Symbol name of the configuration preset.
      # options - The Hash of options to define the preset.
      # block   - If supplied, the block is executed to provide options.
      #
      # Returns a Hash with all the resource configurations.
      def resourcerer_config(name, **options, &block)
        self.resourcerer_configuration = (resourcerer_configuration || {}).merge(
          name => Configuration.new(options, &block)
        )
      end
    end
  end
end
