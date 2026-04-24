class Deal::Term < Deal::Base
  attr_accessor :mortgage_principal,
  :lenders_fee,
  :interest_rate,
  :type,
  :terms,
  :amortization_period,
  :prepayment_term,
  :payment_frecuency,
  :public

  validates :mortgage_principal, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :lenders_fee, numericality: { greater_than_or_equal_to: 0 }, unless: :is_public?, allow_blank: true
  validates :interest_rate, numericality: { greater_than_or_equal_to: 0 }, unless: :is_public?, allow_blank: true
  validates :type, presence: true
  validates :terms, presence: true
  validates :prepayment_term, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 99 }
  validates :amortization_period, presence: true

  def initialize(attributes = {})
    attributes = attributes.with_indifferent_access if attributes.respond_to?(:with_indifferent_access)

    @mortgage_principal = attributes[:mortgage_principal]
    @lenders_fee = attributes[:lenders_fee] || 0
    @interest_rate = attributes[:interest_rate] || 0
    @type = attributes[:type]
    @terms = attributes[:terms]
    @amortization_period = attributes[:amortization_period]
    @prepayment_term = attributes[:prepayment_term] || 0
    @public = attributes[:public] || false
    @payment_frecuency = attributes[:payment_frecuency] || SelectOptions::PAYMENT_FRECUENCY[2]
  end

  def serialize
    {
      mortgage_principal: mortgage_principal,
      lenders_fee: lenders_fee,
      interest_rate: interest_rate,
      type: type,
      terms: terms,
      amortization_period: amortization_period,
      prepayment_term: prepayment_term,
      payment_frecuency: payment_frecuency,
      public: @public
    }
  end

  def is_public?
    serialize[:public].to_s == "1" || serialize[:public].to_s == "true"
  end

  def terms_to_years_months
    terms_months = @terms.to_i

    years = terms_months / 12
    months = terms_months % 12

    { years:, months: }
  end

  def amortization_period_to_months
    periods = {}
    SelectOptions::AMORTIZATION_PERIOD.each do |period|
      years = period.split(' ')[0].to_i
      periods[period] = (12 * years) if years.positive?
    end
    periods
  end

  # Alias for mortgage_principal to clarify intent
  # This is the amount the borrower will actually receive (excluding fees)
  def requested_amount
    mortgage_principal
  end
end
