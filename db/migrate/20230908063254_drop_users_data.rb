class DropUsersData < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :title, :integer
    remove_column :users, :first_name, :string
    remove_column :users, :middle_name, :string
    remove_column :users, :last_name, :string
    remove_column :users, :date_of_birth, :date
    remove_column :users, :phone_number, :string
    remove_column :users, :street, :string
    remove_column :users, :unit, :string
    remove_column :users, :city, :string
    remove_column :users, :country, :string
    remove_column :users, :postal_code, :string
    remove_column :users, :status_account, :integer

    remove_reference :users, :province, foreign_key: true
  end
end
