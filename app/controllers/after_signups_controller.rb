class AfterSignupsController < ApplicationController
  layout 'after_signup'

  before_action :authenticate_user!
  before_action :find_user, only: [:show, :update]

  def show
  end

  def update
    @user.assign_attributes(user_params)

    if @user.save(context: :account_setup)
      PosthogEventJob.perform_async('Create User', current_user.email, {
        '$set' => { 'name' => current_user.name,
                    'email' => current_user.email,
                    'role' => current_user.role }
      })
      redirect_to after_signup_path
    else
      render :show, status: :unprocessable_entity
    end
  end

  private
  def find_user
    @user = User.find(current_user.id)
  end

  def user_params
    params.require(:user).permit(
      :title,
      :first_name,
      :middle_name,
      :last_name,
      :birth_date,
      :phone_number,
      :address_street,
      :address_unit,
      :address_city,
      :address_province,
      :address_country,
      :address_postal_code,
      :accredited_investor,
      :corporation_name
    )
  end
end
