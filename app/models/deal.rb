class Deal < ApplicationRecord
  acts_as_paranoid

  include AASM
  include Finance

  belongs_to :user
  belongs_to :rejected_actor, foreign_key: :rejected_actor_id, class_name: 'User', optional: true

  has_many :deal_lenders, dependent: :destroy
  has_many :lenders, through: :deal_lenders, dependent: :destroy
  has_many_attached :documents, dependent: :destroy
  has_one :ai_document_pool, dependent: :destroy

  has_one_attached :property_picture, dependent: :destroy do |attachable|
    attachable.variant :thumb, saver: { quality: 10 }
  end

  before_create :generate_url_code

  enum state: {
    draft: 1,
    submitted: 2,
    reviewed: 3,
    accepted: 4,
    rejected: 5,
    funding: 6,
    signatures: 7,
    payments: 8,
    unfunded: 9,
    closed: 10
  }

  aasm column: :state, enum: true do
    state :draft, initial: true
    state :submitted, before_enter: :clear_rejection
    state :reviewed, before_enter: :clear_rejection
    state :accepted, before_enter: :clear_rejection
    state :rejected
    state :funding
    state :signatures
    state :payments
    state :unfunded
    state :closed

    event :submit do
      transitions from: [:draft, :rejected, :reviewed, :accepted, :funding], to: :submitted
    end

    event :review do
      transitions from: :submitted, to: :reviewed
    end

    event :accept do
      transitions from: :reviewed, to: :accepted
    end

    event :reject do
      transitions from: [:reviewed, :submitted, :reviewed], to: :rejected
    end

    event :start_funding do
      transitions from: [:accepted, :submitted], to: :funding
    end

    event :request_signatures do
      transitions from: [:funding], to: :signatures
    end

    event :approve_signatures, after_commit: :set_approved_signatures_at do
      transitions from: [:signatures], to: :payments
    end

    event :close do
      transitions from: Deal.states.keys, to: :closed
    end
  end

  validate :property_details_must_be_valid_yaml

  def has_secondary_applicant?
    self.details['secondary_applicant'].present?
  end

  def applicant
    @applicant ||= Deal::Applicant.new(self.details['applicant'] || {})
  end

  def secondary_applicant
    @secondary_applicant ||= Deal::Applicant.new(self.details['secondary_applicant'] || {})
  end

  def guarantor
    @guarantor ||= Deal::Guarantor.new(self.details['guarantor'] || {})
  end

  def property
    @property ||= Deal::Property.new(self.details['property'] || {})
  end

  def terms
    @terms ||= Deal::Term.new(self.details['terms'] || {})
  end

  def loan_purpose
    @loan_purpose ||= Deal::LoanPurpose.new(self.details['loan_purpose'] || {})
  end

  def broker_fees
    @broker_fees ||= Deal::BrokerFee.new(self.details['broker_fees'] || [])
  end

  def credit_check
    @broker_fees ||= Deal::CreditCheck.new(self.details['credit_check'] || {})
  end

  def applicant=(applicant = {})
    self.details['applicant'] = applicant
  end

  def secondary_applicant=(secondary_applicant= {})
    self.details['secondary_applicant'] = secondary_applicant
  end

  def guarantor=(guarantor = {})
    self.details['guarantor'] = guarantor
  end

  def property=(property = {})
    self.details['property'] = property
  end

  def terms=(terms = {})
    self.details['terms'] = terms
  end

  def loan_purpose=(loan_purpose = {})
    self.details['loan_purpose'] = loan_purpose
  end

  def broker_fees=(broker_fees = [])
    self.details['broker_fees'] = broker_fees
  end

  def credit_check=(credit_check = {})
    self.details['credit_check'] = credit_check
  end

  def progress
    percentage = funding_progress

    { state:, percentage: }
  end

  scope :filter_status, ->(query) {
    if query.present?
      return all if query.eql? 'all'
      return where(state: :draft) if query.eql? 'draft'
      return where.not(state: [:draft, :rejected, :unfunded]) if query.eql? 'active'
      return where(state: [:rejected, :unfunded]) if query.eql? 'closed'
    else
      all
    end
  }

  scope :order_by, -> (query, order = 'asc') {
    sort_order = :asc
    sort_order = :desc unless order.eql? 'asc'
    if query.present?
      table = self.arel_table
      quoted_query = Arel::Nodes.build_quoted('id')
      quoted_query = Arel::Nodes.build_quoted('price') if query.eql? SelectOptions::SORT_DEALS[:amount]
      quoted_query = Arel::Nodes.build_quoted("approximate_closing_date") if query.eql? SelectOptions::SORT_DEALS[:closing_date]
      property_node = Arel::Nodes::InfixOperation.new('->', table[:details], Arel::Nodes.build_quoted('property'))
      sorting_key = Arel::Nodes::InfixOperation.new('->', property_node, quoted_query)

      order(sort_order == :desc ? Arel::Nodes::Descending.new(sorting_key) : Arel::Nodes::Ascending.new(sorting_key))
    else
      all
    end
  }

  scope :financing, -> {
    where("details->'terms'->>'public' = ?", 'true')
    .or(where("details->'terms'->>'public' = ?", "1"))
    .where(state: [:funding])
  }

  scope :closing, -> {
    where(
      "(details->'property'->>'approximate_closing_date')::date BETWEEN ? AND ?",
      Date.current,
      30.days.from_now
    )
  }

  scope :recently_closed, -> {
    where(
      "(details->'property'->>'approximate_closing_date')::date BETWEEN ? AND ?",
      Date.current - 30.days,
      Date.current
    )
  }

  scope :visibility, lambda { |query|
    if query.present?
      return where("details->'terms'->>'public' IN (?)", %w[1 true]) if query.eql? 'public'

      return where("details->'terms'->>'public' = ?", 'false')
    end

    all
  }

  scope :amount_range, ->(min, max) {
    min_amount = min.present? ? BigDecimal(min) : BigDecimal(0)
    max_amount = max.present? ? BigDecimal(max) : Float::MAX

    where("(details->'property'->>'price')::numeric BETWEEN ? AND ?", min_amount, max_amount)
  }

  scope :closing_by, ->(query) {
    return all unless query.present?

    days_from_now = 30.days.from_now
    days_from_now = 60.days.from_now if query.present? && query.eql?('60')
    days_from_now = 90.days.from_now if query.present? && query.eql?('90')
    days_from_now = 120.days.from_now if query.present? && query.eql?('90+')

    where(
      "(details->'property'->>'approximate_closing_date')::date BETWEEN ? AND ?",
      Date.current,
      days_from_now
    )
  }

  scope :interest_rate_range, ->(min, max) {
    min_amount = min.present? ? Float(min) : 0.0
    max_amount = max.present? ? Float(max) : Float::MAX

    where("(details->'terms'->>'interest_rate')::numeric BETWEEN ? AND ?", min_amount, max_amount)
  }

  scope :lenders_fee_range, ->(min, max) {
    min_amount = min.present? ? Float(min) : 0.0
    max_amount = max.present? ? Float(max) : Float::MAX

    where("(details->'terms'->>'lenders_fee')::numeric BETWEEN ? AND ?", min_amount, max_amount)
  }

  scope :province, ->(query) {
    return where("details->'property'->'address'->>'province' IN (?)", query) if query.present?

    all
  }

  def name
    property&.address&.full_address
  end

  def resized_property_picture
    property_picture.variant(resize: '160x160').processed
  end

  def target
    total_mortgage_principal
  end

  # Calculate total fees (lender fee + broker fees + notary fee)
  def total_fees
    return BigDecimal(0) if terms.mortgage_principal.blank? || terms.lenders_fee.blank?

    lender_fee_amount = (BigDecimal(terms.mortgage_principal) * BigDecimal(terms.lenders_fee)) / 100
    broker_fees_amount = BigDecimal(broker_fees.total) rescue 0
    notary_fee = BigDecimal(2000) # Standard notary fee

    lender_fee_amount + broker_fees_amount + notary_fee
  end

  # Total mortgage principal including all fees
  # This is what the borrower must repay and what investors fund
  def total_mortgage_principal
    return BigDecimal(0) if terms.mortgage_principal.blank?

    BigDecimal(terms.mortgage_principal) + total_fees
  end

  def commited_capital
    @_commited_capital||= deal_lenders.sum(:commited_capital)
  end

  def missing_signatures_total
    @_missing_signatures_total ||= deal_lenders.where(signed_at: nil).count
  end

  def total_investors
    @total_investors ||= deal_lenders.count
  end

  def total_investors_comitted
    @total_investors_comitted ||= deal_lenders.where('commited_capital > 0').count
  end

  def capital_commited?
    commited_capital >= BigDecimal(target)
  end

  def funding_progress
    return 0 if commited_capital.zero?

    ((commited_capital * 100) / BigDecimal(target)).round(2)
  end

  def funding_completed?
    funding_progress >= 100
  end

  def lender_commited?(user)
    !deal_lenders.where(lender: user).where('commited_capital > 0').empty?
  end

  def total_signatures
    deal_lenders.where.not(signed_at: nil).count
  end

  def GSR
    total_income = 0
    total_income += applicant.employer.income.total / 12
    total_income += secondary_applicant.employer.income.total / 12 if has_secondary_applicant? && secondary_applicant.has_employer?

    return 99 unless total_income.positive?

    total_cost = monthly_cost + applicant.monthly_mortgage_payment
    total_cost += secondary_applicant.monthly_mortgage_payment if has_secondary_applicant?
    property.mortgages.each { |mortgage| total_cost += BigDecimal(mortgage.monthly_payment) } if property.mortgages.present?

    (total_cost / total_income) * 100
  end

  def LVR
    # Use total mortgage principal (including all fees) for LTV calculation
    loan_total = total_mortgage_principal

    if property.mortgages.present?
      if terms.type == 'Refinance'
        size = property.mortgages.count - 1
        property.mortgages.take(size >= 0 ? size : 0).each do |mortgage|
          loan_total += BigDecimal(mortgage.amount_due)
        end
      else
        property.mortgages.each do |mortgage|
          loan_total += BigDecimal(mortgage.amount_due)
        end
      end
    end

    existing_mortgage = 0
    if terms.type != 'Refinance'
      existing_mortgage = applicant.mortgage_liabilities
      existing_mortgage += secondary_applicant.mortgage_liabilities if has_secondary_applicant?
    end

    (BigDecimal(loan_total) / BigDecimal(property.price)) * 100
  end

  def TDSR
    total_income = 0;
    total_income += applicant.employer.income.total / 12
    total_income += secondary_applicant.employer.income.total / 12 if has_secondary_applicant? && secondary_applicant.has_employer?

    return 99 unless total_income.positive?

    total_cost = monthly_cost + applicant.monthly_mortgage_payment
    total_cost += secondary_applicant.monthly_mortgage_payment if has_secondary_applicant?
    property.mortgages.each { |mortgage| total_cost += BigDecimal(mortgage.monthly_payment) } if property.mortgages.present?

    total_cost += applicant.liabilities.total_monthly_debt_obligations
    total_cost += secondary_applicant.liabilities.total_monthly_debt_obligations if has_secondary_applicant?

    (total_cost / total_income) * 100
  end

  def monthly_cost
    loan_total = BigDecimal(terms.mortgage_principal)
    # Lender's fee should not be included in monthly payment for GDS/TDS calculations
    # The lender's fee is a one-time upfront cost, not part of the monthly debt service
    # loan_total *= (BigDecimal(terms.lenders_fee) / 100) + 1 if terms.lenders_fee.to_f.positive?

    # n = Amortization periods in months
    n = terms.amortization_period_to_months[terms.amortization_period]

    if terms.interest_rate.to_f.positive?
      # r = Monthly interest rate
      r = (BigDecimal(terms.interest_rate) / 100) / 12

      if terms.amortization_period.eql? 'Interest Only'
        r * loan_total
      else
        rate = Rate.new(BigDecimal(terms.interest_rate) / 100, :apy, duration: n)
        amortization = Amortization.new(loan_total, rate)

        amortization.payment.abs
      end
    else
      return 0 if n.nil?

      rate = Rate.new(0.01, :apy, duration: n)
      amortization = Amortization.new(loan_total, rate)

      amortization.payment.abs
    end
  end

  def interest_calculated
    BigDecimal(target) * BigDecimal(terms.interest_rate) * BigDecimal(terms.terms.to_i)
  end

  def closing_date
    property&.approximate_closing_date
  end

  def maturity_date
    closing_date.to_date + terms.terms.to_i.months
  end

  def change_to_private!
    self.terms = self.terms.serialize.merge({ public: "private" })
    save
  end

  def change_to_public!
    self.terms = self.terms.serialize.merge({ public: true })
    save
  end

  def invitable?
    funding?
  end

  def end_date
    return if approved_signatures_at.nil?

    approved_signatures_at + terms.terms.to_i.months
  end

  def available_for_lender?(lender)
    terms.is_public? || lenders.pluck(:id).include?(lender.id)
  end

  def under_criminal_rate?
    apr > 45
  end

  def parsed_property_details
    @_parsed_property_details ||= YAML.safe_load(property_details)
  end

  def analize_documents!
    AiDocumentPool.find_or_create_by!(deal_id: self.id, status: AiDocumentPool::PROCESSING)
    AiDocumentAnalyzerJob.perform_later({ 'deal_id' => self.id })
  end

  private

  def clear_rejection
    self.rejected_actor_id = nil
    self.rejected_description = ''
  end

  def set_approved_signatures_at
    self.approved_signatures_at = Time.now
    save!
  end

  def generate_url_code
    self.url_code = loop do
      random_code = SecureRandom.alphanumeric.upcase.gsub(/\d/, '')
      break random_code unless Deal.exists?(url_code: random_code)
    end
  end

  def apr
    return @apr unless @apr.nil?

    interest_rate = (BigDecimal(terms.interest_rate) / 100)
    lenders_fee_percentage = (BigDecimal(terms.lenders_fee) / 100)
    notary_fee = 2000
    loan_amount = BigDecimal(terms.mortgage_principal)
    broker_fees_percentage = (BigDecimal(broker_fees.total) * 100) / loan_amount
    term_months = terms.terms.to_i

    interest_rate_adjusted = if term_months < 12
      (interest_rate / 12.0) * term_months
    else
      interest_rate
    end

    @apr = interest_rate_adjusted + lenders_fee_percentage + broker_fees_percentage + (notary_fee / loan_amount * 100)
  rescue
    0
  end

  def property_details_must_be_valid_yaml
    return unless property_details.present?

    begin
      YAML.safe_load(property_details)
    rescue Psych::SyntaxError
      errors.add(:property_details, "Must be valid YAML")
    end
  end
end
