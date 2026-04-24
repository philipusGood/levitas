class RemoveUserIdColumnFromBorrowers < ActiveRecord::Migration[7.0]
  def change
    remove_column :borrowers, :user_id
  end
end
