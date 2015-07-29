class ModificationOfSptTicketSparePart < ActiveRecord::Migration
  def change
    remove_column :spt_ticket_spare_part, :request_from_manufacture
    remove_column :spt_ticket_spare_part, :request_from_store

    # execute "ALTER TABLE `spt_ticket_spare_part` ADD `request_from` VARCHAR( 10 ) NOT NULL DEFAULT 'M' COMMENT 'M - Manufacture (request from warranty), S - Store (can be corporate-warranty or non-warrranty)' AFTER `cus_chargeable_part`"

    add_column :spt_ticket_spare_part, :request_from, :string, limit: 10, null: false, default: "M", comment: 'M - Manufacture (request from warranty), S - Store (can be corporate-warranty or non-warrranty)', after: :cus_chargeable_part
  end
end
