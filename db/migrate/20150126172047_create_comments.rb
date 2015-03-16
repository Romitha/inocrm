class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :subject
      t.text :content
      t.references :agent, index: true
      t.references :ticket, index: true

      t.timestamps
    end
  end
end
