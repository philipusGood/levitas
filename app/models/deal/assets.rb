class Deal::Assets < Deal::Base
  attr_accessor :items

  validate :validates_items

  class Item
    include ActiveModel::Model

    attr_accessor :id,
    :type,
    :description,
    :amount,
    :mortage,
    :property_type,
    :balance_remaining,
    :monthly_payment

    validates :type, presence: true
    validates :description, presence: true
    validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :mortage, presence: true, if: :real_state?
    validates :property_type, presence: true, if: :has_mortage?
    validates :balance_remaining, presence: true, numericality: { greater_than_or_equal_to: 0 }, if: :has_mortage?
    validates :monthly_payment, presence: true, if: :has_mortage?

    def initialize(attributes = {})
      attributes = attributes.with_indifferent_access if attributes.respond_to?(:with_indifferent_access)

      @type = attributes[:type]
      @description = attributes[:description]
      @amount = attributes[:amount]
      @mortage = attributes[:mortage]
      @property_type = attributes[:property_type]
      @balance_remaining = attributes[:balance_remaining]
      @monthly_payment = attributes[:monthly_payment]
    end

    def real_state?
      type == 'Real Estate'
    end

    def has_mortage?
      real_state? && (mortage == "true"  || mortage == "1")
    end
  end

  def initialize(items = [])
    @items = items.map { |item| Item.new(item) }
  end

  def build_default_item
    items << Item.new
  end

  def serialize
    items.map { |item| serialize_item(item) }
  end

  def total
    items.map { |item| item.amount.to_f }.sum
  end

  def real_state_with_mortage
    items.filter { |item| item.has_mortage? }
  end

  private

  def serialize_item(item)
    data = {
        type: item.type,
        description: item.description,
        amount: item.amount
    }

    data.merge!({ mortage: item.mortage }) if item.real_state?
    data.merge!({
      balance_remaining: item.balance_remaining,
      property_type: item.property_type,
      monthly_payment: item.monthly_payment
    }) if item.has_mortage?

    data
  end

  def validates_items
    valid_items = items.all? { |item| item.valid? }
    unless valid_items
      errors.add(:base, "Asset contains invalid items")
    end
  end
end
