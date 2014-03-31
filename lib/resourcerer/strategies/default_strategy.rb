require 'resourcerer/strategy'
require 'active_support/core_ext/module/delegation'

module Resourcerer
  module Strategies
    class DefaultStrategy < Strategy
      delegate :get?, :delete?, to: :request

      def resource
        if id
          find_resource(id)
        else
          build_resource
        end
      end

      def id
        @id ||= params[finder_param] || params[finder_attribute]
      end

      def finder_param
        config.finder_param || inflector.finder_param
      end

      def find_resource(id)
        controller_eval(config.finder, id) || model.find_by(finder_attribute => id)
      end

      def build_resource
        controller_eval(config.builder) || model.new
      end

      protected

      def controller_eval(proc, *args)
        controller.instance_exec(*args, &proc) if proc
      end
    end
  end
end
