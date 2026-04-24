class DealFetcher
  attr_reader :user, :params

  def initialize(user:, params: nil)
    @user = user
    @params = params
  end

  def call
    case @user.role
    when 'admin'
      deals = admin_deals
    when 'broker'
      deals = broker_deals
    when 'lender'
      deals = lender_deals
    end

    return filter_by_params(deals) if params.present? && params[:commit]

    deals
  end

  private

  def admin_deals
    Deal.all
  end

  def broker_deals
    user.deals
  end

  def lender_deals
    if params.present? && params[:visibility] == 'public'
      Deal.financing
    else
      Deal.joins(:deal_lenders).where({deal_lenders: { lender: user }})
    end
  end

  def filter_by_params(deals)
    postal_to_province = {
      'AB' => 'Alberta',
      'BC' => 'British Columbia',
      'MB' => 'Manitoba',
      'NB' => 'New Brunswick',
      'NL' => 'Newfoundland and Labrador',
      'NS' => 'Nova Scotia',
      'NT' => 'Northwest Territories',
      'NU' => 'Nunavut',
      'ON' => 'Ontario',
      'PE' => 'Prince Edward Island',
      'QC' => 'Quebec',
      'SK' => 'Saskatchewan',
      'YT' => 'Yukon'
    }.freeze

    selected_provices = !params[:provinces].nil? ? params[:provinces].map { |province| postal_to_province[province] } : []

    deals.amount_range(params[:amount_min], params[:amount_max])
         .closing_by(params[:closing_date])
         .interest_rate_range(params[:interest_rate_min], params[:interest_rate_max])
         .lenders_fee_range(params[:lenders_fee_min], params[:lenders_fee_max])
         .province(selected_provices)
  end
end
