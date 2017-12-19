class CreatePermissionModule < ActiveRecord::Migration
  def change
    create_table :rpermission_modules, id: false do |t|
      t.column :id, 'INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY(id)'
      t.string :name

      t.timestamps
    end

    add_column :rpermissions, :rpermission_module_id, 'INT UNSIGNED'
    add_index :rpermissions, :rpermission_module_id, name: "fk_rpermissions_rpermission_module_id_idx"
    add_foreign_key :rpermissions, :rpermission_modules, name: 'fk_rpermissions_rpermission_module_id', column: :rpermission_module_id
  end
end
