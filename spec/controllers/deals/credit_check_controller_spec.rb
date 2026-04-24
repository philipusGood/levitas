# spec/controllers/deals/credit_check_controller_spec.rb

require 'rails_helper'

RSpec.describe Deals::CreditCheckController, type: :controller do
  let(:user) {create(:user, role: 'broker')}
  let(:deal) { create(:deal) }

  before do
    sign_in(user)
  end

  describe 'GET #index' do
    it 'assigns @credit_check' do
      get :index, params: { deal_id: deal.id }
      expect(assigns(:credit_check)).to be_a(Deal::CreditCheck)
    end

    it 'renders the index template' do
      get :index, params: { deal_id: deal.id }
      expect(response).to render_template('index')
    end
  end

  describe 'POST #create' do
    let(:valid_credit_check_params) do
      {
        deal_credit_check: {
          accept_terms: 1 
        }
      }
    end

    let(:invalid_credit_check_params) do
      {
        deal_credit_check: {
          accept_terms: 0 
        }
      }
    end

    it 'redirects to the next step path on success' do
      post :create, params: { deal_id: deal.id }.merge(valid_credit_check_params)
      expect(response).to redirect_to(deal_summary_index_path(deal))
    end

    it 're-renders the index template on failure' do
      post :create, params: { deal_id: deal.id }.merge(invalid_credit_check_params)
      expect(response).to render_template('index')
    end
  end
end
