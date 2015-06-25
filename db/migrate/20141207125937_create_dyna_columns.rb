class CreateDynaColumns < ActiveRecord::Migration
  def change
    create_table :dyna_columns, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :data_key
      t.string :data_value
      #t.references :resourceable, polymorphic: true, index: true
      t.column :resourceable_id, "int(10) UNSIGNED"
      t.string :resourceable_type
      t.timestamps
    end
  end
end
