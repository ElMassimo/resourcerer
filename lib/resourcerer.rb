# frozen_string_literal: true

require 'resourcerer/version'
require 'active_support/all'

module Resourcerer
  autoload :Configuration, 'resourcerer/configuration'
  autoload :Controller,    'resourcerer/controller'
  autoload :Resource,      'resourcerer/resource'

  ActiveSupport.on_load :action_controller do
    include Controller
  end
end
