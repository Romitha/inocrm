class CreateDocumentAttachments < ActiveRecord::Migration
  def change
    create_table :document_attachments do |t|
      t.string :name
      t.string :file_path
      t.boolean :downloadable
      t.references :organization, index: true

      t.timestamps
    end
  end
end
