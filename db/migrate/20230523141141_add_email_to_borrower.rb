class AddEmailToBorrower < ActiveRecord::Migration[7.0]
  def change
    add_column :borrowers, :email, :string
  end
end
