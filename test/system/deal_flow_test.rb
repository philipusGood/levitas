require "application_system_test_case"

class DealCreatinTest < ApplicationSystemTestCase
  test "broker is only able to invite lenders funding stage" do
    user = FactoryBot.create(:user, role: "broker")
    login_as(user: user)

    deal = FactoryBot.create(:deal, state: "submitted", user: user)
    visit deal_path(deal)

    assert_no_selector "#invite-lenders"
    deal.update(state: "accepted")

    reload
    assert_no_selector "#invite-lenders"
    deal.update(state: "funding")

    reload
    assert_selector "#invite-lenders"
    deal.update(state: "signatures")

    reload
    assert_no_selector "#invite-lenders"
  end

  # test "lender should be able to fund public deals" do
  #   user = FactoryBot.create(:user, role: "lender")
  #   login_as(user: user)

  #   deal = FactoryBot.create(:deal, state: "funding", user: FactoryBot.create(:user, role: "broker"))
  #   deal.change_to_public!
  #   visit deal_path(deal)

  #   assert_selector "#funding-deal-btn"

  #   click_on "funding-deal-btn"

  #   fill_in "investment_amount", with: "100"
  #   click_on "funding-continue"


  #   check "accept_policy"

  #   fill_in "confirm_name", with: user.name
  #   click_on "confirm-investment-btn"
  # end

end
