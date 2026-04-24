class CreateDealLenders < ActiveRecord::Migration[7.0]
  def change
    create_table :deal_lenders do |t|
      t.integer :user_id, null: false, foreign_key: true
      t.references :deal, null: false, foreign_key: true
      t.decimal :commited_capital, default: 0

      t.timestamps
    end

    add_index :deal_lenders, [:user_id, :deal_id], unique: true
  end
end
