require 'resourcerer/strategies/default_strategy'

module Resourcerer
  module Strategies
    class OptionalStrategy < DefaultStrategy

      def resource
        find_resource(id) if id
      end

      def find_resource(id)
        if config.optional
          model.where(finder_attribute => id).first
        else
          model.find_by(finder_attribute => id)
        end
      end

      def id
        @id ||= params[finder_param]
      end
    end
  end
end
