class RemoveMainBrokerFromDeals < ActiveRecord::Migration[7.0]
  def change
    remove_column :deals, :main_broker_id
  end
end
