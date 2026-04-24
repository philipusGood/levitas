class Deals::LoanPurposeController < Deals::BaseController
  def index
    @loan_purpose = @deal.loan_purpose
  end

  def create
    @loan_purpose = Deal::LoanPurpose.new(loan_purpose_params)
    if @loan_purpose.valid?
      @deal.loan_purpose = @loan_purpose.serialize

      save_deal
    else
      render :index, status: :unprocessable_entity
    end
  end

  private
  def next_step_path
    deal_documents_path(@deal)
  end

  def set_active_step
    @active_step = @step_builder.set_current_step(:loan_purpose)
  end

  def loan_purpose_params
    params.require(:deal_loan_purpose).permit(
      :funds_usage,
      :exit_strategy,
    )
  end
end
