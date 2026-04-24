class Deal::Income < Deal::Base
  attr_accessor :items

  validate :validates_items

  class Item
    include ActiveModel::Model
    attr_accessor :id, :type, :period, :amount

    validates :type, presence: true
    validates :period, presence: true
    validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

    INCOME_PERIOD = {
      "Weekly": 52,
      "Bi-Weekly (Every Two Weeks)": 26,
      "Semi-Monthly (Twice a Month)": 24,
      "Monthly": 12,
      "Quarterly": 4,
      "Semi-Annually (Every Six Months)": 2,
      "Annually": 1
    }

    def initialize(attributes = {})
      attributes = attributes.with_indifferent_access if attributes.respond_to?(:with_indifferent_access)

      @type = attributes[:type]
      @period = attributes[:period]
      @amount = attributes[:amount]
    end

    def total
      INCOME_PERIOD[period.to_sym].to_f * amount.to_f
    end
  end

  def initialize(items = [])
    @items = items.select { |item| item.is_a?(Hash) || item.is_a?(ActionController::Parameters) }.map { |item| Item.new(item) }
  end

  def build_default_item
    items << Item.new
  end

  def serialize
    items.map do |item|
      {
        type: item.type,
        period: item.period,
        amount: item.amount
      }
    end
  end

  def total
    items.map(&:total).sum
  end

  private

  def validates_items
    valid_items = items.all? { |item| item.valid? }
    unless valid_items
      errors.add(:base, "Incomes contains invalid items")
    end
  end
end
