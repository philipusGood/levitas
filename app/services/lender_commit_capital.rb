class LenderCommitCapital
  attr_reader :lender, :deal, :amount

  def initialize(lender:, deal:, amount: nil)
    @lender = lender
    @deal = deal
    @amount = amount || 0
  end

  def call
    if deal_lender.present?
      deal_lender.commited_capital = total_capital
      deal_lender.save!
      DealMailer.lender_committed_capital(deal: @deal, lender: @lender, amount: @amount).deliver_later

      if @deal.reload.funding_completed?
        DealMailer.funding_completed(deal: @deal).deliver_later
      end

      return true
    end

    false
  end

  private
  def deal_lender
    @deal_lender ||= DealLender.find_or_initialize_by(deal: @deal, lender: @lender)
  end

  def total_capital
    deal_lender.commited_capital + BigDecimal(@amount)
  end
end
