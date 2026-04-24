class Deals::SummaryController < Deals::BaseController
  def index
    PosthogEventJob.perform_async('View Deal Summary', current_user.email, {
      'deal_id' => @deal.id
    })
  end

  def create
    redirect_to deal_submit_index_path(@deal)
  end

  private
  def set_active_step
    @active_step = @step_builder.set_current_step(:summary)
  end
end