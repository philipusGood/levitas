class LenderPerformanceCalculator
  attr_reader :deals, :total_invested_capital, :total_committed_capital, :irr, :cashflows

  def initialize(user:)
    @user = user
    @total_committed_capital = 0
    @total_invested_capital = 0
    @irr = 0
    @cashflows = 0
  end

  def call
    raise "User is not a lender" unless @user.lender?

    calculate_irr!
    calculate_total_invested_capital!
    calculate_total_committed_capital!

    self
  end

  private
  def committed_lender_deals
    DealLender.joins(:deal).where(lender: Current.user).where(deals: { state: ["funding"]})
  end

  def payments_lender_deals
    DealLender.joins(:deal).where(lender: Current.user).where(deals: { state: ["payments"]})
  end

  def calculate_total_invested_capital!
    @total_invested_capital = payments_lender_deals.map(&:commited_capital).sum
  end

  def calculate_total_committed_capital!
    @total_committed_capital = committed_lender_deals.map(&:commited_capital).sum
  end

  def mortgages
    @mortgages ||= payments_lender_deals.map do |lender_deal|
      {
        id: lender_deal.deal.id,
        start_date: lender_deal.deal.approved_signatures_at.to_s,
        end_date: lender_deal.deal.end_date.to_s,
        interest_rate: lender_deal.deal.terms.interest_rate.to_f / 100,
        lenders_fee: lender_deal.deal.terms.lenders_fee.to_f / 100,
        money_invested: lender_deal.commited_capital
      }
    end
  end

  def calculate_irr!
    aggregated_cashflows =  calculate_aggregated_cashflows(mortgages)
    invested = calculated_invested_capital(mortgages)
    cashflows = calculate_totalized_cashflows(aggregated_cashflows, invested)
    @irr = (calculate_irr(cashflows) / 100).to_f.round(2)
  end

  def calculate_aggregated_cashflows(mortgages)
    aggregated_cashflows = Array.new(12, 0.0)

    mortgages.each do |m|
      start_date = Date.parse(m[:start_date])
      end_date = Date.parse(m[:end_date])
      interest_rate = m[:interest_rate]
      lenders_fee = m[:lenders_fee]
      invested_capital = m[:money_invested]
      monthly_cash_produced = (interest_rate / 12.0) * (invested_capital * (1 + lenders_fee))
      puts monthly_cash_produced

      (0...12).each do |month|
        cashflow_month = start_date >> month

        if cashflow_month >= start_date && cashflow_month <= end_date
          aggregated_cashflows[month] += monthly_cash_produced

          # Add principal back if the term ends in this month
          aggregated_cashflows[month] += invested_capital if cashflow_month == end_date
        end
      end
    end

    aggregated_cashflows
  end

  def calculated_invested_capital(mortgages)
    invested_capital = 0.0
    mortgages.each do |m|
      invested_capital += m[:money_invested]
    end

    invested_capital
  end

  def calculate_totalized_cashflows(aggregated_cashflows, invested_capital)
    aggregated_cashflows.unshift(-invested_capital)
    aggregated_cashflows[-1] = aggregated_cashflows[-1] + invested_capital

    aggregated_cashflows
  end


  def calculate_irr(cash_flows, epsilon = 0.00001, max_iterations = 5000)
    lower_bound = 0.00
    upper_bound = 0.50

    iterations = 0

    while (upper_bound - lower_bound) > epsilon && iterations < max_iterations
      iterations += 1
      mid_rate = (lower_bound + upper_bound) / 2.0
      npv = cash_flows.each_with_index.sum { |cf, i| cf / ((1 + mid_rate) ** i) }

      if npv > 0
        lower_bound = mid_rate
      else
        upper_bound = mid_rate
      end
    end

    raise 'IRR calculation did not converge' if iterations == max_iterations

    (lower_bound + upper_bound) / 2.0
  end
end
