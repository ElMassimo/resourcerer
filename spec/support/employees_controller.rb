class EmployeesController < ActionController::Base
  include Resourcerer::Resourceable

  resource :employee, param_key: :employee, collection: ->{ company.employees }, strategy: Resourcerer::Strategies::EagerAttributesStrategy
end
