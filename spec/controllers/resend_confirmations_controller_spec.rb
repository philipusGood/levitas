require 'rails_helper'

RSpec.describe ResendConfirmationsController, type: :controller do
  describe 'POST #create' do
    let(:user) { create(:user, confirmed_at: nil) }

    context 'when user is authenticated' do
      before do
        sign_in user
        request.headers.merge!({ 'HTTP_REFERER' => 'localhost' })
      end

      it 'sends confirmation instructions' do
        expect {
          post :create
        }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end
  end
end
