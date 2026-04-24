class AddUserToDeal < ActiveRecord::Migration[7.0]
  def change
    add_column :deals, :user_id, :integer, null: false
    add_index :deals, :user_id
  end
end
