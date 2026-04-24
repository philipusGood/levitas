require 'rails_helper'

RSpec.describe MarketplaceController, type: :controller do
  let(:user) { create(:user, :lender) }

  before do
    sign_in user

    get :index
  end

  it "defaults view to cards" do
    expect(assigns(:deals_view)).to eq("card")
  end

  it "defaults visibility to Public" do
    expect(assigns(:visibility)).to eq("Public")
  end
end
