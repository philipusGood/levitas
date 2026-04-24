class RegistrationsController < ::Devise::RegistrationsController
  layout :set_registration_layout, only: [:edit, :update]

  def update
    current_user.assign_attributes(user_params)

    if current_user.save(context: :account_setup)
      PosthogEventJob.perform_async('Update Profile',current_user.email, {
        '$set' => { 'name' => current_user.name,
                    'email' => current_user.email,
                    'role' => current_user.role }
      })
      flash.notice = I18n.t('devise.registrations.updated')
      redirect_to profile_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  protected
  def user_params
    params.require(:user).permit(
      :avatar,
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
      :corporation_name,
    )
  end

  def build_resource(hash = {})
    resource = super
    if hash['role'].nil? && request.path == new_lender_registration_path
      resource.role = 'lender'
    elsif hash['role'].nil?
      resource.role = 'broker'
    end

    resource
  end

  def set_registration_layout
    'application'
  end
end
