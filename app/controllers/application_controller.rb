class ApplicationController < ActionController::Base
  impersonates :user

  layout :set_layout

  before_action :set_current_user, if: :user_signed_in?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :remind_to_confirm_email

  around_action :set_locale

  protected

  def ensure_profile_setup!
    if current_user && current_user.pending_account_setup?
      redirect_to after_signup_path
    elsif current_user && current_user.approved_at.nil? && current_user.lender?
      redirect_to after_signup_path
    end
  end

  def set_layout
    return 'turbo_rails/frame' if turbo_frame_request?

    if devise_controller?
      'devise'
    else
      'application'
    end
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  def after_invite_path_for(resource)
    case resource.role
    when 'broker'
      brokers_path
    end
  end

  def require_admin!
    redirect_to root_path unless current_user&.admin?
  end

  def require_admin_or_broker!
    redirect_to root_path unless current_user&.admin? || current_user&.broker?
  end

  def require_lender!
    redirect_to root_path unless current_user&.lender?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation, :role, :invitation_token])
    devise_parameter_sanitizer.permit(:invite, keys: [:email, :role])
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:password, :password_confirmation, :invitation_token])
  end

  private

  def remind_to_confirm_email
    return if current_user.nil? || current_user.role == 'admin'

    unless current_user.confirmed_at?
      cookies[:needs_confirm_email] = true
    end
  end

  def set_current_user
    Current.user = current_user
  end

  def set_locale(&action)
    locale = I18n.default_locale
    locale = current_user.try(:locale) || I18n.default_locale if Flipper.enabled?(:localization, current_user)
    I18n.with_locale(locale, &action)
  end
end
