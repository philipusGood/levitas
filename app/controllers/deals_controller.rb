class DealsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_profile_setup!
  before_action :find_deal, except: [:create]
  before_action :authorize_deal!, except: [:create]
  before_action :require_admin!, only: [:update, :destroy]
  before_action :require_admin_or_broker!, only: :edit

  def show
    PosthogEventJob.perform_async('View Deal', current_user.email, {
      'deal' => @deal.id,
      'deal_name' => @deal.name,
      'capture_method' => 'async'
    })
  end

  def create
    deal = current_user.deals.create

    PosthogEventJob.perform_async('Create Deal', current_user.email, {
      'role' => current_user.role,
      'deal_id' => deal.id
    })

    if Flipper.enabled?(:ai_documents, Current.user)
      redirect_to deal_documents_path(deal)
    else
      redirect_to deal_main_applicant_index_path(deal)
    end
  end

  def edit
    @steps ||= ::DealBuilder.new
    @active_step = @steps.set_current_step(:main_applicant)
    @active_sub_step = @steps.set_current_sub_step(:information)

    @applicant = @deal.applicant
    @secondary_applicant = @deal.secondary_applicant
    @terms = @deal.terms
    @loan_purpose = @deal.loan_purpose
    @broker_fees = @deal.broker_fees
    @property = @deal.property
    @guarantor = @deal.guarantor
  end

  def update
    deal_updater = DealUpdater.new(deal: @deal, params: deal_params)
    if deal_updater.call
      PosthogEventJob.perform_async('Update Deal', current_user.email, {
        'role' => current_user.role,
        'deal_id' => @deal.id,
        'deal_name' => @deal.name
      })

      flash.notice = t('deals.edit_complete')
      redirect_to deal_path(@deal)
    else
      @steps ||= ::DealBuilder.new
      @active_step = @steps.set_current_step(:main_applicant)
      @active_sub_step = @steps.set_current_sub_step(:information)

      @applicant = deal_updater.applicant
      @secondary_applicant = deal_updater.secondary_applicant if @deal.has_secondary_applicant?
      @terms = deal_updater.terms
      @loan_purpose = deal_updater.loan_purpose
      @broker_fees = deal_updater.broker_fees
      @property = deal_updater.property
      @guarantor =  deal_updater.guarantor

      render :edit
    end
  end

  def destroy
    @deal.destroy

    DealMailer.deal_terms_rejected(user: current_user, broker_email: @deal.user.email, deal_name: @deal.name).deliver_later

    PosthogEventJob.perform_async('Delete Deal', current_user.email, {
      'role' => current_user.role,
      'deal_id' => @deal.id,
      'deal_name' => @deal.name
    })

    if current_user.admin?
      NotificationJob.perform_later({
        "content" => I18n.t('notifications.deal_destroyed', name: @deal.name),
        "user_id" => @deal.user.id
      })
    end

    render turbo_stream: turbo_stream.remove(@deal)
  end

  def bookmark
    @deal.update(bookmarked: !@deal.bookmarked)

    PosthogEventJob.perform_async('Bookmark Deal', current_user.email, {
      'role' => current_user.role,
      'deal_id' => @deal.id,
      'deal_name' => @deal.name
    })

    render turbo_stream: turbo_stream_response
  end

  def change
    @deal.submit!

    PosthogEventJob.perform_async('Submit Deal', current_user.email, {
      'role' => current_user.role,
      'deal_id' => @deal.id
    })

    render turbo_stream: turbo_stream_response
  end

  def review
    @terms = Deal::Term.new(deal_term_params)

    if @terms.valid?
      @deal.terms = @terms.serialize
      @deal.save
      @deal.review!

      DealMailer.deal_terms_send(deal: @deal, email: @deal.user.email).deliver_later
      NotificationJob.perform_later({
        "content" => I18n.t('notifications.deal_reviewed'),
        "user_id" => @deal.user.id,
        "notificable_type": @deal.class.to_s,
        "notificable_id": @deal.id
      })

      PosthogEventJob.perform_async('Deal Terms Reviewed', current_user.email, {
        'role' => current_user.role,
        'deal_id' => @deal.id,
        'deal_name' => @deal.name
      })

      render turbo_stream: turbo_stream_response
    else
      render turbo_stream: turbo_stream_response, status: :unprocessable_entity
    end
  end

  def reject_reason
    @deal.rejected_description = params[:deal][:rejected_description]
    @deal.rejected_actor = current_user
    @deal.save
    return unless @deal.reject!

    DealMailer.deal_terms_rejected(user: current_user, broker_email: @deal.user.email, deal_name: @deal.name).deliver_later

    if current_user.admin?
      NotificationJob.perform_later({
        "content" => I18n.t('notifications.deal_rejected'),
        "user_id" => @deal.user.id,
        "notificable_type": @deal.class.to_s,
        "notificable_id": @deal.id
      })
    end

    PosthogEventJob.perform_async('Deal Terms Rejected', current_user.email, {
      'role' => current_user.role,
      'deal_id' => @deal.id,
      'deal_name' => @deal.name
    })

    respond_to do |format|
      format.html { redirect_to @deal }
      format.turbo_stream { render partial: '/partials/modals/terms_success' }
    end
  end

  def accept
    @deal.accept!

    DealMailer.deal_terms_accepted(deal: @deal).deliver_later
    PosthogEventJob.perform_async('Deal Terms Accepted', current_user.email, {
      'role' => current_user.role,
      'deal_id' => @deal.id,
      'deal_name' => @deal.name
    })


    render partial: '/partials/modals/deal_terms/confirm_terms_success'
  end

  def start_funding
    @deal.start_funding!

    NotificationJob.perform_later({
      "content" => I18n.t('notifications.deal_funding'),
      "user_id" => @deal.user.id,
      "notificable_type": @deal.class.to_s,
      "notificable_id": @deal.id
    })

    PosthogEventJob.perform_async('Start Funding Deal', current_user.email, {
      'role' => current_user.role,
      'deal_id' => @deal.id,
      'deal_name' => @deal.name
    })

    render turbo_stream: turbo_stream_response
  end

  def request_signatures
    @deal.request_signatures!

    RequestSignaturesJob.perform_later(deal_id: @deal.id)

    PosthogEventJob.perform_async('Request Signatures of Deal', current_user.email, {
      'role' => current_user.role,
      'deal_id' => @deal.id,
      'deal_name' => @deal.name
    })

    render turbo_stream: turbo_stream_response
  end

  def approve_signatures
    @deal.approve_signatures!

    PosthogEventJob.perform_async('Approved Signatures of Deal', current_user.email, {
      'role' => current_user.role,
      'deal_id' => @deal.id,
      'deal_name' => @deal.name
    })

    render turbo_stream: turbo_stream_response
  end

  def make_public_modal
    render partial: '/partials/modals/make_deal_public'
  end

  def make_public
    terms = @deal.terms
    @deal.terms = terms.serialize.merge({ public: "true" })
    @deal.save
    @deal.submit!

    PosthogEventJob.perform_async('Make Deal Public', current_user.email, {
      'role' => current_user.role,
      'deal_id' => @deal.id,
      'deal_name' => @deal.name
    })

    render turbo_stream: turbo_stream_response
  end

  def review_terms_modal
    return render partial: '/partials/modals/deal_terms/confirm_terms' if params.key?('step_2')

    render partial: '/partials/modals/deal_terms/review_terms'
  end

  def invite_lenders_modal
    render partial: '/partials/modals/invite_lenders'
  end

  def view_invited_lenders_modal
    render partial: '/partials/modals/invite_lenders/view_all'
  end

  def upload_document
    @deal.documents.attach(params[:blob])
    @deal.save

    PosthogEventJob.perform_async('Upload Documents to Deal', current_user.email, {
      'role' => current_user.role,
      'deal_id' => @deal.id,
      'deal_name' => @deal.name
    })

    render turbo_stream: turbo_stream_response
  end

  def download_document
    document = @deal.documents.find(params[:document_id])
    send_data document.blob.download, filename: document.blob.filename.to_s, type: document.blob.content_type
  end

  def signing_complete
    case params[:event]
    when "signing_complete"
      flash.notice = t('deals.signing_complete')
    when "viewing_complete"
      flash.notice = t('deals.viewing_complete')
    end

    redirect_to deal_path(@deal)
  end

  private

  def find_deal
    @deal = Deal.find(params[:id])
    @terms = @deal.terms
    @deal_cycle_partial = DealCycleRender.new(user: current_user, deal: @deal).call
    @deal_flow_partial = DealFlowRender.new(user: current_user, deal: @deal).call
  end

  def authorize_deal!
    if current_user.broker?
      raise ActiveRecord::RecordNotFound if @deal.user_id != current_user.id
    elsif current_user.lender? && !@deal.available_for_lender?(current_user)
      raise ActiveRecord::RecordNotFound
    end
  end

  def deal_params
    params.require(:deal).permit(
      :property_picture,
      :state,
      :property_details,
      applicant: applicant_params,
      secondary_applicant: applicant_params,
      guarantor: [
        :title,
        :first_name,
        :last_name,
        :email,
        :phone_number,
        adddress: [
          :street,
          :unit,
          :city,
          :province,
          :country,
          :postal_code
        ]
      ],
      property: [
        :type,
        :mls_number,
        :price,
        :approximate_closing_date,
        mortgages: [:institution, :monthly_payment, :amount_due, :end_date],
        address: [
          :street,
          :unit,
          :city,
          :province,
          :country,
          :postal_code
        ]
      ],
      terms: [
        :mortgage_principal,
        :lenders_fee,
        :interest_rate,
        :type,
        :terms,
        :amortization_period,
        :prepayment_term,
        :public,
        :payment_frecuency
      ],
      loan_purpose: [
        :funds_usage,
        :exit_strategy
      ],
      broker_fees: [
        fees: [ :broker_name, :amount_fee, :default ]
      ],
    )
  end

  def applicant_params
    [
      :title,
      :first_name,
      :last_name,
      :birth_date,
      :social_insurance_number,
      :email,
      :phone_number,
      :credit_score,
      :credit_score_source,
      :credit_score_report_date,
      address: [
        :street,
        :unit,
        :city,
        :province,
        :country,
        :postal_code
      ],
      employer: [
        :name,
        :job_title,
        :industry_type,
        :employment_type,
        :duration_years,
        :duration_months,
        :phone_number,
        :fax,
        :email,
        :ext,
        income: [:type, :period, :amount],
        address: [
          :street,
          :unit,
          :city,
          :province,
          :country,
          :postal_code
        ]
      ],
      liabilities: [
        :taxes,
        :child_support,
        :bankruptcy,
        :bankruptcy_status,
        :expected_release_date,
        :cost_of_release,
        debt_obligations: [:type, :balance_remaining, :monthly_payment],
      ],
      assets: [:id, :type, :description, :amount, :mortage, :property_type, :balance_remaining, :monthly_payment],
    ]
  end

  def deal_term_params
    params.require(:deal_term).permit(
      :mortgage_principal,
      :lenders_fee,
      :interest_rate,
      :type,
      :terms,
      :amortization_period,
      :prepayment_term,
      :public
    )
  end

  def turbo_stream_response
    # Reloading to update virtual attributes
    turbo_stream.replace("deal_#{@deal.id}", partial: 'deal', locals: { deal: Deal.find(@deal.id), deal_cycle_partial: DealCycleRender.new(user: current_user, deal: @deal).call, deal_flow_partial: DealFlowRender.new(user: current_user, deal: @deal).call })
  end

end
