require 'singular_resource/strategies/mongoid_strategy'
require 'singular_resource/strategies/assign_from_params'

module SingularResource
  class EagerAttributesStrategy < MongoidStrategy
    include Strategies::AssignFromParams
  end
end
