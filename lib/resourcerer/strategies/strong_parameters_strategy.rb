require 'resourcerer/strategies/default_strategy'
require 'resourcerer/strategies/assign_from_method'

module Resourcerer
  module Strategies
    class StrongParametersStrategy < DefaultStrategy
      include Strategies::AssignFromMethod
    end
  end
end
