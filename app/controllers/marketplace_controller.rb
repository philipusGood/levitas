class MarketplaceController < ApplicationController
  layout :set_layout
  before_action :ensure_profile_setup!, if: :user_signed_in?
  before_action :find_deal, only: [:show]

  def index
    if user_signed_in?
      @deals_view = params.present? && params[:view].eql?('table') ? 'table' : 'card'
      @visibility = params.present? && params['visibility'] == 'private' ? 'Private' : 'Public'
      @user_deals = DealFetcher.new(user: current_user, params: params).call
      @deals = @user_deals.where.not(state: [:draft]).filter_status(params[:filter]).order_by(params[:sort], params[:order]).page(params[:page])

      PosthogEventJob.perform_async('View Marketplace', current_user.email, {
        'visibility' => params[:visibility],
        'view_type' => params[:view]
      })
    else
      @deals = Deal.financing
    end
  end

  def show
    @deal_cycle_partial = "broker_funding"
    @deal_flow_partial = "lender_funding"

    redirect_to marketplace_index_path if !@deal.funding? || !@deal.terms.is_public?
  end

  def filters_sidebar
    @visibility = params.present? && params['visibility'] == 'private' ? 'private' : 'public'
    @deals_view = params.present? && params[:view].eql?('table') ? 'table' : 'card'

    render turbo_stream: turbo_stream.update('sidebar_content', partial: '/deals/partials/filters')
  end

  private

  def find_deal
    @deal = if params[:id].to_i.to_s == params[:id]
      Deal.find(params[:id])
    else
      Deal.find_by!(url_code: params[:id])
    end
  end

  def set_layout
    if user_signed_in?
      'application'
    else
      'minimal'
    end
  end
end
