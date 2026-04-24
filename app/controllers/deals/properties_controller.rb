class Deals::PropertiesController < Deals::BaseController
  def index
    @property = @deal.property
  end

  def create
    @property = Deal::Property.new(property_params)
    if @property.valid?
      @deal.property = @property.serialize

      save_deal
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def next_step_path
    deal_terms_path(@deal)
  end

  def set_active_step
    @active_step = @step_builder.set_current_step(:property)
  end

  def property_params
    params.require(:deal_property).permit(
      :type,
      :mls_number,
      :price,
      :approximate_closing_date,
      :has_mortage,
      mortgages: [:institution, :monthly_payment, :amount_due, :end_date],
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
