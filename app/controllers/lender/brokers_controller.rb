class Lender::BrokersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_lender!
  before_action :find_broker_lender, only: [:accept_invitation, :reject_invitation]

  def index
    scope = BrokersFetcher.new(current_user).call
    @brokers = scope.page(params[:page])
    @lender = current_user.as_lender
  end

  def destroy
  end

  def accept_invitation
    @broker_lender.update(status: "accepted")
    redirect_to lender_brokers_path
  end

  def reject_invitation
    @broker_lender.destroy
    redirect_to lender_brokers_path
  end

  private
  def find_broker_lender
    @broker_lender = BrokerLender.find_by(broker_id: params[:broker_id], lender_id: current_user.id)
  end
end
