class Deal::Guarantor < Deal::Base
  attr_accessor :confirmation,
    :title,
    :first_name,
    :last_name,
    :email,
    :phone_number,
    :address

  validates :title, presence: true, if: :confirmed?
  validates :first_name, presence: true, if: :confirmed?
  validates :last_name, presence: true, if: :confirmed?
  validates :phone_number, presence: true, if: :confirmed?
  validates :email, presence: true, format: { with: Devise::email_regexp }, if: :confirmed?
  validate :validate_address, if: :confirmed?

  def initialize(attributes = {})
    attributes = attributes.with_indifferent_access if attributes.respond_to?(:with_indifferent_access)

    @confirmation = attributes[:confirmation]
    @title = attributes[:title]
    @first_name = attributes[:first_name]
    @last_name = attributes[:last_name]
    @email = attributes[:email]
    @phone_number = attributes[:phone_number]

    @address = Deal::Address.new(attributes[:address] || {})
  end

  def name
    "#{first_name} #{last_name}"
  end

  def serialize
    {
      confirmation: confirmation,
      title: title,
      first_name: first_name,
      last_name: last_name,
      email: email,
      phone_number: phone_number,
      address: address.serialize.compact,
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

  def confirmed?
    serialize[:confirmation].to_s == "1" || serialize[:confirmation].to_s == "true"
  end
end
