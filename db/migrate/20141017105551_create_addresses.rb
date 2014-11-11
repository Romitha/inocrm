class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :category
      t.text :address
      t.boolean :primary
      t.references :addressable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
