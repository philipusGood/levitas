module PostalCodeFormatter
  extend ActiveSupport::Concern

  private
  
  def format_postal_code(postal_code)
    postal_code.present? ? postal_code.upcase.gsub(/\A(\w{3})(\w{3})\z/, '\1 \2') : postal_code
  end
end