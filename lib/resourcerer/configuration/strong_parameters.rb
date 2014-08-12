require 'resourcerer/resource_configuration'

module Resourcerer
  module Configuration
    class StrongParameters < ResourceConfiguration

      def permit(attrs)
        options[:permitted_attributes] = attrs
      end
    end
  end
end
