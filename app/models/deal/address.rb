class Deal::Address < Deal::Base
  include PostalCodeFormatter
  attr_accessor :street,
    :unit,
    :city,
    :province,
    :country,
    :postal_code

  validates :street, presence: true
  validates :city, presence: true
  validates :province, presence: true
  validates :country, presence: true
  validates :postal_code, presence: true, format: { with: /\A[ABCEGHJKLMNPRSTVXYabceghjklmnprstvxy]{1}\d{1}[A-Za-z]{1}[ -]*\d{1}[A-Za-z]{1}\d{1}\z/, message: "must be a valid Canadian postal code" }


  def initialize(attributes = {})
    attributes.each do |key, value|
      send("#{key}=", value) if respond_to?("#{key}=")
    end
  end

  def serialize
    {
      street: street,
      unit: unit,
      city: city,
      province: province,
      country: country,
      postal_code: postal_code
    }
  end

  def full_address
    return "" unless street.present?

    if unit.present?
      "#{unit}-#{street}, #{city}, #{province}, #{format_postal_code(postal_code)}"
    else
      "#{street}, #{city}, #{province}, #{format_postal_code(postal_code)}"
    end
  end

  def province_abbreviation
    {
      'AB' => 'Alberta',
      'BC' => 'British Columbia',
      'MB' => 'Manitoba',
      'NB' => 'New Brunswick',
      'NL' => 'Newfoundland and Labrador',
      'NS' => 'Nova Scotia',
      'NT' => 'Northwest Territories',
      'NU' => 'Nunavut',
      'ON' => 'Ontario',
      'PE' => 'Prince Edward Island',
      'QC' => 'Quebec',
      'SK' => 'Saskatchewan',
      'YT' => 'Yukon'
    }.freeze.key(province)
  end
end
