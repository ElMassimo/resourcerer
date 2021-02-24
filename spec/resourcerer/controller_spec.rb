require 'spec_helper'

RSpec.describe Resourcerer::Controller do
  class Thing; end
  class DifferentThing; end
  class BaseController; end

  Given(:controller_klass) {
    Class.new(BaseController) do
      include Resourcerer::Controller
    end
  }
  Given(:params) { {} }
  Given(:actual_params) { params.with_indifferent_access }
  Given(:request) { double('Request', get?: false) }
  Given(:controller) { controller_klass.new }
  Given(:thing) { double('Thing') }

  def controller_thing
    controller.send(:thing)
  end

  Given {
    allow(Thing).to receive(:all).and_return(Thing)
    allow(DifferentThing).to receive(:all).and_return(DifferentThing)
    allow(Thing).to receive(:klass).and_return(Thing)
    allow(DifferentThing).to receive(:klass).and_return(DifferentThing)
    allow(controller).to receive(:params).and_return(actual_params)
    allow(controller).to receive(:request).and_return(request)
    allow(controller).to receive(:action_name).and_return('new')
  }

  delegate :resource, :resourcerer_config, to: :controller_klass

  context 'getter/setter methods' do
    Given { resource :thing }
    Then { controller.respond_to?(:thing, true) }
    And  { controller.respond_to?(:thing=, true) }
    And  { controller.method(:thing=).parameters.size == 1 }
  end

  context 'incorrect proc options' do
    Given { resource :thing, build: :thing }
    When(:usage) { controller_thing }
    Then { expect(usage).to have_failed(ArgumentError, /Can't handle :build => :thing option/) }
  end

  context 'memoization' do
    Given { resource :thing, build: -> { SecureRandom.hex(32) } }
    Then { controller_thing == controller_thing }
  end

  context 'resourcerer_config' do
    context 'subclass configration does not propagate to superclass' do
      Given(:config) { controller_klass.resourcerer_configuration }
      Given(:subklass) { Class.new(controller_klass) }
      Given(:subklass_config) { subklass.resourcerer_configuration }
      Given {
        controller_klass.resourcerer_config :foo, attrs: :bar
        subklass.resourcerer_config :foo, attrs: :lol
        subklass.resourcerer_config :fizz, attrs: :buzz
      }
      Then { subklass_config != config }
      And  { subklass_config[:foo].is_a?(Resourcerer::Configuration) }
      And  { subklass_config[:fizz].is_a?(Resourcerer::Configuration) }
      And  { config[:foo].is_a?(Resourcerer::Configuration) }
      And  { config[:fizz].nil? }
    end

    context 'applying' do
      Given(:params) {{ check_this_out: 'foo', whee: 'wut' }}
      Given {
        resourcerer_config :sluggable, find_by: :slug
        resourcerer_config :weird_id_name, id: :check_this_out
        resourcerer_config :another_id_name, id: :whee
        resourcerer_config :multi, find_by: :slug, id: :check_this_out
      }

      after { expect(controller_thing).to eq(thing) }

      context 'can be reused later' do
        Given { resource :thing, using: :weird_id_name }
        Then { expect(Thing).to receive(:find).with('foo').and_return(thing) }
      end

      context 'can apply multple configs at once' do
        Given { resource :thing, using: [:weird_id_name, :sluggable] }
        Then { expect(Thing).to receive(:find_by!).with(slug: 'foo').and_return(thing) }
      end

      context 'applies multiple configs in a correct order' do
        Given { resource :thing, using: [:another_id_name, :weird_id_name] }
        Then { expect(Thing).to receive(:find).with('wut').and_return(thing) }
      end

      context 'can apply multiple options in a config' do
        Given { resource :thing, using: :multi }
        Then { expect(Thing).to receive(:find_by!).with(slug: 'foo').and_return(thing) }
      end

      context 'applies multiple configs with multiple options in a correct order' do
        Given { resource :thing, using: [:another_id_name, :multi] }
        Then { expect(Thing).to receive(:find_by!).with(slug: 'wut').and_return(thing) }
      end
    end
  end

  context 'default behaviour' do
    context "setting value directly" do
      Given {
        expect(Thing).not_to receive(:new)
        resource :thing
      }
      When {
        controller.instance_eval do
          self.thing = :foobar
        end
      }
      Then { controller_thing == :foobar }
    end

    context 'assign' do
      Given(:attrs) {{ lol: :wut }}
      Given {
        allow(controller).to receive(:thing_params).and_return(attrs)
        expect(Thing).to receive(:new).with(attrs).and_return(thing)
      }
      after { expect(controller_thing).to eq(thing) }

      context 'does not assign on non-update action' do
        Given {
          expect(controller).to receive(:action_name).and_return('index')
        }
        When { resource :thing }
        Then { expect(thing).not_to receive(:assign_attributes) }
      end

      context 'does not assign on empty object' do
        Given(:thing) { nil }
        When { resource :thing }
        Then { }
      end

      context 'assigns on update' do
        Given {
          expect(controller).to receive(:action_name).and_return('update')
        }
        When { resource :thing }
        Then { expect(thing).to receive(:assign_attributes).with(attrs) }
      end
    end

    context 'build' do
      after { expect(controller_thing).to eq(thing) }

      context 'params method is not available' do
        context 'builds a new instance with empty hash' do
          Given { resource :thing }
          Then { expect(Thing).to receive(:new).with({}).and_return(thing) }
        end
      end

      context 'params method is available' do
        context 'ignores params on get request' do
          Given { resource :thing }
          Then {
            expect(request).to receive(:get?).and_return(true)
            expect(controller).not_to receive(:thing_params)
            expect(Thing).to receive(:new).with({}).and_return(thing)
          }
        end

        context 'uses params method on non-get request' do
          Given { resource :thing }
          Then {
            expect(Thing).to receive(:new).with(foo: :bar).and_return(thing)
            expect(controller).to receive(:thing_params).and_return(foo: :bar)
          }
        end

        context 'can use custom params method name' do
          Given { resource :thing, attrs: :custom_params_method_name }
          Then {
            expect(Thing).to receive(:new).with(foo: :bar).and_return(thing)
            expect(controller).to receive(:custom_params_method_name).and_return(foo: :bar)
          }
        end

        context 'can use custom build params' do
          Given { resource :thing, attrs: ->{ foobar } }
          Then {
            expect(controller).to receive(:foobar).and_return(42)
            expect(Thing).to receive(:new).with(42).and_return(thing)
          }
        end
      end
    end

    context 'find' do
      Given do
        resource :thing, model: :different_thing
        expect(DifferentThing).to receive(:find).with(10).and_return(thing)
      end

      context 'checks params[:thing_id] first' do
        Given(:params) {{ thing_id: 10, different_thing_id: 11, id: 12 }}
        Then { controller_thing == thing }
      end

      context 'checks params[:different_thing_id] second' do
        Given(:params) {{ 'different_thing_id' => 10, id: 11 }}
        Then { controller_thing == thing }
      end

      context 'checks params[:id] in the end' do
        Given(:params) {{ id: 10 }}
        Then { controller_thing == thing }
      end
    end
  end

  context 'assign?' do
    Given(:attrs) {{ lol: :wut }}
    Given {
      allow(controller).to receive(:thing_params).and_return(attrs)
      expect(Thing).to receive(:new).with(attrs).and_return(thing)
      allow(controller).to receive(:action_name).and_return('index')
    }

    after { controller_thing == thing }

    context 'assign? is false' do
      When { resource :thing, assign?: false }
      Then { expect(thing).not_to receive(:assign_attributes) }
    end

    context 'assign? is true' do
      When { resource(:thing) { assign? true } }
      Then { expect(thing).to receive(:assign_attributes).with(attrs) }
    end

    context 'passing a single action' do
      context 'when it does not match the current action' do
        When { resource(:thing) { assign? :edit } }
        Then { expect(thing).not_to receive(:assign_attributes).with(attrs) }
      end

      context 'when it matches the current action' do
        When { resource(:thing) { assign? :index } }
        Then { expect(thing).to receive(:assign_attributes).with(attrs) }
      end
    end

    context 'passing several actions' do
      context 'when none matches the current action' do
        When { resource :thing, assign?: [:update, :edit] }
        Then { expect(thing).not_to receive(:assign_attributes).with(attrs) }
      end

      context 'when one matches the current action' do
        When { resource :thing, assign?: [:update, :index, :edit] }
        Then { expect(thing).to receive(:assign_attributes).with(attrs) }
      end
    end
  end

  context 'find_by' do
    it 'throws and error when using with :find' do
      action = ->{ resource :thing, find: -> { }, find_by: :bar }
      expect(&action).to raise_error(ArgumentError, 'Using :find_by option with :find does not make sense')
    end

    context 'allows to specify what attribute to use for find' do
      Given { expect(Thing).to receive(:find_by!).with(foo: 10).and_return(42) }
      When {
        resource :thing, find_by: :foo
        controller.params.merge! id: 10
      }
      Then { expect(controller_thing).to eq(42) }
    end
  end

  context 'collection' do
    Given(:collection) { double('Collection', klass: Thing) }
    Given {
      allow(collection).to receive(:klass).and_return(Thing)
    }

    context 'allows overriding collection using block' do
      Given { expect(collection).to receive(:new).and_return(42) }
      When {
        scope = self.collection
        resource(:thing) { collection { scope } }
      }
      Then { controller_thing == 42 }
    end

    context 'build/find' do
      Given(:current_user) { double('User') }
      Given {
        expect(controller).to receive(:current_user).and_return(current_user)
        expect(current_user).to receive(:things).and_return(collection)
        resource :thing, collection: -> { current_user.things }
      }

      context 'sets the collection to belong to collection defined by controller method' do
        When { expect(collection).to receive(:new).with({}).and_return(42) }
        Then { controller_thing == 42 }
      end

      context 'collections the find to proper collection' do
        Given(:params) {{ thing_id: 10 }}
        When { expect(collection).to receive(:find).with(10).and_return(42) }
        Then { controller_thing == 42 }
        Then { controller.resource(:thing, collection: -> { current_user.things }) == 42 }
      end
    end
  end

  context 'model' do
    Given(:different_thing) { double('DifferentThing') }
    Given { expect(DifferentThing).to receive(:new).with({}).and_return(different_thing) }

    context 'allows overriding model class with proc' do
      When { resource(:thing) { model { DifferentThing } } }
      Then { controller_thing == different_thing }
    end

    context 'allows overriding model with class' do
      When { resource :thing, model: DifferentThing }
      Then { controller_thing == different_thing }
    end

    context 'allows overriding model class with symbol' do
      When { resource :thing, model: :different_thing }
      Then { controller_thing == different_thing }
    end

    context 'allows overriding model class with string' do
      When { resource :thing, model: 'DifferentThing' }
      Then { controller_thing == different_thing }
    end
  end

  context 'id' do
    Given {
      expect(Thing).to receive(:find).with(42).and_return(thing)
    }

    context 'allows overriding id with proc' do
      Given { expect(controller).to receive(:get_thing_id_somehow).and_return(42) }
      When { resource(:thing) { id { get_thing_id_somehow } } }
      Then { controller_thing == thing }
    end

    context 'allows overriding id with symbol' do
      Given(:params) {{ thing_id: 10, custom_thing_id: 42 }}
      When { resource :thing, id: :custom_thing_id }
      Then { controller_thing == thing }
    end

    context 'allows overriding id with an array of symbols' do
      Given { controller.params.merge! another_id_param: 42 }
      When { resource :thing, id: %w[non-existent-id lolwut another_id_param] }
      Then { controller_thing == thing }
    end
  end

  context 'permit' do
    Given(:actual_params) { double('Params', :[] => nil) }
    Given(:attrs) {{ name: 'Max', email: 'max@email.com' }}
    Given(:fields) { [:name, :email] }

    it 'throws and error when using with :attrs' do
      action = ->{ resource :thing, attrs: -> { }, permit: :bar }
      expect(&action).to raise_error(ArgumentError, 'Using :permit option with :attrs does not make sense')
    end

    context 'allows to specify permitted attributes' do
      Given {
        expect(actual_params).to receive(:require).with(:thing).and_return(actual_params)
        expect(actual_params).to receive(:permit).with(*fields).and_return(attrs)
        expect(Thing).to receive(:new).with(attrs).and_return(thing)
      }

      context 'permit using a proc' do
        When { resource :thing, permit: fields }
        Then { controller_thing == thing }
      end

      context 'permit passing fields directly' do
        When {
          permitted_attributes = fields
          resource(:thing) { permit permitted_attributes }
        }
        Then { controller_thing == thing }
      end
    end
  end
end
