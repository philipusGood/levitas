class BrokersFetcher
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def call
    raise 'User is not lender' unless user.lender?

    lender.broker_lenders.with_brokers
  end

  private
  def lender
    @lender ||= Lender.find_by(id: user.id)
  end
end
