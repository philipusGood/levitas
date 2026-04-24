class RecipientCompletedWebhookJob < ApplicationJob
  queue_as :default

  def perform(args)
    envelope_id = args["envelopeId"]

    deal_lender = DealLender.find_by(envelope_id: envelope_id)

    return if deal_lender.nil?

    deal_lender.update(signed_at: Time.now)
  end
end
