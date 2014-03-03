require 'singular_resource/strategies/assign_attributes'

module SingularResource
  module Strategies
    module AssignFromMethodEager
      include AssignAttributes

      def attributes
        @attributes ||= method_attributes || {}
      end

      private

      def default_params_method
        "#{name}_params"
      end

      def method_attributes
        controller.send(options[:attributes] || default_params_method) unless options[:attributes] == false
      end
    end
  end
end
