class CreateBrokers < ActiveRecord::Migration[7.0]
  def change
    create_table :brokers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :company_name

      t.timestamps
    end
  end
end
