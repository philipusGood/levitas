class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.integer :user_id, index: true
      t.integer :notificable_id
      t.text :content
      t.string :notificable_type
      t.boolean :read, default: :false

      t.timestamps
    end
  end
end
