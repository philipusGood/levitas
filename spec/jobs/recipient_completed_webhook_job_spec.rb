require 'rails_helper'

RSpec.describe RecipientCompletedWebhookJob, type: :job do
  let(:envelope_id) { "7a7eba53-56cd-49e7-9749-f3ba934e0d91" }
  let(:params) do
    {
      "accountId" => "f80963c0-98b1-4c69-9a64-8f5f4317a14c",
      "userId"=> "24b7d0ca-a520-4fc4-ba18-6fb78b8746a1",
      "envelopeId" => envelope_id,
      "recipientId" => "2"
    }
  end

  let(:deal) { create(:deal) }
  let(:lender) { create(:user, role: 'lender') }
  subject { described_class.perform_now(params)}

  before do
    DealLender.create(deal: deal, lender_id: lender.id, envelope_id: envelope_id)
  end

  it "updates singed at for record" do
    subject

    expect(DealLender.find_by(envelope_id: envelope_id).signed_at).to_not be_nil
  end
end
