require 'spec_helper'
require 'resourcerer/strategies/strong_parameters_strategy'
require 'active_support/core_ext'

describe Resourcerer::Strategies::StrongParametersStrategy do
  describe "#assign_attributes?" do
    let(:inflector) do
      double("Inflector", param_key: 'model')
    end
    let(:plural) { false }
    let(:request) { double('request', :get? => true) }
    let(:params) { {} }
    let(:controller) { double('controller', :params => params, :request => request) }
    let(:options) { {} }
    let(:strategy) { described_class.new(controller, :model, options) }

    subject { strategy.assign_attributes? }

    before do
      strategy.inflector = inflector
    end

    context "when the resource is a collection (plural)" do
      let(:plural) { true }
      it { should be_false }
    end

    context "for a get request" do
      let(:request) { double('request', :get? => true, :delete? => false) }
      it { should be_false }
    end

    context "for a delete request" do
      let(:request) { double('request', :delete? => true, :get? => false) }
      it { should be_false }
    end

    context "for a post/put/patch request" do
      let(:request) { double('request', :get? => false, :delete? => false) }

      context "and the :attributes_method option is set" do
        let(:options) { { :attributes_method => :my_attributes } }

        context "and the attributes params are present" do
          before do
            controller.stub(:my_attributes).and_return(results)
          end
          let(:params) { { 'model' => results } }
          let(:results) { { :hello => "there" } }
          it { should be_true }
        end

        context "and the attributes params are not present" do
          before do
            controller.stub(:my_attributes).and_return(results)
          end
          let(:params) { { 'other_model' => results } }
          let(:results) { { :hello => "there" } }
          it { should be_false }
        end

        context "and sending the attributes method returns a blank value" do
          let(:results) { {} }
          it { should be_false }
        end
      end

      context "and the :attributes option is not set" do
        it { should be_false }
      end
    end
  end
end
