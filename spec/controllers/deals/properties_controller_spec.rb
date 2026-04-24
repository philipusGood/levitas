require 'rails_helper'

RSpec.describe Deals::PropertiesController, type: :controller do
  let(:user) { create(:user) }
  let(:deal) { create(:deal) }

  before do
    sign_in(user)
  end

  describe 'GET #index' do
    it 'assigns @property' do
      get :index, params: { deal_id: deal.id }
      expect(assigns(:property)).to be_a(Deal::Property)
    end

    it 'renders the index template' do
      get :index, params: { deal_id: deal.id }
      expect(response).to render_template('index')
    end
  end

  describe 'POST #create' do
    let(:valid_property_params) do
      {
        deal_property: {
          type: 'Some Type',
          mls_number: '12345',
          price: 100000,
          approximate_closing_date: Date.tomorrow,
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

    let(:invalid_property_params) do
      {
        deal_property: {
          type: nil,
          mls_number: '12345',
          price: 100000,
          approximate_closing_date: Date.tomorrow,
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

    xit 'redirects to the next step path on success' do
      post :create, params: { deal_id: deal.id }.merge(valid_property_params)
      expect(response).to redirect_to(deal_terms_path(deal))
    end

    it 're-renders the index template on failure' do
      post :create, params: { deal_id: deal.id }.merge(invalid_property_params)
      expect(response).to render_template('index')
    end
  end
end
