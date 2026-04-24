class LocaleController < ApplicationController
  before_action :authenticate_user!

  VALID_LOCALES = %w[en fr].freeze

  def switch
    locale = params[:locale]
    locale = 'en' unless VALID_LOCALES.include?(locale)

    if current_user.update(locale: locale)
      I18n.locale = locale
      # Record the selected locale
      PosthogEventJob.perform_later(current_user.email, 'Language Switch', {
        'locale' => locale
      })
      redirect_back(fallback_location: root_path)
    else
      redirect_back(fallback_location: root_path)
    end
  end
end
