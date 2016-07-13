class AddModification1ToTable < ActiveRecord::Migration
  def change

    add_column :company_config, :inv_last_gin_no, "INT UNSIGNED NULL DEFAULT NULL"
    add_column :spt_ticket_spare_part_store, :cost_price, :decimal, scale: 2, precision: 10, default: nil
    add_column :spt_ticket_on_loan_spare_part, :cost_price, :decimal, scale: 2, precision: 10, default: nil
    add_column :spt_act_request_spare_part, :inv_srr_id, "INT UNSIGNED NULL DEFAULT NULL"
    add_column :spt_act_request_spare_part, :inv_srr_item_id, "INT UNSIGNED NULL DEFAULT NULL"
    add_column :spt_act_request_on_loan_spare_part, :inv_srr_id, "INT UNSIGNED NULL DEFAULT NULL"
    add_column :spt_act_request_on_loan_spare_part, :inv_srr_item_id, "INT UNSIGNED NULL DEFAULT NULL"

    [
      { table_name: :inv_srr_item, column: :product_condition_id},
      { table_name: :inv_srr_item, column: :return_reason_id},
      { table_name: :inv_srr_item_source, column: :currency_id}
    ].each do |modify|
      execute "alter table #{modify[:table_name]} modify column #{modify[:column]} int unsigned null default null;"
    end

    add_index :spt_act_request_on_loan_spare_part, :inv_srr_id
    add_index :spt_act_request_on_loan_spare_part, :inv_srr_item_id
    add_index :spt_act_request_spare_part, :inv_srr_id
    add_index :spt_act_request_spare_part, :inv_srr_item_id

    add_foreign_key :spt_act_request_spare_part, :inv_srr, name: "fk_spt_act_request_spare_part_inv_srr_id", column: :inv_srr_id, on_delete: :restrict, on_update: :restrict
    add_foreign_key :spt_act_request_spare_part, :inv_srr_item, name: "fk_spt_act_request_spare_part_inv_srr_item_id", column: :inv_srr_item_id, on_delete: :restrict, on_update: :restrict
    add_foreign_key :spt_act_request_on_loan_spare_part, :inv_srr, name: "fk_spt_act_request_on_loan_spare_part_inv_srr_id", column: :inv_srr_id, on_delete: :restrict, on_update: :restrict
    add_foreign_key :spt_act_request_on_loan_spare_part, :inv_srr_item, name: "fk_spt_act_request_on_loan_spare_part_inv_srr_item_id", column: :inv_srr_item_id, on_delete: :restrict, on_update: :restrict

    change_column :inv_srr_item_source, :unit_cost, :decimal, precision: 13, scale: 2, default: nil

    # create_table :inv_grn_serial_part, id: false do |t|
    #   t.column :id, "INT UNSIGNED NOT NULL, PRIMARY KEY (id)"
    #   t.column :grn_item_id, "INT UNSIGNED NOT NULL"
    #   t.column :serial_item_id, "INT UNSIGNED NOT NULL"
    #   t.column :inv_serial_part_id, "INT UNSIGNED DEFAULT NULL"
    #   t.boolean :remaining, null: false, default: true

    #   t.index :grn_item_id, name: "fk_grn_item_part"
    #   t.index :serial_item_id, name: "fk_grn_serial_inventory_serial_item_part"
    #   t.index :inv_serial_part_id, name: "fk_inv_serial_part_id_part"
    # end

    # add_foreign_key :inv_grn_serial_part, :inv_grn_item, name: "fk_grn_item_part", column: :grn_item_id, on_delete: :restrict, on_update: :restrict
    # add_foreign_key :inv_grn_serial_part, :inv_inventory_serial_item, name: "fk_grn_serial_inventory_serial_item_part", column: :serial_item_id, on_delete: :restrict, on_update: :restrict
    # add_foreign_key :inv_grn_serial_part, :inv_inventory_serial_part, name: "fk_inv_serial_part_id_part", column: :inv_serial_part_id, on_delete: :restrict, on_update: :restrict

    remove_foreign_key :inv_grn_serial_item, column: :inv_serial_part_id
    remove_index :inv_grn_serial_item, column: :inv_serial_part_id
    remove_column :inv_grn_serial_item, :inv_serial_part_id

    add_column :inv_gin_source, :grn_serial_part_id, "INT UNSIGNED NULL DEFAULT NULL"
    add_column :inv_gin_source, :main_part_grn_serial_item_id, "INT UNSIGNED NULL DEFAULT NULL"

    add_index :inv_gin_source, :grn_serial_part_id
    add_index :inv_gin_source, :main_part_grn_serial_item_id
    # add_foreign_key :inv_gin_source, :inv_grn_serial_part, name: "fk_gin_source_grn_serial_part", column: :grn_serial_part_id, on_delete: :restrict, on_update: :restrict
    # add_foreign_key :inv_gin_source, :inv_grn_serial_item, name: "fk_gin_source_main_part_grn_serial_item", column: :main_part_grn_serial_item_id, on_delete: :restrict, on_update: :restrict

    remove_foreign_key :inv_gin_source, column: :serial_part_id
    remove_index :inv_gin_source, name: "fk_inv_gin_source_inv_inventory_serial_part1"
    remove_column :inv_gin_source, :serial_part_id

    add_column :spt_ticket_spare_part, :part_returned_at, :datetime, default: nil, null: true
    add_column :spt_ticket_spare_part, :part_returned_by, "INT UNSIGNED NULL DEFAULT NULL"
    add_index :spt_ticket_spare_part, :part_returned_by
    add_foreign_key :spt_ticket_spare_part, :users, name: "fk_spt_ticket_spare_part_part_return_by", column: :part_returned_by, on_delete: :restrict, on_update: :restrict

    add_column :spt_ticket_spare_part_manufacture, :issued_at, :datetime, default: nil, null: true
    add_column :spt_ticket_spare_part_manufacture, :issued_by, "INT UNSIGNED NULL DEFAULT NULL"
    add_index :spt_ticket_spare_part_manufacture, :issued_by
    add_foreign_key :spt_ticket_spare_part_manufacture, :users, name: "fk_spt_ticket_spare_part_manufacture_users2", column: :issued_by, on_delete: :restrict, on_update: :restrict

    rename_column :spt_ticket_spare_part_store, :store_issued, :issued
    rename_column :spt_ticket_spare_part_store, :store_issued_at, :issued_at
    # rename_column :spt_ticket_spare_part_store, :store_issued_by, :issued_by #unable to change. because it is indexed
    rename_column :spt_ticket_on_loan_spare_part, :isssued_at, :issued_at

    add_column :inv_damage, :grn_serial_part_id, "INT UNSIGNED NULL DEFAULT NULL"
    add_index :inv_damage, :grn_serial_part_id
    # add_foreign_key :inv_damage, :inv_grn_serial_part, name: "fk_inventory_damage_grn_serial_part", column: :grn_serial_part_id, on_delete: :restrict, on_update: :restrict

    remove_foreign_key :inv_damage, name: "fk_inv_damage_inv_inventory_serial_part1"
    remove_column :inv_damage, :serial_part_id

    add_column :inv_inventory, :damage_quantity, :decimal, null: false, default: 0, scale: 3, precision: 13
    change_column :inv_inventory_serial_part, :serial_no, :string, null: true
  end
end