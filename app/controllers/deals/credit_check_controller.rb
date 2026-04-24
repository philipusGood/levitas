class Deals::CreditCheckController < Deals::BaseController
  def index
    @credit_check = @deal.credit_check
  end

  def create
    @credit_check = Deal::CreditCheck.new(credit_check_params)

    if @credit_check.valid?
      @deal.credit_check = @credit_check.serialize

      save_deal
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def next_step_path
    deal_summary_index_path(@deal)
  end

  def set_active_step
    @active_step = @step_builder.set_current_step(:credit_check)
  end

  def credit_check_params
    params.require(:deal_credit_check).permit(:accept_terms)
  end
end