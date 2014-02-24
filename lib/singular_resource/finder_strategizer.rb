require 'singular_resource/finder'
require 'singular_resource/strategies/strong_parameters_strategy'

module SingularResource
  class FinderStrategizer

    def self.strategy_for(name, options={})
      strategy_class = options.delete(:strategy) || Strategies::StrongParametersStrategy
      options = options.merge(name: name)
      Finder.new(name, strategy_class, options)
    end
  end
end
