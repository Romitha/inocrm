class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :category
      t.text :address
      t.boolean :primary
      t.references :addressable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
