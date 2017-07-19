class SupportDbUpdate < ActiveRecord::Migration
  def change
    remove_column :company_config, :sup_estimation_need_approval
    add_column :company_config, :sup_ch_estimation_need_approval, :boolean, null:false, default:0
    add_column :company_config, :sup_nc_estimation_need_approval, :boolean, null:false, default:0
    add_column :company_config, :owner_customer_id, "INT UNSIGNED NULL"
    add_column :spt_contract, :office_out_at, :datetime
    add_column :spt_contract, :office_in_at, :datetime

    create_table :mst_spt_template_email, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit:100, null:false
      t.text :subject, null:false
      t.text :body, null:false
      t.boolean :active, null:false, default:1
      t.boolean :default_enable, null:false, default:1
      t.datetime :created_at
      t.datetime :updated_at
    end
    create_table :spt_customer_product_history, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :product_serial_id, "INT UNSIGNED NOT NULL"
      t.column :owner_customer_id, "INT UNSIGNED NOT NULL"
      t.column :created_by, "INT UNSIGNED NOT NULL"
      t.datetime :created_at, null:false
      t.text :note

      t.index :product_serial_id, name: "fk_spt_customer_prodcut_history_spt_product_serial1_idx"
      t.index :owner_customer_id, name: "fk_spt_customer_prodcut_history_organizations1_idx"
      t.index :created_by, name: "fk_spt_customer_prodcut_history_users1_idx"

    end

    [
      { table: :company_config, column: :owner_customer_id, options: {name: "fk_spt_product_serial_organizations1_idx"} },
    ]
    .each do |f|
      add_index f[:table], f[:column], f[:options]
    end

    execute "SET FOREIGN_KEY_CHECKS = 0"
    [
      { table: :company_config, reference_table: :organizations, name: "fk_spt_product_serial_organizations1", column: :owner_customer_id },
      { table: :spt_customer_product_history, reference_table: :spt_product_serial, name: "fk_spt_customer_prodcut_history_spt_product_serial1", column: :product_serial_id },
      { table: :spt_customer_product_history, reference_table: :organizations, name: "fk_spt_customer_prodcut_history_organizations1", column: :owner_customer_id },
      { table: :spt_customer_product_history, reference_table: :users, name: "fk_spt_customer_prodcut_history_users1", column: :created_by },
    ]
    .each do |f|
      add_foreign_key f[:table], f[:reference_table], name: f[:name], column: f[:column]
    end
    execute "SET FOREIGN_KEY_CHECKS = 1"

  end
end
