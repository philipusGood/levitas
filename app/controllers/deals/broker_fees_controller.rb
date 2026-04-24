class Deals::BrokerFeesController< Deals::BaseController
  def index
    @broker_fee = @deal.broker_fees
    @broker_fee.build_default_item(build_default_broker) if @broker_fee.items.empty?
  end

  def create
    @broker_fee = Deal::BrokerFee.new(broker_fees_params)

    if @broker_fee.valid?
      @deal.broker_fees = @broker_fee.serialize

      save_deal
    else
      render :index, status: :unprocessable_entity
    end

  end

  private

  def next_step_path
    deal_credit_check_index_path(@deal)
  end

  def set_active_step
    @active_step = @step_builder.set_current_step(:broker_fee)
  end

  def broker_fees_params
    params.require(:deal_broker_fee).require(:fees).map { |asset_params| asset_params.permit(:broker_name, :amount_fee, :default) }
  end

  def build_default_broker
    { broker_name: "#{current_user.full_name}", default: true, amount_fee: 0}
  end
end