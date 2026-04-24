class DealPrefiller < DealUpdater
  def initialize(deal:, params:)
    super(deal: deal, params: params.with_indifferent_access)
  end

  def call
    @deal.details = serialize
    @deal.save!
  end

  def broker_fees
    @broker_fees ||= Deal::BrokerFee.new(
      params.dig(:broker_fees) || []
    )
  end

  def serialize
    data = {
      applicant: applicant.safe_serialization,
      property: property.safe_serialization,
      terms: terms.safe_serialization,
      loan_purpose: loan_purpose.safe_serialization,
      broker_fees: broker_fees.safe_serialization,
      guarantor: guarantor.safe_serialization
    }

    data.merge!({ secondary_applicant: secondary_applicant.safe_serialization }) if @deal.has_secondary_applicant?

    data
  end
end
