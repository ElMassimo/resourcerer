require 'spec_helper'
require 'active_support/concern'
require 'resourcerer/resource'

describe Resourcerer::Resource do

  Given(:name) { 'person' }
  Given(:config) { double("config") }
  Given(:options) { { strategy: strategy } }
  Given(:resource) { Resourcerer::Resource.for(name, options, config) }

  describe "#for" do
    context "with no block" do
      context "with a custom strategy" do
        Given(:strategy) { double("Custom") }
        Given(:instance) { double("custom") }
        Given {
          expect(Resourcerer::Resource).to receive(:new).with(strategy, name, {}, config).and_return(instance)
        }
        Then { resource == instance }
      end

      context "with no custom strategy" do
        Given(:options) { { model: :other } }
        Given(:instance) { double("custom") }
        Given {
          expect(Resourcerer::Resource).to receive(:new).with(
            Resourcerer::Strategies::StrongParametersStrategy, name, { model: :other }, config).and_return(instance)
        }
        Then { resource == instance }
      end
    end
  end

  describe '#call' do
    Given(:controller) { double("controller") }
    Given(:strategy) { double("Custom") }
    Given(:instance) { double("custom") }
    Given {
      expect(strategy).to receive(:new).with(controller, name, {}, config).and_return(instance)
      expect(instance).to receive(:resource).and_return(:res)
    }
    When(:result) { resource.call(controller) }
    Then { result == :res }
  end
end
