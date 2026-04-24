class LendersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_profile_setup!
  before_action :find_lender, only: [:edit, :update, :destroy, :send_invite, :remove_from_pool, :approve_lender]

  include UsersHelper

  def index
    lenders_fetcher = LendersFetcher.new.call
    @lenders = lenders_fetcher.search(params[:query]).page(params[:page])
    PosthogEventJob.perform_async('View Lenders',current_user.email, {})
  end

  def new
    @lender = Lender.new
  end

  def create
    @lender = Lender.new(lender_params)

    @lender.skip_password_validation = true
    @lender.skip_confirmation!
    if @lender.save
      PosthogEventJob.perform_async('Create New Lender', current_user.email, {
        'lender_id' => @lender.id,
        'lender_email' => @lender.email,
        'lender_name' => @lender.full_name
      })
      @lender.deliver_invitation
      redirect_to lenders_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @lender.assign_attributes(lender_params)
    @lender.skip_reconfirmation!
    if @lender.save
      redirect_to lenders_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @lender.destroy
    PosthogEventJob.perform_async('Delete Lender', current_user.email, {
      'lender_id' => @lender.id,
      'lender_email' => @lender.email,
      'lender_name' => @lender.full_name
    })
    redirect_to lenders_path
  end

  def send_invite
    @lender.update(invitation_sent_at: Time.now)
    @lender.deliver_invitation

    PosthogEventJob.perform_async('Invite Lender to Pool', current_user.email, {
      'lender_id' => @lender.id,
      'lender_email' => @lender.email,
      'lender_name' => @lender.full_name
    })

    redirect_to lenders_path
  end

  def remove_from_pool
    pool = BrokerLender.find_by(
      broker_id: Current.user.id,
      lender_id: @lender.id
    )

    pool.destroy if pool.present?

    PosthogEventJob.perform_async('Remove Lender from Pool', current_user.email, {
        'lender_id' => @lender.id,
        'lender_email' => @lender.email,
        'lender_name' => @lender.full_name
    })

    redirect_to lenders_path
  end

  def invite_lenders
    emails = params[:lenders]
    return unless register_lenders(emails)

    render partial: '/partials/modals/invite_lenders/invite_success'
  end

  def invite_lenders_modal
    render partial: '/partials/modals/invite_lenders/non_registered_invite'
  end

  def search_lenders_autocomplete
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [turbo_stream.update('search_results',
                                                  partial: '/partials/modals/invite_lenders/search_results',
                                                  locals: { lenders: [] })]
      end
    end
  end

  def approve_lender
    if current_user.admin?
      @lender.update(approved_at: Time.now)
      LenderMailer.approval_request(user: @lender).deliver_later
    end

    redirect_to lenders_path
  end

  private

  def lender_params
    params.require(:lender).permit(
      :title,
      :first_name,
      :middle_name,
      :last_name,
      :birth_date,
      :email,
      :phone_number,
      :address_street,
      :address_unit,
      :address_city,
      :address_province,
      :address_country,
      :address_postal_code,
    )
  end

  def find_lender
    @lender = Lender.find(params[:id])
  end

  def register_lenders(emails)
    emails.each do |email|
      lender = Lender.find_or_initialize_by(email: email)
      next unless lender.new_record?

      lender.skip_password_validation = true
      lender.skip_confirmation!

      lender.deliver_invitation if lender.save
    end
  end
end
