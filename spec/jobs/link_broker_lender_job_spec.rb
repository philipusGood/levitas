require 'rails_helper'

RSpec.describe LinkBrokerLenderJob, type: :job do
  let(:broker) { create(:user, role: 'broker') }
  let(:lender) { create(:user, role: 'lender') }

  subject { described_class.new.perform({ "broker_id" => broker.id, "lender_id" => lender.id })}

  it "links a lender within a broker" do
    expect {
      subject
    }.to change(BrokerLender, :count).by(1)
  end
end
