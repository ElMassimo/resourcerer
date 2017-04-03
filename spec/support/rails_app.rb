require "action_controller"
require "rails"

def request_params(params)
  { params: params, **params }
end

module Rails
  class App
    def env_config; {} end

    def routes
      @routes ||= ActionDispatch::Routing::RouteSet.new.tap do |routes|
        routes.draw do
          resources :guitars
        end
      end
    end
  end

  def self.root
    ''
  end

  def self.application
    @app ||= App.new
  end
end

class Guitar
  attr_accessor :name
  def initialize(options = {})
    options.each { |k, v| self.public_send("#{k}=", v) }
  end
end

class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers
end

class GuitarsController < ApplicationController
  resource :guitar
  resource(:guitar?, model: Guitar, find: -> (id, model) { !!model.find(id) })
  resource(:guitars) do
    build { Guitar.all }
  end

  # To simplify testing.
  public :guitars, :guitar, :guitar?

  %i(index show edit new create update).each do |action|
    define_method action do
      head :ok
    end
  end

  def guitar_params
    params.require(:guitar).permit(:name)
  end
end
