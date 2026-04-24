require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  describe 'GET #index' do
    let(:user) { create(:user) }
    before do
      sign_in user
      get :index
    end

    it "defaults deal_view to card" do
      expect(assigns(:deals_view)).to eq("card")
    end

    it "builds stats for deals" do
      expect(assigns(:status)).to eq({
        "disbursement"=>0,
        "drafts"=>0,
        "funding"=>0,
        "notary"=>0,
        "paying"=>0,
        "review"=>0,
        "signatures"=>0
      })
    end

    context "when broker" do
      let(:user) { create(:user, :broker)}
      let(:deals) { create_list(:deal, 3, user: user) }

      it "retrieves user deals" do
        expect(assigns(:user_deals)).to eq(deals)
      end

      it "filters deals by state" do
        expect(assigns(:deals)).to eq(deals)
      end
    end
  end
end
