class CreateLenderDeals < ActiveRecord::Migration[7.0]
  def change
    create_table :lender_deals do |t|
      t.belongs_to :lender, null: false, foreign_key: true
      t.belongs_to :deal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
