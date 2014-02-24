module SingularResource
  module Strategies
    module AssignAttributes

      def attributes
        raise 'Implement in submodule'
      end

      def assign_attributes?
        !get? && !delete? && attributes.present?
      end

      def resource
        super.tap do |r|
          r.attributes = attributes if r && assign_attributes?
        end
      end
    end
  end
end
