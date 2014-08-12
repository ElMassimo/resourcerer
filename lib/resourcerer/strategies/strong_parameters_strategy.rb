require 'resourcerer/strategies/default_strategy'
require 'resourcerer/strategies/assign_from_method'
require 'resourcerer/configuration/strong_parameters'

module Resourcerer
  module Strategies
    class StrongParametersStrategy < DefaultStrategy
      include Strategies::AssignFromMethod

      delegate :permitted_attributes, to: :config

      def attributes
        strong_attributes || super
      end

      protected

      def build_configuration(options)
        Configuration::StrongParameters.new(options)
      end

      private

      def strong_attributes
        if permitted_attributes && params.has_key?(param_key)
          params.require(param_key).permit(*permitted_attributes)
        end
      end
    end
  end
end
