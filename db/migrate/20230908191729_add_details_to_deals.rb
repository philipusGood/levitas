class AddDetailsToDeals < ActiveRecord::Migration[7.0]
  def change
    add_column :deals, :details, :jsonb, default: {}
  end
end
