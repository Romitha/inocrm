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

    create_table :inv_grn_serial_part, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL, PRIMARY KEY (id)"
      t.column :grn_item_id, "INT UNSIGNED NOT NULL"
      t.column :serial_item_id, "INT UNSIGNED NOT NULL"
      t.column :inv_serial_part_id, "INT UNSIGNED DEFAULT NULL"
      t.boolean :remaining, null: false, default: true

      t.index :grn_item_id, name: "fk_grn_item_part"
      t.index :serial_item_id, name: "fk_grn_serial_inventory_serial_item_part"
      t.index :inv_serial_part_id, name: "fk_inv_serial_part_id_part"
    end

    add_foreign_key :inv_grn_serial_part, :inv_grn_item, name: "fk_grn_item_part", column: :grn_item_id, on_delete: :restrict, on_update: :restrict
    add_foreign_key :inv_grn_serial_part, :inv_inventory_serial_item, name: "fk_grn_serial_inventory_serial_item_part", column: :serial_item_id, on_delete: :restrict, on_update: :restrict
    add_foreign_key :inv_grn_serial_part, :inv_inventory_serial_part, name: "fk_inv_serial_part_id_part", column: :inv_serial_part_id, on_delete: :restrict, on_update: :restrict

    remove_foreign_key :inv_grn_serial_item, column: :inv_serial_part_id
    remove_index :inv_grn_serial_item, column: :inv_serial_part_id
    remove_column :inv_grn_serial_item, :inv_serial_part_id

    add_column :inv_gin_source, :grn_serial_part_id, "INT UNSIGNED NULL DEFAULT NULL"
    add_column :inv_gin_source, :main_part_grn_serial_item_id, "INT UNSIGNED NULL DEFAULT NULL"

    add_index :inv_gin_source, :grn_serial_part_id
    add_index :inv_gin_source, :main_part_grn_serial_item_id
    add_foreign_key :inv_gin_source, :inv_grn_serial_part, name: "fk_gin_source_grn_serial_part", column: :grn_serial_part_id, on_delete: :restrict, on_update: :restrict
    add_foreign_key :inv_gin_source, :inv_grn_serial_item, name: "fk_gin_source_main_part_grn_serial_item", column: :main_part_grn_serial_item_id, on_delete: :restrict, on_update: :restrict

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
    rename_column :spt_ticket_on_loan_spare_part, :isssued_at, :issued_at

    add_column :inv_damage, :grn_serial_part_id, "INT UNSIGNED NULL DEFAULT NULL"
    add_index :inv_damage, :grn_serial_part_id
    add_foreign_key :inv_damage, :inv_grn_serial_part, name: "fk_inventory_damage_grn_serial_part", column: :grn_serial_part_id, on_delete: :restrict, on_update: :restrict

    remove_foreign_key :inv_damage, name: "fk_inv_damage_inv_inventory_serial_part1"
    remove_column :inv_damage, :serial_part_id

    add_column :inv_inventory, :damage_quantity, :decimal, null: false, default: 0, scale: 3, precision: 13
    change_column :inv_inventory_serial_part, :serial_no, :string, null: true
  end
end


# ALTER TABLE `spt_ticket_spare_part_store` ADD `cost_price` DECIMAL(10, 2) NULL DEFAULT NULL COMMENT 'grn price' AFTER `inv_gin_item_id`;
# ALTER TABLE `company_config` ADD `inv_last_gin_no` INT UNSIGNED NULL DEFAULT NULL AFTER `inv_last_grn_no`;
# ALTER TABLE `spt_ticket_on_loan_spare_part` ADD `cost_price` DECIMAL(10,2) NULL DEFAULT NULL COMMENT 'grn price' AFTER `inv_gin_item_id`;
# ALTER TABLE `spt_act_request_spare_part` ADD `inv_srr_id` INT(10) UNSIGNED NULL DEFAULT NULL COMMENT 'return or reject return' AFTER `reject_return_part_reason_id`, ADD `inv_srr_item_id` INT(10) UNSIGNED NULL DEFAULT NULL COMMENT 'return or reject return' AFTER `inv_srr_id`;
# ALTER TABLE `spt_act_request_on_loan_spare_part` ADD `inv_srr_id` INT(10) UNSIGNED NULL DEFAULT NULL COMMENT 'return or reject return' AFTER `ticket_on_loan_spare_part_id`, ADD `inv_srr_item_id` INT(10) UNSIGNED NULL DEFAULT NULL COMMENT 'return or reject return' AFTER `inv_srr_id`, ADD INDEX (`inv_srr_id`), ADD INDEX (`inv_srr_item_id`);

