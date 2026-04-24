class AddSignatureSentAtToDealLender < ActiveRecord::Migration[7.0]
  def change
    add_column :deal_lenders, :signature_sent_at, :datetime
  end
end
