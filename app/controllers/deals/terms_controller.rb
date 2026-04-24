class Deals::TermsController < Deals::BaseController
  def index
    @terms = @deal.terms
  end

  def create
    @terms = Deal::Term.new(term_params)
    if @terms.valid?
      @deal.terms = @terms.serialize
      PosthogEventJob.perform_async('Send Terms', current_user.email, {
        'deal_id' => @deal.id
      })

      save_deal
    else
      render :index, status: :unprocessable_entity
    end
  end

  private
  def next_step_path
    deal_loan_purpose_index_path(@deal)
  end

  def set_active_step
    @active_step = @step_builder.set_current_step(:deal_terms)
  end

  def term_params
    params.require(:deal_term).permit(
      :mortgage_principal,
      :lenders_fee,
      :interest_rate,
      :type,
      :terms,
      :amortization_period,
      :prepayment_term,
      :public,
      :payment_frecuency
    )
  end
end
