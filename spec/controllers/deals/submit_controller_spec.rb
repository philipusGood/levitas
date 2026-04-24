require 'rails_helper'

RSpec.describe Deals::SubmitController, type: :controller do
  let(:user) { create(:user, role: 'broker') }
  let(:deal) { create(:deal) }

  before do
    sign_in(user)
  end

  describe 'GET #index' do
    context 'when deal is in submitted state' do
      before { deal.update(state: 'submitted') }

      it 'renders the index template' do
        get :index, params: { deal_id: deal.id }
        expect(response).to render_template('index')
      end
    end

    context 'when deal is not in draft state' do
      before { deal.update(state: 'draft') }

      it 'redirects to deal summary index path' do
        get :index, params: { deal_id: deal.id }
        expect(response).to redirect_to(deal_summary_index_path(deal))
      end
    end
  end

  describe 'POST #create' do
    it 'updates deal state to submitted' do
      post :create, params: { deal_id: deal.id }
      deal.reload
      expect(deal.state).to eq('submitted')
    end

    it 'redirects to deal submit index path' do
      post :create, params: { deal_id: deal.id }
      expect(response).to redirect_to(deal_submit_index_path(deal))
    end
  end
end
