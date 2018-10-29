class AddSparePartInformationIdToSptTicketSparePart < ActiveRecord::Migration
  def change
    Inventory

    create_table :mst_spt_ticket_spare_part_information, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name, limit:200, null: false
      t.timestamps
    end
    
    add_column :spt_ticket_spare_part, :spare_part_information_id, "INT UNSIGNED NULL"
    add_index :spt_ticket_spare_part, :spare_part_information_id, name: "fk_spt_ticket_spare_part_mst_spt_ticket_spare_part_informat_idx"
    
    add_foreign_key :spt_ticket_spare_part, :mst_spt_ticket_spare_part_information, name: "fk_spt_ticket_spare_part_mst_spt_ticket_spare_part_information1", column: :spare_part_information_id


    add_column :spt_ticket_invoice, :delivery_address, :text #, "TEXT NULL"
    add_column :spt_ticket_invoice, :delivery_number_date, :string, limit: 100#"VARCHAR(100) NULL"
    add_column :spt_ticket_invoice, :so_number, :string, limit: 100 # "VARCHAR(100) NULL"
    add_column :spt_ticket_invoice, :po_number, :string, limit: 100 # "VARCHAR(100) NULL"


    add_column :inv_prn, :supplier_id, 'INT UNSIGNED NULL'
    add_index :inv_prn, :supplier_id, name: "fk_inv_prn_organzations1_idx"
    #InventoryPrn.update_all(supplier_id: Organization.organization_suppliers.first.id)

    add_foreign_key :inv_prn, :organizations, name: "fk_inv_prn_organzations1", column: :supplier_id

    add_column :spt_ticket_spare_part_manufacture, :'order_pending_at', :datetime, null:true
    add_column :spt_ticket_spare_part_manufacture, :'order_pending_by', "INT UNSIGNED NULL"
    add_index :spt_ticket_spare_part_manufacture, :order_pending_by, name: "ind_spt_ticket_spare_part_manufacture_order_pending_by"
    add_foreign_key :spt_ticket_spare_part_manufacture, :users, name: "fk_spt_ticket_spare_part_manufacture_order_pending_by", column: :order_pending_by

 
  end
end
