class Deal::BrokerFee < Deal::Base
  attr_accessor :items

  validate :validates_items

  class Item
    include ActiveModel::Model
    attr_accessor :id, :broker_name, :amount_fee, :default

    validates :broker_name, presence: true
    validates :amount_fee, presence: true, numericality: { greater_than_or_equal_to: 0 }

    def initialize(attributes = {})
      attributes = attributes.with_indifferent_access if attributes.respond_to?(:with_indifferent_access)

      @broker_name = attributes[:broker_name]
      @amount_fee = attributes[:amount_fee]
      @default = attributes[:default]
    end
  end

  def initialize(items = [])
    @items = items.map { |item| Item.new(item) }
  end

  def build_default_item(attributes)
    items << Item.new(attributes)
  end

  def serialize
    items.map do |item|
      {
        broker_name: item.broker_name,
        amount_fee: item.amount_fee,
        default: item.default
      }
    end
  end

  def total
    items.map { |item| BigDecimal(item.amount_fee) }.sum
  end

  private
  def validates_items
    valid_items = items.all? { |item| item.valid? }
    unless valid_items
      errors.add(:base, "Fees contains invalid items")
    end
  end
end