# ALTER TABLE `inv_srr_item` CHANGE `product_condition_id` `product_condition_id` INT(10) UNSIGNED NULL DEFAULT NULL;
# ALTER TABLE `inv_srr_item` CHANGE `return_reason_id` `return_reason_id` INT(10) UNSIGNED NULL DEFAULT NULL COMMENT 'returned from support ticket this is null';
# ALTER TABLE `inv_srr_item_source` CHANGE `currency_id` `currency_id` INT(10) UNSIGNED NULL DEFAULT NULL;

# ALTER TABLE `spt_act_request_spare_part` ADD INDEX(`inv_srr_id`);
# ALTER TABLE `spt_act_request_spare_part` ADD INDEX(`inv_srr_item_id`);

# ALTER TABLE `spt_act_request_spare_part` ADD CONSTRAINT `fk_spt_act_request_spare_part_inv_srr_id` FOREIGN KEY (`inv_srr_id`) REFERENCES `inocrm_dev`.`inv_srr`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
# ALTER TABLE `spt_act_request_spare_part` ADD CONSTRAINT `fk_spt_act_request_spare_part_inv_srr_item_id` FOREIGN KEY (`inv_srr_item_id`) REFERENCES `inocrm_dev`.`inv_srr_item`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
# ALTER TABLE `spt_act_request_on_loan_spare_part` ADD CONSTRAINT `fk_spt_act_request_on_loan_spare_part_inv_srr_id` FOREIGN KEY (`inv_srr_id`) REFERENCES `inocrm_dev`.`inv_srr`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
# ALTER TABLE `spt_act_request_on_loan_spare_part` ADD CONSTRAINT `fk_spt_act_request_on_loan_spare_part_inv_srr_item_id` FOREIGN KEY (`inv_srr_item_id`) REFERENCES `inocrm_dev`.`inv_srr_item`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

# ALTER TABLE `inv_srr_item_source` CHANGE `unit_cost` `unit_cost` DECIMAL(13,2) NULL DEFAULT NULL;

# CREATE TABLE IF NOT EXISTS `inv_grn_serial_part` (
#   `id` int(10) unsigned NOT NULL,
#   `grn_item_id` int(10) unsigned NOT NULL,
#   `serial_item_id` int(10) unsigned NOT NULL,
#   `inv_serial_part_id` int(10) unsigned DEFAULT NULL COMMENT 'Part of main product',
#   `remaining` tinyint(4) NOT NULL DEFAULT '1',
#   `created_at` datetime DEFAULT NULL,
#   `updated_at` datetime DEFAULT NULL
# ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

# ALTER TABLE `inv_grn_serial_part`
#   ADD PRIMARY KEY (`id`),
#   ADD KEY `fk_grn_item_part` (`grn_item_id`),
#   ADD KEY `fk_grn_serial_inventory_serial_item_part` (`serial_item_id`),
#   ADD KEY `fk_inv_serial_part_id_part` (`inv_serial_part_id`);


# ALTER TABLE `inv_grn_serial_part`
#   MODIFY `id` int(10) unsigned NOT NULL AUTO_INCREMENT;

# ALTER TABLE `inv_grn_serial_part`
#   ADD CONSTRAINT `fk_grn_item_part` FOREIGN KEY (`grn_item_id`) REFERENCES `inv_grn_item` (`id`),
#   ADD CONSTRAINT `fk_grn_serial_inventory_serial_item_part` FOREIGN KEY (`serial_item_id`) REFERENCES `inv_inventory_serial_item` (`id`),
#   ADD CONSTRAINT `fk_inv_serial_part_id_part` FOREIGN KEY (`inv_serial_part_id`) REFERENCES `inv_inventory_serial_part` (`id`);


