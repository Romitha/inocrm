class CreateRpermissions < ActiveRecord::Migration
  def change
    create_table :rpermissions, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      t.string :controller_resource
      t.string :controller_action

      t.timestamps
    end

    create_table :roles_rpermissions, id: false do |t|
      t.belongs_to :role
      t.belongs_to :rpermission
    end
  end
end
