class AddAapprovedAtToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :approved_at, :datetime
  end
end
