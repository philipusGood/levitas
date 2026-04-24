class Deals::LendersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_profile_setup!
  before_action :find_deal, except: [:selected_lenders_counter, :invite_lender_add]
  before_action :find_lender, only: [:destroy, :commit_capital, :send_signature_reminder, :sign_deal]

  def create
    return unless DealInviter.new(deal: @deal, emails: lenders_params[:lenders]).call

    render partial: '/partials/modals/invite_lenders/invite_success'
  end

  def destroy
    deal_lender = DealLender.find_by(
      deal: @deal,
      lender_id: params[:id]
    )

    if deal_lender
      deal_lender.destroy

      redirect_to deal_path(@deal), notice: 'Lender was removed from deal'
    else
      redirect_to deal_path(@deal), alert: 'Lender does not exist in the deal'
    end
  end

  def commit_capital
    if LenderCommitCapital.new(deal: @deal, lender: @lender, amount: params[:amount]).call
      render partial: '/partials/modals/lender_funding/success_investment',
             locals: { investment: view_context.number_to_currency_without_cents(params[:amount]) }
    else
      redirect_to deal_path(@deal), notice: 'Lender does not exist in the deal'
    end
  end

  def send_signature_reminder
    deal_lender = DealLender.find_by(lender: @lender, deal: @deal)

    if deal_lender && deal_lender.signed_at.nil?
      DealMailer.lender_signature_reminder(deal: @deal, lender: @lender, amount: deal_lender.commited_capital.to_s).deliver_later
      NotificationJob.perform_later({
        "content" => I18n.t('notifications.lender_signature_reminder', amount: deal_lender.commited_capital.to_s, deal_name: @deal.name),
        "user_id" => @lender.id,
        "notificable_type": @deal.class.to_s,
        "notificable_id": @deal.id
      })
      deal_lender.update(signature_sent_at: Time.now)

      return render turbo_stream: turbo_stream_response_deal
    else
      redirect_to deal_path(@deal), notice: 'Lender already signed'
    end
  end

  def review_investment_modal
    if params.key?('step_2') && params.key?('investment_amount')
      # redirect not working, must be a turbo stream update
      if BigDecimal(params['investment_amount']).zero?
        return render turbo_stream: turbo_stream.replace('modal', partial: '/partials/modals/lender_funding/review_investment')
      end

      return render partial: '/partials/modals/lender_funding/confirm_investment',
                    locals: { investment: params['investment_amount'] }
    end

    render partial: '/partials/modals/lender_funding/review_investment'
  end

  def search_lenders_autocomplete
    @lenders = params[:query].present? ? Lender.search(params[:query]).limit(4) : []

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [turbo_stream.update('search_results',
                                                  partial: '/partials/modals/invite_lenders/search_results',
                                                  locals: { lenders: @lenders })]
      end
    end
  end

  def invite_lender_add
    @email = params[:email]
    @lender = Lender.find_by(email: @email) if @email.present?

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [turbo_stream.append('added_lenders',
                                                  partial: '/partials/modals/invite_lenders/added_lenders',
                                                  locals: { lender: @lender, email: @email })]
      end
    end
  end

  def selected_lenders_counter
    count = 0
    count = params[:count] if params[:count].present?

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [turbo_stream.update('lendersSelected',
                                                  partial: '/partials/modals/invite_lenders/lenders_selected',
                                                  locals: { count: count })]
      end
    end
  end

  def sign_deal
    deal_lender = DealLender.find_by(deal: @deal, lender: @lender)

    redirect_to deal_lender.document_url, allow_other_host: true
  end

  private

  def lenders_params
    params.permit(:authenticity_token, :button, :deal_id, lenders: [])
  end

  def find_deal
    @deal = Deal.find(params[:deal_id])
  end

  def find_lender
    @lender = Lender.find(params[:id])
  end

  def turbo_stream_response_deal
    # Reloading to update virtual attributes
    @deal_flow_partial = DealFlowRender.new(user: current_user, deal: @deal).call
    turbo_stream.replace("deal_#{@deal.id}", partial: '/deals/deal', locals: { deal: Deal.find(@deal.id), deal_cycle_partial: DealCycleRender.new(user: current_user, deal: @deal).call, deal_flow_partial: @deal_flow_partial })
  end
end
