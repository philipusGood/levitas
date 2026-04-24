class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_profile_setup!

  def show
    PosthogEventJob.perform_async('View Profile', current_user.email, {})
  end
end