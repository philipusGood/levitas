require 'rails_helper'

RSpec.describe Deals::LendersController, type: :controller do
  let(:user) { create(:user) }
  let(:deal) { create(:deal, user: user) }
  let(:lender) { create(:user, role: 'lender') }

  before do
    sign_in(user)
  end

  describe 'POST #create' do
    it 'invites lenders and redirects to deal_path' do
      expect {
        post :create, params: { deal_id: deal.id, lenders: ['email1@example.com', 'email2@example.com'] }
      }.to change { DealLender.count }.by(2)
    end
  end

  describe 'DELETE #destroy' do
    it 'removes lender from deal' do
      deal_lender = DealLender.create(deal: deal, lender_id: lender.id)

      expect {
        delete :destroy, params: { deal_id: deal.id, id: lender.id }
      }.to change { DealLender.count }.by(-1)
    end
  end

  describe 'POST #commit_capital' do
    let!(:deal_lender) { DealLender.create(deal: deal, lender_id: lender.id) }

    it 'commits capital for the lender' do
      put :commit_capital, params: { deal_id: deal.id, id: lender.id, amount: 1000 }

      expect(deal_lender.reload.commited_capital).to eq(1000)
    end
  end

  describe 'POST #send_signature_reminder' do
    let!(:deal_lender) { DealLender.create(deal: deal, lender_id: lender.id) }

    it 'commits capital for the lender' do
      post :send_signature_reminder, params: { deal_id: deal.id, id: lender.id }

      expect(deal_lender.reload.signature_sent_at).to_not be_nil
    end
  end
end