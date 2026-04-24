class ImpersonationsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_profile_setup!
  before_action :require_admin!

  def create
    user = User.find(params[:user_id])
    impersonate_user(user)
    redirect_to root_path
  end
end
