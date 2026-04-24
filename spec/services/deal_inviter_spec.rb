require 'rails_helper'

describe DealInviter, type: :service do
  let(:broker) { create(:user, role: 'broker') }
  let!(:deal) { create(:deal) }
  let(:emails) { ['lender@levitas.ai', 'lender2@levitas.ai'] }
  subject { described_class.new(deal: deal, emails: emails).call }

  before do
    Current.user = broker
  end

  it "creates lenders for deal" do
    subject

    expect(deal.reload.lenders.map(&:email)).to eq(emails)
  end

  it "enqueues LinkBrokerLenderJob" do
    expect {
      subject
    }.to have_enqueued_job(LinkBrokerLenderJob).at_least(2).times
  end
end
