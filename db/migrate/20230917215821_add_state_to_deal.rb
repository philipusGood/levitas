class AddStateToDeal < ActiveRecord::Migration[7.0]
  def change
    add_column :deals, :state, :integer, index: true, default: 0
    add_index :deals, :state
  end
end
