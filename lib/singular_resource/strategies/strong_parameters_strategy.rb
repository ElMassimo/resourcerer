require 'singular_resource/strategies/mongoid_strategy'
require 'singular_resource/strategies/assign_from_method'

module SingularResource
  module Strategies
    class StrongParametersStrategy < MongoidStrategy
      include Strategies::AssignFromMethod
    end
  end
end
