class DealUpdater
  attr_reader :deal, :params

  def initialize(deal:, params:)
    @deal = deal
    @params = params
  end

  def call
    if valid?
      update_deal
    end
  end

  def applicant
    assets = params[:applicant]&.[](:assets) || []
    @applicant ||= Deal::Applicant.new(
      **params[:applicant] || {},
      assets: assets.is_a?(Array) ? assets : assets.values
    )
  end

  def secondary_applicant
    assets = params[:secondary_applicant]&.[](:assets) || []
    @secondary_applicant ||= Deal::Applicant.new(
      **params[:secondary_applicant] || {},
      assets: assets.is_a?(Array) ? assets : assets.values
    )
  end

  def property
    @property ||= Deal::Property.new(
      params[:property] || {},
    )
  end

  def terms
    @terms ||= Deal::Term.new(
      params[:terms] || {},
    )
  end

  def loan_purpose
    @loan_purpose ||= Deal::LoanPurpose.new(
      params[:loan_purpose] || {}
    )
  end

  def broker_fees
    @broker_fees ||= Deal::BrokerFee.new(
      params.dig(:broker_fees, :fees) || []
    )
  end

  def guarantor
    @guarantor ||= Deal::Guarantor.new(
      params[:guarantor] || {}
    )
  end

  private

  def valid?
    [valid_applicant?, valid_secondary_applicant?, valid_property?, valid_terms?, valid_loan_purpose?, valid_broker_fees?].all?
  end

  def valid_applicant?
    applicant.valid? && applicant.employer.valid? && applicant.assets.valid? && applicant.liabilities.valid?
  end

  def valid_secondary_applicant?
    return true unless @deal.has_secondary_applicant?

    secondary_applicant.valid? && secondary_applicant.employer.valid? && secondary_applicant.assets.valid? && secondary_applicant.liabilities.valid?
  end

  def valid_property?
    property.valid?
  end

  def valid_terms?
    terms.valid?
  end

  def valid_loan_purpose?
    loan_purpose.valid?
  end

  def valid_broker_fees?
    broker_fees.valid?
  end

  def serialize
    data = {
      applicant: applicant.serialize,
      property: property.serialize,
      terms: terms.serialize,
      loan_purpose: loan_purpose.serialize,
      broker_fees: broker_fees.serialize,
      guarantor: guarantor.serialize
    }

    data.merge!({ secondary_applicant: secondary_applicant.serialize }) if @deal.has_secondary_applicant?

    data
  end

  def update_deal
    deal.property_picture = params[:property_picture] if params[:property_picture].present?
    deal.state = params[:state] if params[:state].present?
    deal.property_details = params[:property_details] if params[:property_details].present?
    deal.details = deal.details.deep_merge(serialize)
    deal.approved_signatures_at = Time.now if deal.approved_signatures_at.nil? && deal.state == "signatures"
    deal.save
  end
end
