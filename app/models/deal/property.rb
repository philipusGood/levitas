class Deal::Property < Deal::Base
  attr_accessor :type,
  :mls_number,
  :price,
  :approximate_closing_date,
  :mortgages,
  :address

  validates :type, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :approximate_closing_date, presence: true, format: { with: /\A\d{4}-\d{2}-\d{2}\z/ }

  validate :validate_address
  validate :validate_mortgages


  class Mortgage
    include ActiveModel::Model

    attr_accessor :id,
    :institution,
    :monthly_payment,
    :amount_due,
    :end_date

    validates :institution, presence: true
    validates :monthly_payment, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :amount_due, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :end_date, presence: true, format: { with: /\A\d{4}-\d{2}-\d{2}\z/ }

    def initialize(attributes)
      @institution = attributes[:institution]
      @monthly_payment = attributes[:monthly_payment]
      @amount_due = attributes[:amount_due]
      @end_date = attributes[:end_date]
    end

    def serialize
      {
        institution: institution,
        monthly_payment: monthly_payment,
        amount_due: amount_due,
        end_date: end_date,
      }
    end
  end

  def initialize(attributes = {})
    attributes = attributes.with_indifferent_access if attributes.respond_to?(:with_indifferent_access)

    @type = attributes[:type]
    @mls_number = attributes[:mls_number]
    @price = attributes[:price]
    @approximate_closing_date = attributes[:approximate_closing_date]
    @mortgages = (attributes[:mortgages] || []).map { |mortgages_attributes| Mortgage.new(mortgages_attributes) }

    @address = Deal::Address.new(attributes[:address] || {})
  end

  def serialize
    {
      type: type,
      mls_number: mls_number,
      price: price,
      approximate_closing_date: approximate_closing_date,
      mortgages: mortgages.map(&:serialize),
      address: address.serialize
    }
  end

  private

  def validate_address
    unless address.valid?
      address.errors.full_messages.each do |message|
        errors.add(:base, "Address #{message}")
      end
    end
  end

  def approximate_closing_date_must_be_in_future
    if approximate_closing_date.present?
      closing_date = Date.strptime(approximate_closing_date, "%Y-%m-%d")
      if closing_date <= Date.today
        errors.add(:approximate_closing_date, "must be in the future")
      end
    end
  rescue ArgumentError
    errors.add(:approximate_closing_date, "is not a valid date")
  end

  def validate_mortgages
    valid_items = mortgages.all? { |item| item.valid? }
    unless valid_items
      errors.add(:base, "Mortages contains invalid items") end
  end
end
