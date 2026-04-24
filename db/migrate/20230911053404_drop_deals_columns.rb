class DropDealsColumns < ActiveRecord::Migration[7.0]
  def change
    remove_index :deals, :borrower_id
    remove_column :deals, :borrower_id
    remove_column :deals, :loan_amount
    remove_column :deals, :interest_rate
    remove_column :deals, :address_line_1
  end
end
