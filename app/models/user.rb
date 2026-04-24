require 'letter_avatar/has_avatar'

class User < ApplicationRecord
  include PostalCodeFormatter
  include LetterAvatar::HasAvatar
  include Flipper::Identifier

  attr_accessor :skip_password_validation, :accredited_investor

  devise :invitable, :database_authenticatable, :registerable, :recoverable, :rememberable,
         :validatable, :confirmable, :lockable, :timeoutable, :trackable

  enum role: { broker: 0, lender: 1, borrower: 2, admin: 3 }

  has_many :deals, dependent: :destroy
  has_many :notifications, dependent: :destroy

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [40, 40]
  end

  after_initialize :set_default_attributes
  before_save :set_default_attributes

  jsonb_accessor :profile,
    title: :string,
    first_name: :string,
    middle_name: :string,
    last_name: :string,
    birth_date: :string,
    phone_number: :string,
    address_street: :string,
    address_city: :string,
    address_province: :string,
    address_unit: :string,
    address_country: :string,
    address_postal_code: :string,
    corporation_name: :string

  validates :title, presence: true, on: :account_setup
  validates :first_name, presence: true, on: :account_setup
  validates :last_name, presence: true, on: :account_setup
  validates :birth_date, presence: true, format: { with: /\A\d{4}-\d{2}-\d{2}\z/ }, on: :account_setup
  validates :phone_number, presence: true, on: :account_setup
  validates :address_street, presence: true, on: :account_setup
  validates :address_city, presence: true, on: :account_setup
  validates :address_province, presence: true, on: :account_setup
  validates :address_country, presence: true, on: :account_setup
  validates :address_postal_code, presence: true, on: :account_setup
  validates :accredited_investor, acceptance: true, on: :account_setup, if: :lender?

  validate :password_complexity

  scope :search, ->(query) {
    if query.present?
      where("email ILIKE :query", query: "%#{query}%")
      .or(where("profile ->> 'first_name' ILIKE :query", query: "%#{query}%"))
      .or(where("profile ->> 'last_name' ILIKE :query", query: "%#{query}%"))
    else
      all
    end
  }

  def pending_account_setup?
    profile.empty? || !valid?(:account_setup)
  end

  def name
    full_name
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def invited?
    invitation_sent_at.present?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def full_address
    if address_unit.empty?
      "#{address_street}, #{address_city}, #{address_province}, #{format_postal_code(address_postal_code)}"
    else
    "#{address_unit}-#{address_street}, #{address_city}, #{address_province}, #{format_postal_code(address_postal_code)}"
    end
  end

  def short_full_name
    full_name.split(' ').map {|word| word[0] }.join('')
  end

  def as_lender
    self.becomes(Lender)
  end

  def as_broker
    self.becomes(Broker)
  end

  def flipper_id
    self.id
  end

  def lender?
    role == 'lender'
  end

  def funded?(deal)
    deal.lenders.include?(self)
  end

  def url_for_avatar
    return "" if Rails.env.test?

    avatar_url(40)
  end

  private

  def set_default_attributes
    self.role ||= 'broker'
    self.profile ||= {}
  end

  def password_complexity
    return if password.blank? || password =~ /(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-])/
    errors.add :password, 'Complexity requirement not met. Please use: 1 uppercase, 1 lowercase, 1 digit and 1 special character'
  end
end
