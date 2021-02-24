require 'spec_helper'
require 'support/rails_app'
require 'rspec/rails'

RSpec.describe GuitarsController, type: :controller do
  Given(:guitar) { Guitar.new }

  context 'when a build block is used' do
    Given {
      expect(Guitar).to receive(:all).and_return([guitar])
    }
    When { get :index }
    Then { controller.guitars == [guitar] }
  end

  context 'normal resource' do
    context 'finds model by id' do
      Given {
        expect(Guitar).to receive(:find).with('ES-335').and_return(guitar)
      }
      When { get :show, **request_params(id: 'ES-335') }
      Then { controller.guitar == guitar }
    end

    context 'finds model by guitar_id' do
      Given {
        expect(Guitar).to receive(:find).with('ES-335').and_return(guitar)
      }
      When { get :new, **request_params(guitar_id: 'ES-335') }
      Then { controller.guitar == guitar }
    end

    context 'builds guitar if id is not provided' do
      When { get :new }
      Then { controller.guitar.is_a?(Guitar) }
    end
  end

  context 'when build params are used' do
    When { post :create, **request_params(guitar: { name: 'strat' }) }
    Then { controller.guitar.name == 'strat' }
  end

  context 'when a guitar? with a question mark is exposed' do
    Given {
      expect(Guitar).to receive(:find).with('ES-335').and_return(guitar)
    }
    When { get :show, **request_params(id: 'ES-335') }
    Then { controller.guitar? == true }
  end
end
