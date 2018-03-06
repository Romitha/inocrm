class ContractDatabaseUpdate < ActiveRecord::Migration
  def change
    remove_foreign_key :mst_spt_product_category, name: :fk_mst_spt_product_category_mst_spt_prodcut_brand1
    remove_index :mst_spt_product_category, name: :fk_mst_spt_product_category_mst_spt_prodcut_brand1
    remove_column :mst_spt_product_category, :product_brand_id

    add_column :mst_spt_product_category, :product_category2_id, "INT UNSIGNED NOT NULL"

    add_column :company_config, :sup_product_category1_label, :string, limit:100, null: false, default: "Product Category 1"
    add_column :company_config, :sup_product_category2_label, :string, limit:100, null: false, default: "Product Category 2"
    add_column :company_config, :sup_product_category_label, :string, limit:100, null: false, default: "Product Category 3"

    add_column :mst_inv_category3, :spt_product_brand_id, "INT UNSIGNED NOT NULL"
    add_column :mst_inv_category3, :spt_product_category1_id, "INT UNSIGNED NOT NULL"
    add_column :mst_inv_category3, :spt_product_category2_id, "INT UNSIGNED NOT NULL"
    add_column :mst_inv_category3, :spt_product_category3_id, "INT UNSIGNED NOT NULL"

    add_column :spt_contract, :status_id, "INT UNSIGNED NOT NULL"

    add_column :spt_product_serial, :location_address_id, "INT UNSIGNED NULL"

    add_column :spt_contract_product, :location_address_id, "INT UNSIGNED NULL"

    add_column :spt_product_serial, :dn_number, :string, limit:100, null: true
    add_column :spt_product_serial, :invoice_number, :string, limit:100, null: true
    add_column :spt_product_serial, :invoice_date, :datetime, null: true

    add_column :spt_contract_product, :contract_start_at, :datetime, null: true
    add_column :spt_contract_product, :contract_end_at, :datetime, null: true
    add_column :spt_contract_product, :contract_b2b, :boolean

    add_column :spt_ticket_total_cost, :admin_cost, :decimal, precision: 10, scale: 2, null: false, default: 0

    add_column :mst_currency, :sup_admin_cost, :decimal, precision: 10, scale: 2, null: false, default: 0


    create_table :mst_spt_product_category1, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :product_brand_id, "INT UNSIGNED NULL"
      t.string :name, limit:100, null: false
      t.string :contract_no_value, limit:50, null: true

      t.index :product_brand_id, name: "fk_mst_spt_product_category_mst_spt_prodcut_brand1"
    end
    create_table :mst_spt_product_category2, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :product_category1_id, "INT UNSIGNED NOT NULL"
      t.string :name, limit:100, null: false
      t.string :contract_no_value, limit:50, null: true

      t.index :product_category1_id, name: "fk_mst_spt_product_category2_mst_spt_product_category11_idx"
    end
    create_table :mst_spt_contract_status, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name, limit:200, null: false
      t.string :colour_code, limit:200, null: false
    end
    create_table :spt_contract_payment_installment, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :contract_id, "INT UNSIGNED NOT NULL"
      t.column :payment_installment, "INT NOT NULL"
      t.decimal :installment_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :total_amount, precision: 10, scale: 2, null: false, default: 0
      
      t.index :contract_id, name: "fk_spt_contract_payment_installment_spt_contract1_idx"

    end
    [
      { table: :mst_spt_product_category, column: :product_category2_id, options: {name: "fk_mst_spt_product_category_mst_spt_product_category21_idx"} },
      { table: :mst_inv_category3, column: :spt_product_brand_id, options: {name: "fk_mst_inv_category3_mst_spt_product_brand1_idx"} },
      { table: :mst_inv_category3, column: :spt_product_category1_id, options: {name: "fk_mst_inv_category3_mst_spt_product_category11_idx"} },
      { table: :mst_inv_category3, column: :spt_product_category2_id, options: {name: "fk_mst_inv_category3_mst_spt_product_category21_idx"} },
      { table: :mst_inv_category3, column: :spt_product_category3_id, options: {name: "fk_mst_inv_category3_mst_spt_product_category31_idx"} },
      { table: :spt_contract, column: :status_id, options: {name: "fk_spt_contract_mst_spt_contract_status1_idx"} },
      { table: :spt_product_serial, column: :location_address_id, options: {name: "fk_spt_product_serial_addresses1_idx"} },
      { table: :spt_contract_product, column: :location_address_id, options: {name: "fk_spt_contract_product_addresses1_idx"} },
    ]
    .each do |f|
      add_index f[:table], f[:column], f[:options]
    end

    execute "SET FOREIGN_KEY_CHECKS = 0"
    [
      { table: :mst_spt_product_category1, reference_table: :mst_spt_product_brand, name: "fk_mst_spt_product_category_mst_spt_prodcut_brand10", column: :product_brand_id },
      { table: :mst_spt_product_category2, reference_table: :mst_spt_product_category1, name: "fk_mst_spt_product_category2_mst_spt_product_category11", column: :product_category1_id },
      { table: :mst_spt_product_category, reference_table: :mst_spt_product_category2, name: "fk_mst_spt_product_category_mst_spt_product_category21", column: :product_category2_id },

      { table: :mst_inv_category3, reference_table: :mst_spt_product_brand, name: "fk_mst_inv_category3_mst_spt_product_brand1", column: :spt_product_brand_id },
      { table: :mst_inv_category3, reference_table: :mst_spt_product_category1, name: "fk_mst_inv_category3_mst_spt_product_category11", column: :spt_product_category1_id },
      { table: :mst_inv_category3, reference_table: :mst_spt_product_category2, name: "fk_mst_inv_category3_mst_spt_product_category21", column: :spt_product_category2_id },
      { table: :mst_inv_category3, reference_table: :mst_spt_product_category3, name: "fk_mst_inv_category3_mst_spt_product_category31", column: :spt_product_category3_id },

      { table: :spt_contract, reference_table: :mst_spt_contract_status, name: "fk_spt_contract_mst_spt_contract_status1", column: :status_id },

      { table: :spt_product_serial, reference_table: :addresses, name: "fk_spt_product_serial_addresses1", column: :location_address_id },

      { table: :spt_contract_product, reference_table: :addresses, name: "fk_spt_contract_product_addresses1", column: :location_address_id },
      { table: :spt_contract_payment_installment, reference_table: :spt_contract, name: "fk_spt_contract_payment_installment_spt_contract1", column: :contract_id },
    ]
    .each do |f|
      add_foreign_key f[:table], f[:reference_table], name: f[:name], column: f[:column]
    end
    execute "SET FOREIGN_KEY_CHECKS = 1"
  end
end
