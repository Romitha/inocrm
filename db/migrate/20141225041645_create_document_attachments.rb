class CreateDocumentAttachments < ActiveRecord::Migration
  def change
    create_table :document_attachments, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      t.string :file_path
      t.boolean :downloadable
      #t.references :attachable, polymorphic: true, index: true
      t.column :attachable_id, "int(10) UNSIGNED"
      t.string :attachable_type
      t.timestamps
    end
  end
end
