require 'spec_helper'
require 'resourcerer/resource_configuration'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'

describe Resourcerer::ResourceConfiguration do

  def configuration_options(options={})
    {
      model: model_name,
      finder: ->(finder_id) { "#{model_name}_#{finder_id}" },
      builder: -> { "#{model_name}_new" },
      attributes: -> { "#{model_name}_attributes" },
      collection: -> { custom_collection }
    }.merge(options)
  end

  Given(:config) { Resourcerer::ResourceConfiguration.new(options) }
  Given(:model_name) { :person }
  Given(:id) { 'id' }
  Given(:custom_collection) { double('collection') }

  When { config.instance_eval(&block) if block }

  context "with options" do
    Given(:options) { configuration_options }
    Given(:block) { nil }

    Then { config.model == :person }
    And  { config.finder.call(id) == "person_id" }
    And  { config.builder.call == 'person_new' }
    And  { config.attributes.call == 'person_attributes' }
    And  { config.collection.call == custom_collection }
  end

  context "with a block" do
    Given(:id) { 'name' }
    Given(:options) { nil }
    Given(:block) do
      model_name = :rockstar
      my_collection = custom_collection
      Proc.new {
        model model_name
        find { |finder_id| "#{model_name}_#{finder_id}" }
        build { "#{model_name}_new" }
        assign { "#{model_name}_attributes" }
        collection { my_collection }
      }
    end

    Then { config.model == :rockstar }
    And  { config.finder.call(id) == "rockstar_name" }
    And  { config.builder.call == 'rockstar_new' }
    And  { config.attributes.call == 'rockstar_attributes' }
    And  { config.collection.call == custom_collection }
  end

  context "with options and a block" do
    Given(:options) { configuration_options }
    Given(:block) do
      Proc.new {
        model :rockstar
        find { |finder_id| "rockstar_#{finder_id}" }
      }
    end

    Then { config.finder.call(id) == "rockstar_#{id}" }
    And  { config.builder.call == 'person_new' }
    And  { config.attributes.call == 'person_attributes' }
    And  { config.model == :rockstar }
  end
end
