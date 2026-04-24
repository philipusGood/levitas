class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_profile_setup!

  helper_method :performance

  def index
    @deals_view = params.present? && params[:view].eql?('table') ? 'table' : 'card'
    @user_deals = DealFetcher.new(user: current_user, params: params).call
    @deals = @user_deals.filter_status(params[:filter]).order_by(params[:sort], params[:order]).page(params[:page])
    @status = DealStatuses.new(user: current_user).call

    if current_user.lender?
      @lender_performance = LenderPerformanceCalculator.new(user: current_user).call
    end

    PosthogEventJob.perform_async('View Dashboard', current_user.email, {
      'role' => current_user.role
    })
  end

  def performance
    @performance ||= PerformanceCalculator.new(user: current_user, deals_scope: @user_deals)
  end

  def filters_sidebar
    @deals_view = params.present? && params[:view].eql?('table') ? 'table' : 'card'

    PosthogEventJob.perform_async('Filters Sidebar', current_user.email, {
      'role' => current_user.role
    })

    render turbo_stream: turbo_stream.update('sidebar_content',
                                             partial: '/deals/partials/filters',
                                             locals: {
                                               action_url: dashboard_index_path(request.query_parameters)
                                             })
  end
end
