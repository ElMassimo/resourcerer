require 'resourcerer/resourceable'

ActiveSupport.on_load(:action_controller) do
  include Resourcerer::Resourceable
end
