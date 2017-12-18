class AddPermissionWrapper < ActiveRecord::Migration
  def change
    create_table :permission_wrappers, id: false do |t|
      t.column :id, 'INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY(id)'
      t.string :name, null: false

      t.timestamps
    end

    create_table :rpermissions_wrapper, id: false do |t|
      t.column :id, 'INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY(id)'
      t.column :permission_wrapper_id, 'INT UNSIGNED NOT NULL'
      t.column :rpermission_id, 'INT UNSIGNED NOT NULL'
      t.index :permission_wrapper_id
      t.index :rpermission_id
    end

    add_foreign_key :rpermissions_wrapper, :permission_wrappers, name: 'fk_permissions_wrapper_rpermissions_wrapper', column: :permission_wrapper_id
    add_foreign_key :rpermissions_wrapper, :rpermissions, name: 'fk_permissions_wrapper_rpermissions', column: :rpermission_id

  end
end
