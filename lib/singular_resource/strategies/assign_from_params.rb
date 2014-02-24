require 'singular_resource/strategies/assign_attributes'

module SingularResource
  module Strategies
    module AssignFromParams
      include AssignAttributes

      def attributes
        @attributes ||= params[param_key] || {}
      end

      private

      def param_key
        options[:param_key] || inflector.param_key
      end
    end
  end
end
