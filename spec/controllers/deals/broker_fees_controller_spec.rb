require 'rails_helper'

RSpec.describe Deals::BrokerFeesController, type: :controller do
  let(:user) { create(:user) }
  let(:deal) { create(:deal) }
  let(:valid_broker_fee_params) do
    {
      deal_broker_fee: {
        fees: [
          { broker_name: 'Broker A', amount_fee: 500, default: false },
          { broker_name: 'Broker B', amount_fee: 700, default: false }
        ]
      }
    }
  end

  before do
    sign_in(user)
  end

  describe 'GET #index' do
    it 'assigns @broker_fee' do
      get :index, params: { deal_id: deal.id }
      expect(assigns(:broker_fee)).to be_a(Deal::BrokerFee)
    end

    it 'renders the index template' do
      get :index, params: { deal_id: deal.id }
      expect(response).to render_template('index')
    end
  end

  describe 'POST #create' do
    it 'assigns @broker_fee' do
      post :create, params: { deal_id: deal.id }.merge(valid_broker_fee_params)
      expect(assigns(:broker_fee)).to be_a(Deal::BrokerFee)
    end

    it 'redirects to the next step path on success' do
      post :create, params: { deal_id: deal.id }.merge(valid_broker_fee_params)
      expect(response).to redirect_to(deal_credit_check_index_path(deal))
    end

    it 're-renders the index template on failure' do
      invalid_broker_fee_params = valid_broker_fee_params.dup
      invalid_broker_fee_params[:deal_broker_fee][:fees].first[:amount_fee] = nil

      post :create, params: { deal_id: deal.id }.merge(invalid_broker_fee_params)
      expect(response).to render_template('index')
    end
  end
end
