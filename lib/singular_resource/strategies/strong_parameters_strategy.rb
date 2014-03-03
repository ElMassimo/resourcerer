require 'singular_resource/strategies/mongoid_strategy'
require 'singular_resource/strategies/assign_from_method_eager'

module SingularResource
  module Strategies
    class StrongParametersStrategy < MongoidStrategy
      include Strategies::AssignFromMethodEager
    end
  end
end
