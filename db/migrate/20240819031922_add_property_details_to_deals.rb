class AddPropertyDetailsToDeals < ActiveRecord::Migration[7.0]
  def change
    add_column :deals, :property_details, :text
  end
end
