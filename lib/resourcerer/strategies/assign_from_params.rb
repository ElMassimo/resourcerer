require 'resourcerer/strategies/assign_attributes'

module Resourcerer
  module Strategies
    module AssignFromParams
      include AssignAttributes

      def attributes
        super || resource_params
      end
    end
  end
end
