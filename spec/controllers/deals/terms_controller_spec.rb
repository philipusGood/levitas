require 'rails_helper'

RSpec.describe Deals::TermsController, type: :controller do
  let(:user) { create(:user) }
  let(:deal) { create(:deal) }
  let(:valid_term_params) do
    {
      deal_term: {
        mortgage_principal: 200000,
        lenders_fee: 5000,
        interest_rate: 3.5,
        type: 'Fixed',
        terms: '20 years',
        amortization_period: '25 years',
        public: true
      }
    }
  end

  before do
    sign_in(user)
  end

  describe 'GET #index' do
    it 'assigns @terms' do
      get :index, params: { deal_id: deal.id }
      expect(assigns(:terms)).to be_a(Deal::Term)
    end

    it 'renders the index template' do
      get :index, params: { deal_id: deal.id }
      expect(response).to render_template('index')
    end
  end

  describe 'POST #create' do
    it 'assigns @terms' do
      post :create, params: { deal_id: deal.id }.merge(valid_term_params)
      expect(assigns(:terms)).to be_a(Deal::Term)
    end

    it 'redirects to the next step path on success' do
      post :create, params: { deal_id: deal.id }.merge(valid_term_params)
      expect(response).to redirect_to(deal_loan_purpose_index_path(deal))
    end

    it 're-renders the index template on failure' do
      invalid_term_params = valid_term_params.dup
      invalid_term_params[:deal_term][:mortgage_principal] = nil

      post :create, params: { deal_id: deal.id }.merge(invalid_term_params)
      expect(response).to render_template('index')
    end
  end
end
