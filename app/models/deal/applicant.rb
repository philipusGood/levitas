class Deal::Applicant < Deal::Base

  attr_accessor :title,
    :first_name,
    :last_name,
    :birth_date,
    :social_insurance_number,
    :email,
    :phone_number,
    :address,
    :employer,
    :assets,
    :liabilities,
    :credit_score,
    :credit_score_source,
    :credit_score_report_date

  validates :title, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :birth_date, presence: true, format: { with: /\A\d{4}-\d{2}-\d{2}\z/, message: "must be in the format of YYYY-MM-DD" }
  validates :social_insurance_number, format: { with: /\A(\d{3}-\d{3}-\d{3}|\d{9})\z/, message: "must be in the format of 999-999-999 or 999888777" }, if: -> { social_insurance_number.present? }
  validates :email, presence: true, format: { with: Devise::email_regexp }
  validates :phone_number, presence: true

  validate :validate_address
  validate :birth_date_must_be_18_years_ago

  def initialize(attributes = {})
    attributes = attributes.with_indifferent_access if attributes.respond_to?(:with_indifferent_access)

    @title = attributes[:title]
    @first_name = attributes[:first_name]
    @last_name = attributes[:last_name]
    @birth_date = attributes[:birth_date]
    @social_insurance_number = attributes[:social_insurance_number]
    @email = attributes[:email]
    @phone_number = attributes[:phone_number]
    @credit_score = attributes[:credit_score] || 0
    @credit_score_source = attributes[:credit_score_source]
    @credit_score_report_date = attributes[:credit_score_report_date]

    @employer = Deal::Employer.new(attributes[:employer] || {})
    @address = Deal::Address.new(attributes[:address] || {})
    @assets = Deal::Assets.new(attributes[:assets] || [])
    @liabilities = Deal::Liabilities.new(attributes[:liabilities] || {})
  end


  def serialize
    {
      title: title,
      first_name: first_name,
      last_name: last_name,
      birth_date: birth_date,
      social_insurance_number: social_insurance_number,
      email: email,
      phone_number: phone_number,
      address: address.serialize.compact,
      employer: employer.serialize.compact,
      assets: assets.serialize.compact,
      liabilities: liabilities.serialize.compact,
      credit_score: credit_score,
      credit_score_source: credit_score_source,
      credit_score_report_date: credit_score_report_date,
    }
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def short_full_name
    full_name.split(' ').map {|word| word[0] }.join('')
  end

  def liabilities_total
    balance_remaining = assets.real_state_with_mortage.map {|item| item.balance_remaining.to_f }.sum
    liabilities.total +  balance_remaining
  end

  def has_liabilities?
    return !liabilities_total.zero?
  end

  def has_debt_obligations?
    liabilities.debt_obligations.any?
  end

  def has_employer?
    return !employer.income.items.empty?
  end

  def monthly_mortgage_payment
    assets.real_state_with_mortage.map { |mortgage| mortgage.monthly_payment.to_f }.sum
  end

  def mortgage_liabilities
    assets.real_state_with_mortage.map { |mortgage| mortgage.balance_remaining.to_f }.sum
  end

  def all_valid?
    valid? && employer.valid? && address.valid? && assets.valid? && liabilities.valid?
  end

  private

  def validate_address
    unless address.valid?
      address.errors.full_messages.each do |message|
        errors.add(:base, "Address #{message}")
      end
    end
  end

  def birth_date_must_be_18_years_ago
    return unless birth_date.present?

    begin
      parsed_date = birth_date.is_a?(Date) ? birth_date : Date.parse(birth_date.to_s)
      if parsed_date > 18.years.ago.to_date
        errors.add(:birth_date, "must be at least 18 years ago.")
      end
    rescue Date::Error
      errors.add(:birth_date, "is not a valid date")
    end
  end

end