#   DELETE inv_inventory_serial_part_id from inv_grn_serial_item with foreign key and index

#   ALTER TABLE `inv_gin_source` ADD `grn_serial_part_id` INT(10) UNSIGNED NULL DEFAULT NULL AFTER `serial_part_id`, ADD `main_part_grn_serial_item_id` INT(10) UNSIGNED NULL DEFAULT NULL COMMENT 'grn info of main part ' AFTER `grn_serial_part_id`, ADD INDEX (`grn_serial_part_id`), ADD INDEX (`main_part_grn_serial_item_id`);


#   ALTER TABLE `inv_gin_source` ADD CONSTRAINT `fk_gin_source_grn_serial_part` FOREIGN KEY (`grn_serial_part_id`) REFERENCES `inocrm_dev`.`inv_grn_serial_part`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT; ALTER TABLE `inv_gin_source` ADD CONSTRAINT `fk_gin_source_main_part_grn_serial_item` FOREIGN KEY (`main_part_grn_serial_item_id`) REFERENCES `inocrm_dev`.`inv_grn_serial_item`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

#   delete serial_part_id from inv_gin_source with foreign key and index


# ALTER TABLE `spt_ticket_spare_part` ADD `part_returned_at` DATETIME NULL DEFAULT NULL AFTER `part_returned`, ADD `part_returned_by` INT(10) UNSIGNED NULL DEFAULT NULL AFTER `part_returned_at`, ADD INDEX (`part_returned_by`);
# ALTER TABLE `spt_ticket_spare_part` ADD CONSTRAINT `fk_spt_ticket_spare_part_part_return_by` FOREIGN KEY (`part_returned_by`) REFERENCES `inocrm_dev`.`users`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

# ALTER TABLE `spt_ticket_spare_part_manufacture` ADD `issued_at` DATETIME NULL DEFAULT NULL AFTER `issued`, ADD `issued_by` INT(10) UNSIGNED NULL DEFAULT NULL AFTER `issued_at`, ADD INDEX (`issued_by`);
# ALTER TABLE `spt_ticket_spare_part_manufacture` ADD CONSTRAINT `fk_spt_ticket_spare_part_manufacture_users2` FOREIGN KEY (`issued_by`) REFERENCES `inocrm_dev`.`users`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

# ALTER TABLE `spt_ticket_spare_part_store` CHANGE `store_issued` `issued` TINYINT(1) NOT NULL DEFAULT '0', CHANGE `store_issued_at` `issued_at` DATETIME NULL DEFAULT NULL, CHANGE `store_issued_by` `issued_by` INT(10) UNSIGNED NULL DEFAULT NULL;
# ALTER TABLE `spt_ticket_on_loan_spare_part` CHANGE `isssued_at` `issued_at` DATETIME NULL DEFAULT NULL;
# ALTER TABLE `inv_damage` ADD `grn_serial_part_id` INT(10) UNSIGNED NULL DEFAULT NULL AFTER `grn_serial_item_id`, ADD INDEX (`grn_serial_part_id`);
# ALTER TABLE `inv_damage` ADD CONSTRAINT `fk_inventory_damage_grn_serial_part` FOREIGN KEY (`grn_serial_part_id`) REFERENCES `inocrm_dev`.`inv_grn_serial_part`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

# ALTER TABLE inv_damage DROP FOREIGN KEY fk_inv_damage_inv_inventory_serial_part1;
# ALTER TABLE `inv_damage` DROP `serial_part_id`;


# ALTER TABLE `inv_inventory` ADD `damage_quantity` DECIMAL(13,3) NOT NULL DEFAULT '0' AFTER `reserved_quantity`;

# ALTER TABLE `inocrm_dev`.`inv_inventory_serial_part` 
# CHANGE COLUMN `serial_no` `serial_no` VARCHAR(255) CHARACTER SET 'utf8' NULL ;