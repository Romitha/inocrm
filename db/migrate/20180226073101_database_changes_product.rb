class DatabaseChangesProduct < ActiveRecord::Migration
  def change
    add_column :spt_product_serial, :sla_id, "INT UNSIGNED NULL"
  	add_index :spt_product_serial, :sla_id, name: "fk_spt_product_serial_mst_spt_sla1_idx"
    add_foreign_key :spt_product_serial, :mst_spt_sla, name: :fk_spt_product_serial_mst_spt_sla1, column: :sla_id
    
    add_column :spt_ticket_spare_part, :received_eng_by, "INT UNSIGNED NULL"
    add_column :spt_ticket_spare_part, :received_eng_at, "DATETIME NULL"
  	add_index :spt_ticket_spare_part, :received_eng_by, name: "fk_spt_ticket_spare_part_users4_idx"
    add_foreign_key :spt_ticket_spare_part, :users, name: :fk_spt_ticket_spare_part_users4, column: :received_eng_by

    add_column :mst_spt_sbu, :active, :boolean, null:false, default:1
    add_column :mst_spt_sbu_engineer, :active, :boolean, null:false, default:1

    add_column :spt_contract, :product_category1_id, "INT UNSIGNED NULL"
    add_column :spt_contract, :product_category2_id, "INT UNSIGNED NULL"
  	add_index :spt_contract, :product_category1_id, name: "fk_spt_contract_mst_spt_product_category11_idx"
  	add_index :spt_contract, :product_category2_id, name: "fk_spt_contract_mst_spt_product_category21_idx"
    add_foreign_key :spt_contract, :mst_spt_product_category1, name: :fk_spt_contract_mst_spt_product_category11, column: :product_category1_id
    add_foreign_key :spt_contract, :mst_spt_product_category2, name: :fk_spt_contract_mst_spt_product_category21, column: :product_category2_id

    add_column :company_config, :sup_model_no_label, :string, limit:100, null:false, default:"Model No"
    add_column :company_config, :sup_product_no_label, :string, limit:100, null:false, default:"Product No"

  end
end