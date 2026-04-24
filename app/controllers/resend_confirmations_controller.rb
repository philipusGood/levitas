class ResendConfirmationsController < ApplicationController
  before_action :authenticate_user!

  def create
    current_user.send_confirmation_instructions

    redirect_to request.referrer, allow_other_host: true
  end
end
