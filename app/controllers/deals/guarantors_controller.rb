class Deals::GuarantorsController< Deals::BaseController
  def index
    @guarantor = @deal.guarantor
  end

  def create
    @guarantor = Deal::Guarantor.new(guarantor_params)

    if @guarantor.valid?
      @deal.guarantor = @guarantor.serialize

      save_deal
    else
      render :index, status: :unprocessable_entity
    end

  end

  private

  def next_step_path
    deal_property_index_path(@deal)
  end

  def set_active_step
    @active_step = @step_builder.set_current_step(:guarantor)
  end

  def guarantor_params
    params.require(:deal_guarantor).permit(
      :confirmation,
      :title,
      :first_name,
      :last_name,
      :email,
      :phone_number,
      address: [
        :street,
        :unit,
        :city,
        :province,
        :country,
        :postal_code
      ]
    )
  end
end
