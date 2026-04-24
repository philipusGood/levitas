class DealLender < ApplicationRecord
  belongs_to :deal
  belongs_to :lender

  validates_uniqueness_of :lender_id, scope: :deal_id

  def generate_envelope!
    return if envelope_id.present?

    response = docusign_client.create_and_send_envelope(
      deal: deal,
      lender: lender,
      commited_capital: commited_capital # Its Committed, double MM and double TT
    )

    envelope_id = response["envelopeId"]
    self.update!(envelope_id: envelope_id)
  end

  def document_url
    return if envelope_id.nil?

    docusign_client.get_recipient_view_url(
      envelope_id: envelope_id,
      lender: lender,
      deal: deal
    )
  end

  private

  def docusign_client
    @docusign_client ||= DocusignService.new
  end
end