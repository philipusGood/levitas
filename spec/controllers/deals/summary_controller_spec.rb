require 'rails_helper'

RSpec.describe Deals::SummaryController, type: :controller do
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
end
