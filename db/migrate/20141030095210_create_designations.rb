class CreateDesignations < ActiveRecord::Migration
  def change
    create_table :designations do |t|
      t.string :name
      t.text :description
      t.references :organization, index: true

      t.timestamps
    end

    add_reference :users, :designation, index: true
  end
end
