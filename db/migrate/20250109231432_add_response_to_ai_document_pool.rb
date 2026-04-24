class AddResponseToAiDocumentPool < ActiveRecord::Migration[7.0]
  def change
    add_column :ai_documents_pools, :response, :text
  end
end
