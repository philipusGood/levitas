require 'rails_helper'

RSpec.describe Deals::GuarantorsController, type: :controller do
  let(:user) { create(:user) }
  let(:deal) { create(:deal) }

  before do
    sign_in(user)
  end

  describe 'GET #index' do
    it 'renders the index template' do
      get :index, params: { deal_id: deal.id }
      expect(response).to render_template('index')
    end
  end

  describe 'POST #create' do
    let(:valid_guarantor_params) do
      {
        deal_guarantor: {
          title: 'Mr',
          first_name: 'John',
          last_name: 'Doe',
          email: 'john@example.com',
          phone_number: '1234567890',
          address: {
            street: '123 Main St',
            unit: 'Apt 101',
            city: 'Cityville',
            province: 'CA',
            country: 'CA',
            postal_code: 'M5V 3L9'
          }
        }
      }
    end

    let(:invalid_guarantor_params) do
      {
        deal_guarantor: {
          confirmation: "true",
          title: nil,
          first_name: '',
          last_name: 'Doe',
          email: 'john@example.com',
          phone_number: '1234567890',
          address: {
            street: '123 Main St',
            unit: 'Apt 101',
            city: 'Cityville',
            province: 'CA',
            country: 'US',
            postal_code: 'M5V 3L9'
          }
        }
      }
    end

    it 'redirects to the next step path on success' do
      post :create, params: { deal_id: deal.id }.merge(valid_guarantor_params)
      expect(response).to redirect_to(deal_property_index_path(deal))
    end

    it 're-renders the index template on failure' do
      post :create, params: { deal_id: deal.id }.merge(invalid_guarantor_params)
      expect(response).to render_template('index')
    end
  end
end
