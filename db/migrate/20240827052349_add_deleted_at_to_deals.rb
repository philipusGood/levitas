class AddDeletedAtToDeals < ActiveRecord::Migration[7.0]
  def change
    add_column :deals, :deleted_at, :datetime
    add_index :deals, :deleted_at
  end
end
