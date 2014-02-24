require 'singular_resource/strategies/assign_attributes'

module SingularResource
  module Strategies
    module AssignFromMethod
      include AssignAttributes

      def attributes
        @attributes ||= method_attributes || {}
      end

      private

      def method_attributes
        controller.send(options[:attributes]) if options[:attributes]
      end
    end
  end
end
