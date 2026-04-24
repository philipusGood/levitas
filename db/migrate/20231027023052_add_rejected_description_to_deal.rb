class AddRejectedDescriptionToDeal < ActiveRecord::Migration[7.0]
  def change
    add_column :deals, :rejected_description, :text
  end
end
