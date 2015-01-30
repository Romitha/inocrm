class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :subject
      t.text :content
      t.references :agent, index: true
      t.references :ticket, index: true

      t.timestamps
    end
  end
end
