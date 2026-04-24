class AddColumnsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :title, :integer
    add_column :users, :first_name, :string
    add_column :users, :middle_name, :string
    add_column :users, :last_name, :string
    add_column :users, :date_of_birth, :date
    add_column :users, :phone_number, :string
    add_column :users, :street, :string
    add_column :users, :unit, :string
    add_column :users, :city, :string
    add_reference :users, :province, foreign_key: true
    add_column :users, :country, :string
    add_column :users, :postal_code, :string
    add_column :users, :status_account, :integer
  end
end
