require 'spec_helper'
require 'action_controller'
require 'resourcerer/resourceable'
require 'resourcerer/strategies/eager_attributes_strategy'
require 'support/employees_controller'

describe EmployeesController do

  Given(:company) { double('company', employees: employees) }
  Given(:employees) { double('employees') }
  Given(:controller) { EmployeesController.new }
  Given(:request) { double('request', parameters: params, get?: false, delete?: false) }
  Given(:params) { {} }

  Given do
    allow_any_instance_of(EmployeesController).to receive(:company).and_return(company)

    allow(controller).to receive(:request).and_return(request)
  end

  context 'when there is no resource id' do
    Given(:params) {{ employee: { name: 'John Doe', phone: '555-444-333' } }}
    Given(:employee) { double('employee') }
    Given do
      expect(employees).to receive(:new).and_return(employee)
    end
    context 'when it should assign attributes' do
      Given do
        expect(employee).to receive(:attributes=).with(params[:employee])
      end
      Then { controller.employee == employee }
    end

    context 'when it should not assign attributes' do
      Given do
        allow(request).to receive(:get?).and_return(true)
        expect(employee).not_to receive(:attributes=)
      end
      Then { controller.employee == employee }
    end
  end

  context 'when there is a resource id' do
    Given(:params) {{ employee_id: 'fake_id', employee: { name: 'John Doe', phone: '555-444-333' } }}
    Given(:employee) { double('employee') }
    Given do
      expect(employees).to receive(:find_by).with(id: 'fake_id').and_return(employee)
    end

    context 'and it is a POST request' do
      Given do
        expect(employee).to receive(:attributes=).with(params[:employee])
      end
      Then { controller.employee == employee }
    end

    context 'when it is a GET request' do
      Given do
        allow(request).to receive(:get?).and_return(true)
        expect(employee).not_to receive(:attributes=)
      end
      Then { controller.employee == employee }
    end
  end
end
