class BrokerLender < ApplicationRecord
  belongs_to :broker
  belongs_to :lender

  validates_uniqueness_of :lender_id, scope: :broker_id

  enum status: {
    pending: 1,
    accepted: 2,
  }

  class << self
    def with_brokers
      joins(:broker)
    end
  end
end
