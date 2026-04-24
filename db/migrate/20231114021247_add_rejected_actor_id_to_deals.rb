class AddRejectedActorIdToDeals < ActiveRecord::Migration[7.0]
  def change
    add_column :deals, :rejected_actor_id, :integer, index: true
  end
end
