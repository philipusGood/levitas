class BrokersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_profile_setup!
  before_action :find_broker, except: [:index, :create, :new]
  before_action :require_admin!

  def index
    @brokers = Broker.search(params[:query]).page(params[:page])
    PosthogEventJob.perform_async('View Brokers', current_user.email, {})
  end

  def new
    @broker = Broker.new
  end

  def show
    PosthogEventJob.perform_async('View Broker Profile', current_user.email, {
      'broker_id' => params[:id]
    })
  end

  def create
    @broker = Broker.new(broker_params)

    @broker.skip_password_validation = true
    @broker.skip_confirmation!
    if @broker.save
      @broker.deliver_invitation
      PosthogEventJob.perform_async('Create new Broker', current_user.email, {
        'role' => current_user.role
      })
      redirect_to brokers_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @broker.assign_attributes(broker_params)
    @broker.skip_reconfirmation!
    if @broker.save
      redirect_to brokers_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @broker.destroy
    PosthogEventJob.perform_async('Delete Broker', current_user.email, {
      'role' => current_user.role,
      'broker' => @broker.id
    })
    redirect_to brokers_path
  end

  def send_invite
    @broker.update(invitation_sent_at: Time.now)
    @broker.deliver_invitation
    PosthogEventJob.perform_async('Invite Broker', current_user.email, {})

    redirect_to brokers_path
  end

  def lenders_pool
    @lenders = @broker.lenders.search(params[:query]).page(params[:page])
    PosthogEventJob.perform_async('View Lender Pool', current_user.email, {})
  end

  def remove_lender_from_pool
    @lender = @broker.lenders.find(params[:lender_id])
    pool = BrokerLender.find_by(
      broker_id: @broker.id,
      lender_id: @lender.id
    )

    pool.destroy if pool.present?

    PosthogEventJob.perform_async('Remove Lender from Pool', current_user.email, {
      'role' => current_user.role,
      'lender' => @lender.id
    })

    render turbo_stream: turbo_stream.remove(@lender)
  end


  private
  def broker_params
    params.require(:broker).permit(
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
      :role
    )
  end

  def find_broker
    @broker = Broker.find(params[:id])
  end
end
