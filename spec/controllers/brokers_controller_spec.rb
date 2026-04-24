require 'rails_helper'

RSpec.describe BrokersController, type: :controller do
  let(:valid_attributes) {
    { email: 'valid_email@example.com' }
  }

  let(:invalid_attributes) {
    { email: '' }
  }

  let(:user) { create(:user, role: 'admin') }

  before do
    sign_in(user)
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index

      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new broker' do
        expect {
          post :create, params: { broker: valid_attributes }
        }.to change(Broker, :count).by(1)
      end

      it 'redirects to the brokers index page' do
        post :create, params: { broker: valid_attributes }
        expect(response).to redirect_to(brokers_path)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new broker' do
        expect {
          post :create, params: { broker: invalid_attributes }
        }.not_to change(Broker, :count)
      end

      it 'returns unprocessable_entity status' do
        post :create, params: { broker: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #edit' do
    let(:broker) { create(:broker) }

    it 'returns a success response' do
      get :edit, params: { id: broker.to_param }
      expect(response).to be_successful
    end
  end

  describe 'PUT #update' do
    let(:broker) { create(:broker) }

    context 'with valid parameters' do
      it 'updates the broker' do
        put :update, params: { id: broker.to_param, broker: valid_attributes }
        broker.reload
        expect(broker.email).to eq(valid_attributes[:email])
      end

      it 'redirects to the brokers index page' do
        put :update, params: { id: broker.to_param, broker: valid_attributes }
        expect(response).to redirect_to(brokers_path)
      end
    end

    context 'with invalid parameters' do
      it 'does not update the broker' do
        put :update, params: { id: broker.to_param, broker: invalid_attributes }
        broker.reload
        expect(broker.email).not_to eq(invalid_attributes[:email])
      end

      it 'returns unprocessable_entity status' do
        put :update, params: { id: broker.to_param, broker: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:broker) { create(:broker) }

    it 'destroys the requested broker' do
      expect {
        delete :destroy, params: { id: broker.to_param }
      }.to change(Broker, :count).by(-1)
    end

    it 'redirects to the brokers index page' do
      delete :destroy, params: { id: broker.to_param }
      expect(response).to redirect_to(brokers_path)
    end
  end

  describe "POST #send_invite" do
    let(:broker) { create(:user, role: :broker)}
    before do
      sign_in(user)
    end

    it "updates invitation_sent_at for the broker" do
      expect {
        post :send_invite, params: { id: broker.id }
        broker.reload
      }.to change { broker.invitation_sent_at }.from(nil)
    end

    it "delivers the invitation" do
      expect_any_instance_of(User).to receive(:deliver_invitation)
      post :send_invite, params: { id: broker.id }
    end

    it "redirects to brokers_path" do
      post :send_invite, params: { id: broker.id }
      expect(response).to redirect_to(brokers_path)
    end
  end
end
