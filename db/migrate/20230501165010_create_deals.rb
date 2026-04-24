class CreateDeals < ActiveRecord::Migration[7.0]
  def change
    create_table :deals do |t|
      t.belongs_to :borrower, null: false, foreign_key: true
      t.decimal :loan_amount
      t.decimal :interest_rate

      t.timestamps
    end
  end
end
