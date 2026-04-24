require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  describe 'GET #show' do
    context 'when user is authenticated' do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it 'renders the show template' do
        get :show
        expect(response).to render_template('show')
      end

      it 'responds with a successful HTTP status' do
        get :show
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to the sign-in page' do
        get :show
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
