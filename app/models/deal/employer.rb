class Deal::Employer < Deal::Base

  attr_accessor :name,
  :job_title,
  :industry_type,
  :employment_type,
  :duration_years,
  :duration_months,
  :phone_number,
  :ext,
  :fax,
  :email,
  :address,
  :income

  validates :duration_years, numericality: { greater_than_or_equal_to: 0 }
  validates :duration_months, numericality: { greater_than_or_equal_to: 0 }

  validate :validate_income


  def initialize(attributes = {})
    attributes = attributes.with_indifferent_access if attributes.respond_to?(:with_indifferent_access)

    @name = attributes[:name]
    @job_title = attributes[:job_title]
    @industry_type = attributes[:industry_type]
    @employment_type = attributes[:employment_type]
    @duration_years = attributes[:duration_years] || 0
    @duration_months = attributes[:duration_months] || 0
    @phone_number = attributes[:phone_number]
    @ext = attributes[:ext]
    @fax = attributes[:fax]
    @email = attributes[:email]

    @address = Deal::Address.new(attributes[:address] || {})
    @income = Deal::Income.new(attributes[:income] || [])
  end

  def serialize
    {
      name: name,
      job_title: job_title,
      industry_type: industry_type,
      employment_type: employment_type,
      duration_years: duration_years,
      duration_months: duration_months,
      phone_number: phone_number,
      ext: ext,
      fax: fax,
      email: email,
      address: address.serialize.compact,
      income: income.serialize.compact
    }
  end

  def duration
    time = []
    time << "#{duration_years} #{'Year'.pluralize(duration_years) }" unless duration_years.to_f.zero?
    time << "#{duration_months} #{'Month'.pluralize(duration_years) }" unless duration_months.to_f.zero?

    time.join(' ')
  end

  private

  def validate_address
    unless address.valid?
      address.errors.full_messages.each do |message|
        errors.add(:base, "Address #{message}")
      end
    end
  end

  def validate_income
    unless income.valid?
      income.errors.full_messages.each do |message|
        errors.add(:base, "Assets #{message}")
      end
    end
  end
end
