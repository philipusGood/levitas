class RequestSignatures
  attr_accessor :deal

  def initialize(deal:)
    @deal = deal
  end

  def call
    @deal.deal_lenders.each do |deal_lender|
      generate_envelope(deal_lender)
    end
  end

  private

  def generate_envelope(deal_lender)
    lender = deal_lender.lender
    return if lender.pending_account_setup? || deal_lender.envelope_id.present?
    deal_lender.generate_envelope! 
  end
end