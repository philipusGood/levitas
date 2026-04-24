class DropBorrowersTable < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :deals, column: :borrower_id
    drop_table :borrowers
  end
end
