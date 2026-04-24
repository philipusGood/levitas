require 'rails_helper'

describe LenderCommitCapital, type: :service do
  let!(:lender) { create(:user, role: "lender") }
  let!(:deal) { create(:deal) }
  let(:amount) { deal.target }
  subject { described_class.new(lender: lender, deal: deal, amount: amount).call }

  before do
    deal.lenders << lender.as_lender
  end

  it "updates deal lender amount" do
    subject

    deal_lender = DealLender.find_by(lender_id: lender.id, deal_id: deal.id)

    expect(deal_lender.commited_capital).to eq(BigDecimal(amount))
  end

  it "notifies admin when deal funding is completed" do
    expect {
      subject
    }.to have_enqueued_mail(DealMailer, :funding_completed).with(deal: deal)
  end
end
