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

      def find_resource(id)
        controller_eval(config.finder, id) || collection.find_by(finder_attribute => id)
      end

      def build_resource
        controller_eval(config.builder) || collection.new
      end

      protected

      def controller_eval(proc, *args)
        controller.instance_exec(*args, &proc) if proc
      end

      def collection
        controller_eval(config.collection) || model
      end
    end
  end
end
