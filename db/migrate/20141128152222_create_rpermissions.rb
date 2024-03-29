class CreateRpermissions < ActiveRecord::Migration
  def change
    create_table :rpermissions, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      t.string :controller_resource
      t.string :controller_action

      t.column :subject_class_id, "INT UNSIGNED"

      t.timestamps
    end

    create_table :roles_rpermissions, id: false do |t|
      # t.belongs_to :role
      # t.belongs_to :rpermission
      t.column :role_id, "INT(10) UNSIGNED"
      t.column :rpermission_id, "INT(10) UNSIGNED"
    end
  end
end
