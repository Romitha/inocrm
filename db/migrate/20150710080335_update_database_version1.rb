class UpdateDatabaseVersion1 < ActiveRecord::Migration
  def change
  	[
      {constraint_name: "FK_spt_act_warranty_repair_type_mst_spt_warranty_type", foreign_key: "ticket_warranty_type_id", reference_table: "mst_spt_warranty_type"},
      {constraint_name: "FK_spt_act_warranty_repair_type_mst_spt_ticket_repair_type", foreign_key: "ticket_repair_type_id", reference_table: "mst_spt_ticket_repair_type"},
      {constraint_name: "FK__spt_ticket_action", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_warranty_repair_type` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

     create_table :spt_act_warranty_repair_type, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL , PRIMARY KEY (ticket_action_id)"
      t.column :ticket_warranty_type_id, "int(10) UNSIGNED"
      t.column :ticket_repair_type_id, "int(10) UNSIGNED"
      t.boolean :cus_chargeable
      t.timestamps
    end
  end
end
