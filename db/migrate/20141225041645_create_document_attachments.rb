class CreateDocumentAttachments < ActiveRecord::Migration
  def change
    create_table :document_attachments do |t|
      t.string :name
      t.string :file_path
      t.boolean :downloadable
      t.references :attachable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
