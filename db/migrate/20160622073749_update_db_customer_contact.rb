class UpdateDbCustomerContact < ActiveRecord::Migration
  def change
    create_table :mst_spt_contact_type_validate, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
    end

    add_column :mst_spt_customer_contact_type, :validate_id, "INT UNSIGNED NOT NULL"
    add_index :mst_spt_customer_contact_type, :validate_id

    execute "SET FOREIGN_KEY_CHECKS = 0"

    add_foreign_key :mst_spt_customer_contact_type, :mst_spt_contact_type_validate, name: "fk_mst_spt_customer_contact_type_mst_spt_contact_type_validate1", column: :validate_id

    add_column :mst_spt_templates, :ticket_sticker_request_type, :string, default: "PRINT_SPPT_TICKET_STICKER"
    add_column :mst_spt_templates, :ticket_sticker, :text

    execute "SET FOREIGN_KEY_CHECKS = 1"
  end
end
