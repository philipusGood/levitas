class CreateBorrowers < ActiveRecord::Migration[7.0]
  def change
    create_table :borrowers do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :credit_score
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
