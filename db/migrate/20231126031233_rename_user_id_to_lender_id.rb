class RenameUserIdToLenderId < ActiveRecord::Migration[7.0]
  def change
    rename_column :deal_lenders, :user_id, :lender_id
  end
end
