require 'spec_helper'
require 'resourcerer/resourceable'
require 'action_controller'
require 'support/block_strategy'

class MyController < ActionController::Base
  include Resourcerer::Resourceable
  resource(:bird, strategy: BlockStrategy) { "Bird: #{rand}" }

  def params
    @params ||= {}
  end
end

describe Resourcerer::Resourceable do

  describe ".resource" do
    Given(:controller) { MyController.new }

    context "defines a getter and setter with the given name" do
      Then { expect(controller).to respond_to(:bird) }
      And  { expect(controller).to respond_to(:bird=) }
    end

    context "prevents the getter and setter methods from being routable" do
      Then { expect(controller.hidden_actions).to include('bird') }
      And  { expect(controller.hidden_actions).to include('bird=') }
    end

    context "caches the value, only loading once" do
      Given!(:resource) do
        controller.class._resources[:bird].tap do |resource|
          expect(resource).to receive(:call).once.with(controller)
        end
      end
      When { 2.times { controller.bird } }
      Then { controller.bird == controller.bird }
    end
  end
end
