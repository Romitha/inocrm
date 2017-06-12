class RpermissionColumnUpdate < ActiveRecord::Migration
  def change

    remove_foreign_key :rpermissions, name: :fk_main_permissions_main_permissions2
    remove_index :rpermissions, name: :fk_main_permissions_main_permissions2_idx
    remove_column :rpermissions, :subject_attribute_id

    remove_foreign_key :rpermissions, name: :fk_main_permissions_main_permissions1
    remove_index :rpermissions, name: :fk_main_permissions_main_permissions1_idx
    remove_column :rpermissions, :subject_action_id

    # remove_column :spt_ticket, :updated_by

    add_column :subject_actions, :value, :string
    add_column :subject_actions, :rpermission_id, "INT UNSIGNED NOT NULL"
    add_index :subject_actions, :rpermission_id, name: "fk_subject_actions_rpermission_id1_idx"
    execute "SET FOREIGN_KEY_CHECKS = 0"
    add_foreign_key :subject_actions, :rpermissions, name: "fk_subject_actions_rpermissions", column: :rpermission_id
    execute "SET FOREIGN_KEY_CHECKS = 1"

    add_column :subject_attributes, :rpermission_id, "INT(10) UNSIGNED NOT NULL"
    add_index :subject_attributes, :rpermission_id, name: "fk_subject_attributes_rpermission_id1_idx"
    execute "SET FOREIGN_KEY_CHECKS = 0"
    add_foreign_key :subject_attributes, :rpermissions, name: "fk_subject_attributes_rpermissions", column: :rpermission_id
    execute "SET FOREIGN_KEY_CHECKS = 1"
  end
end
