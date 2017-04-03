require 'spec_helper'

RSpec.describe Resourcerer::Controller do
  module Awesome
    class Thing; end
  end

  Given(:controller_klass) { Class.new { include Resourcerer::Controller } }
  Given(:params) { double('Params', :[] => nil) }
  Given(:request) { double('Request', get?: false) }
  Given(:controller) { controller_klass.new }
  Given(:thing) { double('Awesome::Thing') }

  def controller_thing
    controller.send(:thing)
  end

  Given {
    allow(controller).to receive(:action_name).and_return('edit')
    allow(controller).to receive(:params).and_return(params)
    allow(controller).to receive(:request).and_return(request)
  }

  delegate :resource, :resourcerer_config, to: :controller_klass

  context 'permit' do
    Given(:attrs) {{ name: 'Max', email: 'max@email.com' }}
    Given(:fields) { [:name, :email] }

    context 'allows to specify permitted attributes' do
      Given {
        require 'active_model'
        expect(params).to receive(:require).with(:awesome_thing).and_return(params)
        expect(params).to receive(:permit).with(*fields).and_return(attrs)
        expect(Awesome::Thing).to receive(:new).with(attrs).and_return(thing)
      }

      after {
        ActiveModel.send(:remove_const, 'Name')
      }

      context 'permit using a proc' do
        When { resource :thing, model: Awesome::Thing, permit: fields }
        Then { controller_thing == thing }
      end
    end
  end
end
