class AddSupLastFsrNo < ActiveRecord::Migration
  def change
    add_column :company_config, :sup_last_fsr_no, "INT(10) UNSIGNED NULL"
    add_column :company_config, :inv_last_srn_no, "INT(10) UNSIGNED NULL"
    add_column :company_config, :inv_last_srr_no, "INT(10) UNSIGNED NULL"
    add_column :company_config, :inv_last_sbn_no, "INT(10) UNSIGNED NULL"
    add_column :company_config, :inv_last_prn_no, "INT(10) UNSIGNED NULL"
    add_column :company_config, :inv_last_grn_no, "INT(10) UNSIGNED NULL"
    

    change_column :mst_inv_product_info, :need_serial, :boolean

    [
      { table_name: :inv_grn, column: :grn_no},
      { table_name: :inv_prn, column: :prn_no},
      { table_name: :inv_sbn, column: :sbn_no},
      { table_name: :inv_srn, column: :srn_no},
      { table_name: :inv_srr, column: :srr_no},
      { table_name: :spt_ticket, column: :ticket_no}
    ].each do |modify|
      execute "alter table #{modify[:table_name]} modify column #{modify[:column]} int unsigned not null;"
    end

    add_column :inv_gin, :gin_no, "INT UNSIGNED NOT NULL"
    add_column :mst_inv_product_info, :need_batch, :boolean

    remove_foreign_key :spt_product_serial, name: :fk_spt_product_serial_inv_inventory_serial_item1
    remove_foreign_key :inv_grn_serial_item, name: :fk_grn_serial_inventory_serial_item1
    remove_foreign_key :inv_inventory_serial_part, name: :fk_inv_inventory_serial_part_inv_inventory_serial_item1
    remove_foreign_key :inv_serial_additional_cost, name: :fk_inv_serial_warranty_inv_inventory_serial_item10
    remove_foreign_key :inv_serial_warranty, name: :fk_inv_serial_warranty_inv_inventory_serial_item1

    change_column :inv_inventory_serial_item, :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT"
    # execute "ALTER TABLE inv_inventory_serial_item ADD PRIMARY KEY(id);"


    add_foreign_key :spt_product_serial, :inv_inventory_serial_item, name: :fk_spt_product_serial_inv_inventory_serial_item1, column: :inventory_serial_item_id
    add_foreign_key :inv_grn_serial_item, :inv_inventory_serial_item, name: :fk_grn_serial_inventory_serial_item1, column: :serial_item_id
    add_foreign_key :inv_inventory_serial_part, :inv_inventory_serial_item, name: :fk_inv_inventory_serial_part_inv_inventory_serial_item1, column: :serial_item_id
    add_foreign_key :inv_serial_additional_cost, :inv_inventory_serial_item, name: :fk_inv_serial_warranty_inv_inventory_serial_item10, column: :serial_item_id
    add_foreign_key :inv_serial_warranty, :inv_inventory_serial_item, name: :fk_inv_serial_warranty_inv_inventory_serial_item1, column: :serial_item_id

    add_column :inv_srn_item, :main_product_id, "INT UNSIGNED NULL DEFAULT NULL"
    add_index :inv_srn_item, :main_product_id
    add_foreign_key :inv_srn_item, :mst_inv_product, name: :fk_srn_item_main_mst_product1, column: :main_product_id

    add_column :inv_gin_item, :main_product_id, "INT UNSIGNED NULL DEFAULT NULL"
    add_index :inv_gin_item, :main_product_id
    add_foreign_key :inv_gin_item, :mst_inv_product, name: :fk_gin_item_main_mst_product, column: :main_product_id

    add_column :spt_ticket_spare_part_store, :inv_gin_id, "INT UNSIGNED NULL DEFAULT NULL"
    add_column :spt_ticket_spare_part_store, :inv_gin_item_id, "INT UNSIGNED NULL DEFAULT NULL"
    add_index :spt_ticket_spare_part_store, :inv_gin_item_id
    add_foreign_key :spt_ticket_spare_part_store, :inv_gin, name: :fk_spt_ticket_spare_part_inv_gin_id, column: :inv_gin_id

    add_column :spt_ticket_on_loan_spare_part, :inv_gin_id, "INT UNSIGNED NULL DEFAULT NULL"
    add_column :spt_ticket_on_loan_spare_part, :inv_gin_item_id, "INT UNSIGNED NULL DEFAULT NULL"
    add_index :spt_ticket_on_loan_spare_part, :inv_gin_id
    add_index :spt_ticket_on_loan_spare_part, :inv_gin_item_id
    add_foreign_key :spt_ticket_on_loan_spare_part, :inv_gin, name: :fk_spt_ticket_on_loan_spare_part_inv_gin_id, column: :inv_gin_id
    add_foreign_key :spt_ticket_on_loan_spare_part, :inv_gin_item, name: :fk_spt_ticket_on_loan_spare_part_inv_gin_item_id, column: :inv_gin_item_id

    add_column :inv_gin_item, :inventory_not_updated, :boolean
    add_column :inv_grn_item, :inventory_not_updated, :boolean
    add_column :inv_grn_item, :main_product_id, "INT UNSIGNED NULL DEFAULT NULL"
    add_index :inv_grn_item, :main_product_id
    add_foreign_key :inv_grn_item, :mst_inv_product, name: :fk_grn_item_main_mst_product1, column: :main_product_id
    add_column :inv_grn_serial_item, :inv_serial_part_id, "INT UNSIGNED NULL DEFAULT NULL"
    add_index :inv_grn_serial_item, :inv_serial_part_id
    add_foreign_key :inv_grn_serial_item, :inv_inventory_serial_part, name: :fk_grn_serial_inventory_serial_part, column: :inv_serial_part_id

    add_column :inv_grn_serial_item, :remaining, :boolean

    [
      { table_name: :inv_inventory_serial_item, column: :batch_id},
    ].each do |modify|
      execute "alter table #{modify[:table_name]} modify column #{modify[:column]} int unsigned null default null;"
    end
  end
end