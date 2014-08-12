require 'spec_helper'
require 'resourcerer/strategies/strong_parameters_strategy'
require 'active_support/core_ext'

describe Resourcerer::Strategies::StrongParametersStrategy do
  describe "#assign_attributes?" do
    Given(:inflector) do
      double("Inflector", param_key: 'model')
    end
    Given(:plural) { false }
    Given(:request) { double('request', get?: true) }
    Given(:params) { {} }
    Given(:controller) { double('controller', params: params, request: request) }
    Given(:options) { {} }
    Given(:strategy) { described_class.new(controller, :model, options) }

    When(:assign) { strategy.assign_attributes? }

    Given do
      strategy.inflector = inflector
    end

    context "when the resource is a collection (plural)" do
      Given(:plural) { true }
      Then { !assign }
    end

    context "for a get request" do
      Given(:request) { double('request', get?: true, delete?: false) }
      Then { !assign }
    end

    context "for a delete request" do
      Given(:request) { double('request', delete?: true, get?: false) }
      Then { !assign }
    end

    context "for a post/put/patch request" do
      Given(:request) { double('request', get?: false, delete?: false) }

      context "and the :attributes_method option is set" do
        Given(:options) { { attributes_method: :my_attributes } }

        context "and the attributes params are present" do
          Given do
            allow(controller).to receive(:my_attributes).and_return(results)
          end
          Given(:params) { { 'model' => results } }
          Given(:results) { { hello: "there" } }
          Then { assign }
        end

        context "and the attributes params are not present" do
          Given do
            allow(controller).to receive(:my_attributes).and_return(results)
          end
          Given(:params) { { 'other_model' => results } }
          Given(:results) { { hello: "there" } }
          Then { !assign }
        end

        context "and sending the attributes method returns a blank value" do
          Given(:results) { {} }
          Then { !assign }
        end
      end

      context "and the :attributes option is not set" do
        Then { !assign }
      end
    end
  end
end
