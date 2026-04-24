class Deals::BaseController < ApplicationController
  layout 'deals'

  before_action :authenticate_user!
  before_action :find_deal
  before_action :verify_state
  before_action :set_step_builder
  before_action :set_active_step

  protected
  def find_deal
    @deal = Deal.find(params[:deal_id])
  end

  def set_step_builder
    @step_builder ||= ::DealBuilder.new
  end

  def save_as_draft?
    params[:draft] && params[:draft] == "true"

  end

  def next_step_path
    root_path
  end

  def save_deal
    @deal.save

    if save_as_draft?
      redirect_to root_path
    else
      redirect_to next_step_path
    end
  end

  def verify_state
    if !current_user&.admin?
      redirect_to root_path(@deal) if @deal.submitted?
    end
  end
end
