require 'rails_helper'

RSpec.describe Lender::BrokersController, type: :controller do
  let(:user) { create(:user, :broker) }
  let(:lender) { create(:user, :lender) }

  before { sign_in lender }

  describe 'GET #index' do
    it 'assigns @brokers and @lender' do
      get :index

      expect(assigns(:lender).id).to eq(lender.id)
    end
  end

  describe 'POST #accept_invitation' do
    let(:broker_lender) { BrokerLender.create(broker: user.as_broker, lender: lender.as_lender) }

    it 'updates broker_lender status to accepted' do
      post :accept_invitation, params: { broker_id: broker_lender.broker_id }
      broker_lender.reload
      expect(broker_lender.status).to eq('accepted')
    end

    it 'redirects to lender_brokers_path' do
      post :accept_invitation, params: { broker_id: broker_lender.broker_id }
      expect(response).to redirect_to(lender_brokers_path)
    end
  end

  describe 'POST #reject_invitation' do
    let(:broker_lender) { BrokerLender.create(broker: user.as_broker, lender: lender.as_lender) }

    it 'destroys the broker_lender' do
      post :reject_invitation, params: { broker_id: broker_lender.broker_id }

      expect(BrokerLender.count).to eq(0)
    end

    it 'redirects to lender_brokers_path' do
      post :reject_invitation, params: { broker_id: broker_lender.broker_id }
      expect(response).to redirect_to(lender_brokers_path)
    end
  end
end
