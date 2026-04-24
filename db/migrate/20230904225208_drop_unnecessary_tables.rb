class DropUnnecessaryTables < ActiveRecord::Migration[7.0]
  def change
    drop_table :broker_deals
    drop_table :lender_deals
    drop_table :brokers
    drop_table :lenders
  end
end
