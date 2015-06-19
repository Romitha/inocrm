class BpmTables < ActiveRecord::Migration
  def change
  	create_table :role_bpm_role, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :role_id, "int(10) UNSIGNED NOT NULL"
      t.column :bpm_role_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end
  end
end
