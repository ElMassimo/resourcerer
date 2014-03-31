module Resourcerer
  module Strategies
    module AssignAttributes

      def resource
        super.tap do |r|
          assign_attributes(r) if r && assign_attributes?
        end
      end

      def attributes
        @attributes ||= controller_eval(config.attributes)
      end

      def assign_attributes?
        !get? && !delete? && attributes.present?
      end

      def assign_attributes(resource)
        resource.attributes = attributes
      end

      def resource_params
        params[param_key]
      end

      private

      def param_key
        config.param_key || inflector.param_key
      end
    end
  end
end
