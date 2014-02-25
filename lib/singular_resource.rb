require 'singular_resource/resource'
require 'singular_resource/error'

ActiveSupport.on_load(:action_controller) do
  include SingularResource::Resource
end
