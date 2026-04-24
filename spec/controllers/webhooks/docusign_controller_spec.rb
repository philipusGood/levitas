require 'rails_helper'

RSpec.describe Webhooks::DocusignController, type: :controller do
  describe "POST#create" do
    let(:params) do
      {
        "event" => "recipient-completed",
        "apiVersion" => "v2.1",
        "uri" => "/restapi/v2.1/accounts/f80963c0-98b1-4c69-9a64-8f5f4317a14c/envelopes/7a7eba53-56cd-49e7-9749-f3ba934e0d91",
        "retryCount" => 0,
        "configurationId" => 10476521,
        "generatedDateTime" => "2024-02-06T02:25:00.3464434Z",
        "data" => {
          "accountId" => "f80963c0-98b1-4c69-9a64-8f5f4317a14c",
          "userId"=> "24b7d0ca-a520-4fc4-ba18-6fb78b8746a1",
          "envelopeId" => "evenlopeId",
          "recipientId" => "2"
        }
      }
    end

    subject { post :create, params: params }

    it "enqueues RecipientCompletedWebhookJob" do
      expect {
        subject
      }.to have_enqueued_job(RecipientCompletedWebhookJob)
    end
  end
end
