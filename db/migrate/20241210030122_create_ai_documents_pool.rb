class CreateAiDocumentsPool < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_documents_pools do |t|
      t.string :job_id, index: true
      t.string :status, index: true
      t.references :deal, foreign_key: true

      t.timestamps
    end
  end
end
