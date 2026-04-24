class AddMainBrokerToBrokerDeals < ActiveRecord::Migration[7.0]
  def change
    add_column :broker_deals, :main_broker, :boolean
  end
end
