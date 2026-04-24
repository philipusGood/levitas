class Deal::Liabilities < Deal::Base
  attr_accessor :taxes,
  :child_support,
  :bankruptcy,
  :bankruptcy_status,
  :expected_release_date,
  :cost_of_release,
  :debt_obligations

  validates :taxes, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :child_support, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :bankruptcy, presence: true
  validates :bankruptcy_status, presence: true, if: :bankruptcy?
  validates :expected_release_date, presence: true, format: { with: /\A\d{4}-\d{2}-\d{2}\z/ }, if: :bankruptcy_active?
  validates :cost_of_release, presence: true, numericality: { greater_than_or_equal_to: 0 }, if: :bankruptcy_active?
  validate :validate_debt_obligations

  class DebtObligation
    include ActiveModel::Model

    attr_accessor :id,
    :type,
    :balance_remaining,
    :monthly_payment

    validates :type, presence: true
    validates :balance_remaining, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :monthly_payment, presence: true

    def initialize(attributes = {})
      @type = attributes[:type]
      @balance_remaining = attributes[:balance_remaining]
      @monthly_payment = attributes[:monthly_payment]
    end

    def serialize
      {
        type: type,
        balance_remaining: balance_remaining,
        monthly_payment: monthly_payment,
      }
    end
  end

  def initialize(attributes = {})
    attributes = attributes.with_indifferent_access if attributes.respond_to?(:with_indifferent_access)

    @taxes = attributes[:taxes]
    @child_support = attributes[:child_support]
    @bankruptcy = attributes[:bankruptcy]
    @bankruptcy_status = attributes[:bankruptcy_status]
    @expected_release_date = attributes[:expected_release_date]
    @cost_of_release = attributes[:cost_of_release]
    @debt_obligations = (attributes[:debt_obligations] || []).map { |attrs| DebtObligation.new(attrs) }
  end

  def serialize
    {
      taxes: taxes,
      child_support: child_support,
      bankruptcy: bankruptcy,
      debt_obligations: debt_obligations.map(&:serialize),
    }.merge!(bankruptcy_fields)
  end

  def bankruptcy?
    bankruptcy == "true"
  end

  def bankruptcy_active?
    bankruptcy? &&  bankruptcy_status == "true"
  end

  def total
    total = taxes.to_f + (child_support.to_f * 12)
    if bankruptcy_active?
      total = total + cost_of_release.to_f
    end

    total + total_debt_obligations
  end

  def total_debt_obligations
    debt_obligations.map { |debt_obligation| debt_obligation.balance_remaining.to_f }.sum
  end

  def total_monthly_debt_obligations
    debt_obligations.map { |debt_obligation| debt_obligation.monthly_payment.to_f }.sum
  end

  private

  def bankruptcy_fields
    data = {}
    data.merge!({ bankruptcy_status: bankruptcy_status }) if bankruptcy?
    data.merge!({ expected_release_date: expected_release_date, cost_of_release: cost_of_release }) if bankruptcy_active?

    data
  end

  def validate_debt_obligations
    valid_items = debt_obligations.all? { |item| item.valid? }
    unless valid_items
      errors.add(:base, "Debt Related Obligations contains invalid items") end
  end
end
