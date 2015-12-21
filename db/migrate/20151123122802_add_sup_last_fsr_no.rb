class AddSupLastFsrNo < ActiveRecord::Migration
  def change
    add_column :company_config, :sup_last_fsr_no, "INT(10) UNSIGNED NULL"
    add_column :company_config, :inv_last_srn_no, "INT(10) UNSIGNED NULL"
    add_column :company_config, :inv_last_srr_no, "INT(10) UNSIGNED NULL"
    add_column :company_config, :inv_last_sbn_no, "INT(10) UNSIGNED NULL"
    add_column :company_config, :inv_last_prn_no, "INT(10) UNSIGNED NULL"
    add_column :company_config, :inv_last_grn_no, "INT(10) UNSIGNED NULL"
    

    change_column :spt_ticket, :ticket_no, "INT(11) UNSIGNED NOT NULL"
    change_column :inv_grn, :grn_no, "INT UNSIGNED NOT NULL"
    change_column :inv_prn, :prn_no, "INT UNSIGNED NOT NULL"
    change_column :inv_prn, :prn_no, "INT UNSIGNED NOT NULL"
    change_column :inv_sbn, :sbn_no, "INT UNSIGNED NOT NULL"
    change_column :inv_srn, :srn_no, "INT UNSIGNED NOT NULL"
    change_column :inv_srr, :srr_no, "INT UNSIGNED NOT NULL"
    change_column :mst_inv_product_info, :need_serial, :boolean
    change_column :inv_inventory_serial_item, :batch_id, "INT UNSIGNED NULL DEFAULT NULL"

    #______________________________test_____________________________________________________
    # change_column :inv_inventory_serial_item, :batch_id, :integer, default: nil
    # change_column :inv_inventory_serial_item, :batch_id, "INT DEFAULT NULL"
    # change_column :inv_inventory_serial_item, :batch_id, "INT UNSIGNED NULL DEFAULT NULL"
    # change_column :inv_inventory_serial_item, :batch_id, :integer, :default => nil, :null => true
    #_______________________________________________________________________________________________

    add_column :inv_gin, :gin_no, "INT UNSIGNED NOT NULL"
    add_column :mst_inv_product_info, :need_batch, :boolean

    remove_foreign_key :spt_product_serial, name: :fk_spt_product_serial_inv_inventory_serial_item1
    remove_foreign_key :inv_grn_serial_item, name: :fk_grn_serial_inventory_serial_item1
    remove_foreign_key :inv_inventory_serial_part, name: :fk_inv_inventory_serial_part_inv_inventory_serial_item1
    remove_foreign_key :inv_serial_additional_cost, name: :fk_inv_serial_warranty_inv_inventory_serial_item10
    remove_foreign_key :inv_serial_warranty, name: :fk_inv_serial_warranty_inv_inventory_serial_item1

    change_column :inv_inventory_serial_item, :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT"
    execute "ALTER TABLE inv_inventory_serial_item ADD PRIMARY KEY(id);"


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
  end
end


