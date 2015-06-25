class CreateContactNumbers < ActiveRecord::Migration
  def change
    create_table :contact_numbers, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :category
      t.string :value
      t.boolean :primary
      #t.references :c_numberable, polymorphic: true, index: true, unsigned: true
      t.column :c_numberable_id, "int(10) UNSIGNED"
      t.string :c_numberable_type
      t.timestamps
    end
  end
end
