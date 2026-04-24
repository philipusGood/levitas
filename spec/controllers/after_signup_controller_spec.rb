require 'rails_helper'

RSpec.describe AfterSignupsController, type: :controller do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET #show" do
    it "renders the show template" do
      get :show
      expect(response).to render_template(:show)
    end
  end

  describe "PATCH #update" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          user: {
            title: "Dr.",
            first_name: "John",
            middle_name: "M",
            last_name: "Doe",
            birth_date: Date.today - 30.years,
            phone_number: "555-555-5555",
            address_street: "123 Main St",
            address_unit: "Apt 101",
            address_city: "Anytown",
            address_province: "State",
            address_country: "Country",
            address_postal_code: "12345"
          }
        }
      end

      it "updates the user and redirects to after_signup_path" do
        patch :update, params: valid_params
        expect(user.reload.first_name).to eq("John")
        expect(response).to redirect_to(after_signup_path)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          user: {
            first_name: "", # Invalid parameter
            last_name: "Doe",
          }
        }
      end

      it "does not update the user and renders show template with unprocessable_entity status" do
        patch :update, params: invalid_params
        expect(user.reload.first_name).not_to eq("")
        expect(response).to render_template(:show)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
