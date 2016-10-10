class ModifyRolesRelatedTables < ActiveRecord::Migration
  def change
    remove_column :rpermissions, :controller_resource, :controller_action

    add_column :roles_rpermissions, :subject_value, :string

    create_table :subject_classes, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      t.column :subject_base_id, "INT UNSIGNED"
      t.timestamps

      t.index :subject_base_id, name: "fk_system_resources_resource_bases1_idx"
    end

    create_table :subject_attributes, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      t.timestamps
    end

    create_table :subject_actions, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      t.column :subject_action_alias_id, "INT UNSIGNED"
      t.timestamps

      t.index :subject_action_alias_id, name: "fk_subject_actions_subject_actions1_idx"
    end

    create_table :subject_bases, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      t.timestamps
    end


    add_column :rpermissions, :subject_class_id, "INT UNSIGNED NOT NULL"
    add_column :rpermissions, :subject_attribute_id, "INT UNSIGNED NOT NULL"
    add_column :rpermissions, :subject_action_id, "INT UNSIGNED NOT NULL"

    add_index :rpermissions, :subject_class_id, name: "fk_main_permissions_subject_classes1_idx"
    add_index :rpermissions, :subject_attribute_id, name: "fk_main_permissions_main_permissions2_idx"
    add_index :rpermissions, :subject_action_id, name: "fk_main_permissions_main_permissions1_idx"

    add_foreign_key(:subject_classes, :subject_bases, name: "fk_system_resources_resource_bases1", column: :subject_base_id)
    add_foreign_key(:subject_actions, :subject_actions, name: "fk_system_resources_resource_actions1", column: :subject_action_alias_id)

    execute "SET FOREIGN_KEY_CHECKS = 0"
    add_foreign_key(:rpermissions, :subject_classes, name: "fk_main_permissions_subject_classes1", column: :subject_class_id)
    add_foreign_key(:rpermissions, :subject_attributes, name: "fk_main_permissions_main_permissions2", column: :subject_attribute_id)
    add_foreign_key(:rpermissions, :subject_actions, name: "fk_main_permissions_main_permissions1", column: :subject_action_id)
    execute "SET FOREIGN_KEY_CHECKS = 1"
  end
end
