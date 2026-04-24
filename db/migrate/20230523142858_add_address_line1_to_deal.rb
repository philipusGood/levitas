class AddAddressLine1ToDeal < ActiveRecord::Migration[7.0]
  def change
    add_column :deals, :address_line_1, :string
  end
end
