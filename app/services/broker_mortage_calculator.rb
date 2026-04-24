class BrokerMortageCalculator
  attr_reader :deals

  def initialize(deals:)
    @deals = deals
  end

  def call
    total_mortage_value.to_s
  end

  private
  def total_mortage_value
    deals.map { |deal| BigDecimal(deal.target || 0) }.sum
  end
end
