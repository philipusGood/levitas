class PerformanceCalculator
  attr_reader :user, :deals_scope

  def initialize(user:, deals_scope:)
    @user = user
    @deals_scope = deals_scope
  end

  def total_active_deals
    if @user.lender?
      return deals_scope.joins(:deal_lenders)
                        .where.not(state: %i[draft rejected closed])
                        .where('deal_lenders.commited_capital > ?', 0)
                        .count
    end
    deals_scope.where.not(state: %i[draft rejected closed]).count
  end

  def status
    DealStatuses.new(user: user).call
  end

  def closing_deals
    Deal.closing.where(user: user).count
  end

  def total_mortage_value
    BrokerMortageCalculator.new(deals: deals_scope).call
  end

  def closing
    Deal.closing.where(user: user).count
  end

  def fees_generated
    Deal.where(user: user).recently_closed.map do |deal|
      deal.broker_fees.total
    end.sum.to_s
  end
end
