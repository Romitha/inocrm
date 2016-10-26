class AddOnsiteTypeTable < ActiveRecord::Migration
  def change

    create_table :mst_spt_onsite_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code
      t.string :name
      t.timestamps
    end

    add_column :spt_ticket, :onsite_type_id, "INT UNSIGNED"
    add_index :spt_ticket, :onsite_type_id, name: "fk_spt_ticket_mst_spt_onsite_type1_idx"
    add_foreign_key(:spt_ticket, :mst_spt_onsite_type, name: "fk_spt_ticket_mst_spt_onsite_type1", column: :onsite_type_id)
 
    add_column :spt_ticket_spare_part_manufacture, :requested_quantity, :decimal, scale: 3, precision: 13, null: false

    add_column :spt_ticket_spare_part_store, :requested_quantity, :decimal, scale: 3, precision: 13, default: 1, null: false
    add_column :spt_ticket_spare_part_store, :approved_quantity, :decimal, scale: 3, precision: 13
    add_column :spt_ticket_spare_part_store, :returned_quantity, :decimal, scale: 3, precision: 13

    add_column :spt_ticket_on_loan_spare_part, :requested_quantity, :decimal, scale: 3, precision: 13, default: 1, null: false
    add_column :spt_ticket_on_loan_spare_part, :approved_quantity, :decimal, scale: 3, precision: 13, default: 1

  end
end