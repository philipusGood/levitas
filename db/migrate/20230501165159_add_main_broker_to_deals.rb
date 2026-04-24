class AddMainBrokerToDeals < ActiveRecord::Migration[7.0]
  def change
    add_reference :deals, :main_broker, foreign_key: { to_table: :brokers }
  end
end
