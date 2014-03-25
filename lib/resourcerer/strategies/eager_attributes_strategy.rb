require 'resourcerer/strategies/default_strategy'
require 'resourcerer/strategies/assign_from_params'

module Resourcerer
  module Strategies
    class EagerAttributesStrategy < DefaultStrategy
      include Strategies::AssignFromParams
    end
  end
end
