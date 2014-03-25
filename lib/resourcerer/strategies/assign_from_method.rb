require 'resourcerer/strategies/assign_attributes'

module Resourcerer
  module Strategies
    module AssignFromMethod
      include AssignAttributes

      def attributes
        super || attributes_from_method
      end

      private

      def attributes_from_method
        controller.send(attributes_method) if resource_params
      end

      def attributes_method
        config.attributes_method || "#{name}_params"
      end
    end
  end
end
