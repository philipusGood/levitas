class CreateBrokerLenders < ActiveRecord::Migration[7.0]
  def change
    create_table :broker_lenders do |t|
      t.integer :lender_id, index: true
      t.integer :broker_id, index: true
      t.integer :status, default: 1
      t.timestamps
    end
  end
end
