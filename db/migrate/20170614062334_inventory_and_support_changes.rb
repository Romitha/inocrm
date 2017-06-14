class InventoryAndSupportChanges < ActiveRecord::Migration
  def change
    add_column :mst_inv_product, :purchase_request_type, :integer, null:false, default:0

    remove_column :company_config, :sup_contract_reminder_email
    add_column :company_config, :sup_contract_reminder_email, :string, limit:255

    add_column :spt_contract_document, :name, :string, limit:255


    create_table :inv_prn_srn_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :prn_item_id, "INT UNSIGNED NOT NULL"
      t.column :srn_item_id, "INT UNSIGNED NOT NULL"

      t.index :prn_item_id, name: "fk_inv_prn_srn_item_inv_prn_item1_idx"
      t.index :srn_item_id, name: "fk_inv_prn_srn_item_inv_srn_item1_idx"
    end

    create_table :mst_spt_contract_annexture, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :template_name, null: false, limit:255
      t.string :name, null: false, limit:255
      t.text :document_url
      t.datetime :created_at, null: false
      t.column :created_by, "INT UNSIGNED NULL"
      t.datetime :updated_at
      t.column :updated_by, "INT UNSIGNED NULL"

      t.index :created_by, name: "fk_spt_contract_documents_users1_idx"
      t.index :updated_by, name: "fk_spt_contract_documents_users2_idx"
    end


    execute "SET FOREIGN_KEY_CHECKS = 0"
    [
      { table: :inv_prn_srn_item, reference_table: :inv_prn_item, name: "fk_inv_prn_srn_item_inv_prn_item1", column: :prn_item_id },
      { table: :inv_prn_srn_item, reference_table: :inv_srn_item, name: "fk_inv_prn_srn_item_inv_srn_item1", column: :srn_item_id },
      { table: :mst_spt_contract_annexture, reference_table: :users, name: "fk_spt_contract_documents_users12", column: :created_by },
      { table: :mst_spt_contract_annexture, reference_table: :users, name: "fk_spt_contract_documents_users22", column: :updated_by },
    ]
    .each do |f|
      add_foreign_key f[:table], f[:reference_table], name: f[:name], column: f[:column]
    end
    execute "SET FOREIGN_KEY_CHECKS = 1"

  end
end
