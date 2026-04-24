class AddBookmarkedToDeal < ActiveRecord::Migration[7.0]
  def change
    add_column :deals, :bookmarked, :boolean, default: false
  end
end
