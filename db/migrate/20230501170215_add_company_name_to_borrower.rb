class AddCompanyNameToBorrower < ActiveRecord::Migration[7.0]
  def change
    add_column :borrowers, :company_name, :string
  end
end
