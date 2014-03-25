require 'spec_helper'
require 'resourcerer/inflector'

class Car; extend ActiveModel::Naming; end
class CarManufacturer; extend ActiveModel::Naming; end
module Content
  class Page; extend ActiveModel::Naming; end
end

describe Resourcerer::Inflector do
  Given(:model) { Object }
  Given(:inflector) { Resourcerer::Inflector.new(name, model) }

  describe '#parameter' do
    Given(:name) { 'car_manufacturer' }
    Given(:model) { CarManufacturer }
    Then { inflector.finder_param == 'car_manufacturer_id' }
  end

  describe '#param_key' do
    context 'with a normal name' do
      Given(:name) { 'Car' }
      Given(:model) { Car }
      Then { inflector.param_key == 'car' }
    end

    context 'with a namespaced name' do
      Given(:name) { 'Content::Page' }
      Given(:model) { Content::Page }
      Then { inflector.param_key == 'content_page' }
    end
  end

  describe '##class_for' do
    Then { Resourcerer::Inflector.class_for('content::page') == Content::Page }
    And  { Resourcerer::Inflector.class_for('car_manufacturer') == CarManufacturer }
    And  { Resourcerer::Inflector.class_for('car') == Car }
  end
end
