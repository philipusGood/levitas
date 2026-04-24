class AddRoleEnumToUser < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :role
    add_column :users, :role, :integer, default: 0, limit: 2
    User.where.not(role: [0, 1, 2]).update_all(role: 0)
    change_column_null :users, :role, false
    add_index :users, :role
  end
end
