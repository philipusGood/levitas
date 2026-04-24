class AddSignatureFieldsToDealLenders < ActiveRecord::Migration[7.0]
  def change
    add_column :deal_lenders, :envelope_id, :string
    add_column :deal_lenders, :signed_at, :timestamp
  end
end
