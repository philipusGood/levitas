class AddApprovedSignaturesAtToDeal < ActiveRecord::Migration[7.0]
  def change
    add_column :deals, :approved_signatures_at, :timestamp
  end
end
