class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :category
      t.text :address
      t.references :organization

      t.timestamps
    end
  end
end