# ALTER TABLE `spt_ticket` CHANGE `ticket_no` `ticket_no` INT(11) UNSIGNED NOT NULL; - DONE
# ALTER TABLE `inv_gin` ADD `gin_no` INT UNSIGNED NOT NULL AFTER `id`; - DONE
# ALTER TABLE `inv_grn` CHANGE `grn_no` `grn_no` INT UNSIGNED NOT NULL;
# ALTER TABLE `inv_prn` CHANGE `prn_no` `prn_no` INT UNSIGNED NOT NULL;
# ALTER TABLE `inv_sbn` CHANGE `sbn_no` `sbn_no` INT UNSIGNED NOT NULL;
# ALTER TABLE `inv_srn` CHANGE `srn_no` `srn_no` INT UNSIGNED NOT NULL;
# ALTER TABLE `inv_srr` CHANGE `srr_no` `srr_no` INT UNSIGNED NOT NULL;
# ALTER TABLE `mst_inv_product_info` ADD `need_batch` TINYINT NOT NULL DEFAULT '0' AFTER `need_serial`;
# ALTER TABLE `mst_inv_product_info` CHANGE `need_serial` `need_serial` TINYINT(1) NOT NULL DEFAULT '0';
# ALTER TABLE `inv_inventory_serial_item` CHANGE `batch_id` `batch_id` INT(10) UNSIGNED NULL DEFAULT NULL;
# ALTER TABLE `inv_srn_item` ADD `main_product_id` INT UNSIGNED NULL DEFAULT NULL AFTER `spare_part`;
# ALTER TABLE `inv_srn_item` ADD INDEX( `main_product_id`);
# ALTER TABLE `inv_srn_item` ADD CONSTRAINT `fk_srn_item_main_mst_product1` FOREIGN KEY (`main_product_id`) REFERENCES `inocrm_dev`.`mst_inv_product`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
# ALTER TABLE `inv_gin_item` ADD `main_product_id` INT UNSIGNED NULL DEFAULT NULL AFTER `currency_id`, ADD INDEX (`main_product_id`);
# ALTER TABLE `inv_gin_item` ADD CONSTRAINT `fk_gin_item_main_mst_product` FOREIGN KEY (`main_product_id`) REFERENCES `inocrm_dev`.`mst_inv_product`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
# ALTER TABLE `spt_ticket_spare_part_store` ADD `inv_gin_id` INT UNSIGNED NULL DEFAULT NULL AFTER `inv_srn_item_id`, ADD `inv_gin_item_id` INT UNSIGNED NULL DEFAULT NULL AFTER `inv_gin_id`, ADD INDEX (`inv_gin_id`), ADD INDEX (`inv_gin_item_id`);
# ALTER TABLE `spt_ticket_spare_part_store` ADD CONSTRAINT `fk_spt_ticket_spare_part_inv_gin_id` FOREIGN KEY (`inv_gin_id`) REFERENCES `inocrm_dev`.`inv_gin`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT; ALTER TABLE `spt_ticket_spare_part_store` ADD CONSTRAINT `fk_spt_ticket_spare_part_inv_gin_item_id` FOREIGN KEY (`inv_gin_item_id`) REFERENCES `inocrm_dev`.`inv_gin_item`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
# ALTER TABLE `spt_ticket_on_loan_spare_part` ADD `inv_gin_id` INT UNSIGNED NULL DEFAULT NULL AFTER `inv_srn_item_id`, ADD `inv_gin_item_id` INT UNSIGNED NULL DEFAULT NULL AFTER `inv_gin_id`, ADD INDEX (`inv_gin_id`), ADD INDEX (`inv_gin_item_id`);
# ALTER TABLE `spt_ticket_on_loan_spare_part` ADD CONSTRAINT `fk_spt_ticket_on_loan_spare_part_inv_gin_id` FOREIGN KEY (`inv_gin_id`) REFERENCES `inocrm_dev`.`inv_gin`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT; ALTER TABLE `spt_ticket_on_loan_spare_part` ADD CONSTRAINT `fk_spt_ticket_on_loan_spare_part_inv_gin_item_id` FOREIGN KEY (`inv_gin_item_id`) REFERENCES `inocrm_dev`.`inv_gin_item`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
# ALTER TABLE `inv_gin_item` ADD `inventory_not_updated` TINYINT NOT NULL DEFAULT '0' AFTER `spare_part`;
# ALTER TABLE `inv_grn_item` ADD `inventory_not_updated` TINYINT NOT NULL DEFAULT '0' AFTER `srr_item_id`;
# ALTER TABLE `inv_grn_item` ADD `main_product_id` INT UNSIGNED NULL DEFAULT NULL AFTER `inventory_not_updated`, ADD INDEX (`main_product_id`);
# ALTER TABLE `inv_grn_item` ADD CONSTRAINT `fk_grn_item_main_mst_product1` FOREIGN KEY (`main_product_id`) REFERENCES `inocrm_dev`.`mst_inv_product`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
# ALTER TABLE `inv_grn_serial_item` ADD `inv_serial_part_id` INT UNSIGNED NULL DEFAULT NULL COMMENT 'Part of main product' AFTER `serial_item_id`, ADD INDEX (`inv_serial_part_id`);
# ALTER TABLE `inv_grn_serial_item` ADD CONSTRAINT `fk_grn_serial_inventory_serial_part` FOREIGN KEY (`inv_serial_part_id`) REFERENCES `inocrm_dev`.`inv_inventory_serial_part`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;



# add_foreign_key :articles, :authors

# ALTER TABLE `inv_grn_serial_item` ADD `remaining` TINYINT NOT NULL DEFAULT '1' AFTER `inv_serial_part_id`;

# This adds a new foreign key to the author_id column of the articles table. The key references the id column of the authors table. If the column names can not be derived from the table names, you can use the :column and :primary_key options.
