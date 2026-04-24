require 'rails_helper'

RSpec.describe LendersController, type: :controller do
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "renders the index template" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template :new
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new lender" do
        expect {
          post :create, params: { lender: { email: "test@example.com" } }
        }.to change(Lender, :count).by(1)
      end

      it "redirects to lenders_path" do
        post :create, params: { lender: { email: "test@example.com" } }
        expect(response).to redirect_to lenders_path
      end
    end

    context "with invalid params" do
      it "renders the new template" do
        post :create, params: { lender: { email: "" } }
        expect(response).to render_template :new
      end
    end
  end

  describe "GET #edit" do
    let(:lender) { FactoryBot.create(:lender) }

    it "renders the edit template" do
      get :edit, params: { id: lender.id }
      expect(response).to render_template :edit
    end
  end

  describe "PUT #update" do
    let(:lender) { FactoryBot.create(:lender) }

    context "with valid params" do
      it "updates the lender" do
        put :update, params: { id: lender.id, lender: { email: "new_email@example.com" } }
        lender.reload
        expect(lender.email).to eq("new_email@example.com")
      end

      it "redirects to lenders_path" do
        put :update, params: { id: lender.id, lender: { email: "new_email@example.com" } }
        expect(response).to redirect_to lenders_path
      end
    end

    context "with invalid params" do
      it "renders the edit template" do
        put :update, params: { id: lender.id, lender: { email: "" } }
        expect(response).to render_template :edit
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:lender) { FactoryBot.create(:lender) }

    it "destroys the lender" do
      expect {
        delete :destroy, params: { id: lender.id }
      }.to change(Lender, :count).by(-1)
    end

    it "redirects to lenders_path" do
      delete :destroy, params: { id: lender.id }
      expect(response).to redirect_to lenders_path
    end
  end

  describe "POST #send_invite" do
    let(:lender) { create(:user, role: :lender)}
    before do
      sign_in(user)
    end

    it "updates invitation_sent_at for the lender" do
      expect {
        post :send_invite, params: { id: lender.id }
        lender.reload
      }.to change { lender.invitation_sent_at }.from(nil)
    end

    it "delivers the invitation" do
      expect_any_instance_of(User).to receive(:deliver_invitation)
      post :send_invite, params: { id: lender.id }
    end

    it "redirects to lenders_path" do
      post :send_invite, params: { id: lender.id }
      expect(response).to redirect_to(lenders_path)
    end
  end
end