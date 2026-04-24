class Deals::SubmitController < Deals::BaseController
  before_action :verify_deal_state, only: [:index]

  def index
  end

  def create
    @deal.submit!

    DealMailer.deal_submitted(deal: @deal).deliver_later

    redirect_to deal_submit_index_path(@deal)
  end

  private
  def set_active_step
    @active_step = @step_builder.set_current_step(:summary)
  end

  def verify_deal_state
    redirect_to deal_summary_index_path(@deal) if @deal.draft?
  end

  def verify_state
    nil
  end
end