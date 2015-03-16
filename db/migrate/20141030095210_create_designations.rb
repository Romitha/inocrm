class CreateDesignations < ActiveRecord::Migration
  def change
    create_table :designations, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      t.text :description
      t.references :organization, index: true

      t.timestamps
    end

    add_reference :users, :designation, index: true
  end
end
