class AddUrlCodeToDeals < ActiveRecord::Migration[7.0]
  def change
    add_column :deals, :url_code, :string, index: true, unique: true
  end
end
