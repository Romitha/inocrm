class AddTablesForEstimationAndTaxes < ActiveRecord::Migration
  def change

    add_column :mst_spt_templates, :quotation_request_type, :string, default: "PRINT_SPPT_QUOTATION"
    add_column :mst_spt_templates, :quotation, :text
    add_column :mst_spt_templates, :bundle_hp_request_type, :string, default: "PRINT_SPPT_BUNDLE_HP"
    add_column :mst_spt_templates, :bundle_hp, :text
    add_column :company_config, :sup_last_quotation_no, "INT UNSIGNED NULL DEFAULT NULL"
    add_column :company_config, :sup_last_bundle_no, "INT UNSIGNED NULL DEFAULT NULL"

    create_table :spt_ticket_customer_quotation, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED NOT NULL"
      t.column :customer_quotation_no, "INT UNSIGNED NOT NULL"
      t.column :currency_id, "INT UNSIGNED DEFAULT NULL"
      t.column :payment_term_id, "INT UNSIGNED DEFAULT NULL"
      t.column :created_by, "INT UNSIGNED DEFAULT NULL"
      t.boolean :customer_contacted, null: false, default: false
      t.boolean :canceled, null: false, default: false
      t.boolean :advance_payment_requested, null: false, default: false
      t.text :note
      t.text :remark
      t.string :validity_period
      t.string :delivery_period
      t.string :warranty
      t.integer :print_count, null: false, default: 0

      t.timestamps

      t.index :created_by, name: "fk_spt_ticket_cutomer_qutation_users1_idx"
      t.index :ticket_id, name: "fk_spt_ticket_cutomer_qutation_spt_ticket1_idx"
      t.index :currency_id, name: "fk_spt_ticket_cutomer_qutation_mst_currency1_idx"
      t.index :payment_term_id, name: "fk_spt_ticket_customer_quotation_mst_spt_payment_term1_idx"
    end

    create_table :spt_ticket_customer_quotation_estimation, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :customer_quotation_id, "INT UNSIGNED NOT NULL"
      t.column :estimation_id, "INT UNSIGNED NOT NULL"
      t.index :estimation_id, name: "fk_spt_ticket_customer_qutation_estimation_spt_ticket_estim_idx"
      t.index :customer_quotation_id, name: "fk_spt_ticket_customer_quotation_estimation_spt_ticket_cuto_idx"
    end

    create_table :spt_ticket_invoice, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED NOT NULL"
      t.column :invoice_no, "INT UNSIGNED NOT NULL"
      t.column :created_by, "INT UNSIGNED NOT NULL"
      t.column :print_count, "INT UNSIGNED NOT NULL DEFAULT 0"
      t.column :payment_term_id, "INT UNSIGNED NOT NULL"
      t.column :currency_id, "INT UNSIGNED NOT NULL"
      
      t.boolean :canceled, null: false, default: false
      t.boolean :customer_sent, null: false, default: false

      t.text :note
      t.text :remark

      t.decimal :deducted_amount, scale: 2, precision: 10, null: false, default: 0

      t.timestamps

      t.index  :created_by, name: "fk_spt_ticket_cutomer_qutation_users1_idx"
      t.index  :ticket_id, name: "fk_spt_ticket_cutomer_qutation_spt_ticket1_idx"
      t.index  :currency_id, name: "fk_spt_ticket_cutomer_qutation_mst_currency1_idx"
      t.index  :payment_term_id, name: "fk_spt_ticket_invoice_mst_spt_payment_term1_idx"

    end

    create_table :spt_ticket_invoice_estimation, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :invoice_id, "INT UNSIGNED NOT NULL"
      t.column :estimation_id, "INT UNSIGNED NOT NULL"

      t.index  :invoice_id, name: "fk_spt_ticket_invoice_estimation_spt_ticket_invoice1_idx"
      t.index  :estimation_id, name: "fk_spt_ticket_invoice_estimation_spt_ticket_estimation1_idx"
      t.timestamps
    end

    create_table :spt_ticket_invoice_advance_payment, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :invoice_id, "INT UNSIGNED NOT NULL"
      t.column :payment_received_id, "INT UNSIGNED NOT NULL"

      t.index  :invoice_id, name: "fk_spt_ticket_invoice_advance_payment_spt_ticket_invoice1_idx"
      t.index  :payment_received_id, name: "fk_spt_ticket_invoice_advance_payment_spt_ticket_payment_re_idx"
      t.timestamps
    end

    create_table :spt_ticket_estimation_additional_tax, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :estimation_additional_id, "INT UNSIGNED NOT NULL"
      t.column :tax_id, "INT UNSIGNED NOT NULL"
      t.decimal :tax_rate, scale: 2, precision: 5, null: false, default: 0

      t.decimal :estimated_tax_amount, scale: 2, precision: 10, null: false, default: 0
      t.decimal :approved_tax_amount, scale: 2, precision: 10, null: false, default: 0

      t.timestamps

      t.index  :tax_id, name: "fk_spt_ticket_estimation_additional_tax_mst_tax1_idx"
      t.index  :estimation_additional_id, name: "fk_spt_ticket_estimation_additional_tax_spt_ticket_estimati_idx"

    end

    create_table :spt_ticket_estimation_part_tax, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :estimation_part_id, "INT UNSIGNED NOT NULL"
      t.column :tax_id, "INT UNSIGNED NOT NULL"

      t.decimal :estimated_tax_amount, scale: 2, precision: 10, null: false, default: 0
      t.decimal :approved_tax_amount, scale: 2, precision: 10, null: false, default: 0
      t.decimal :tax_rate, scale: 2, precision: 5, null: false

      t.timestamps

      t.index  :tax_id, name: "fk_spt_ticket_estimation_additional_tax_mst_tax1_idx"
      t.index  :estimation_part_id, name: "fk_spt_ticket_estimation_part_tax_spt_ticket_estimation_par_idx"

    end

    create_table :spt_ticket_estimation_external_tax, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :estimation_external_id, "INT UNSIGNED NOT NULL"
      t.column :tax_id, "INT UNSIGNED NOT NULL"

      t.decimal :estimated_tax_amount, scale: 2, precision: 10, null: false, default: 0
      t.decimal :approved_tax_amount, scale: 2, precision: 10, null: false, default: 0
      t.decimal :tax_rate, scale: 2, precision: 5, null: false

      t.timestamps

      t.index  :tax_id, name: "fk_spt_ticket_estimation_additional_tax_mst_tax1_idx"
      t.index  :estimation_external_id, name: "fk_spt_ticket_estimation_external_tax_spt_ticket_estimation_idx"

    end

    create_table :mst_spt_payment_term, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      t.string :description
      t.timestamps
    end

    create_table :mst_tax, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :tax
      t.text :description
      t.timestamps
    end

    create_table :mst_tax_rate, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :tax_id, "INT UNSIGNED NOT NULL"

      t.decimal :rate, scale: 2, precision: 5, null: false

      t.column :created_by, "INT UNSIGNED NOT NULL"

      t.boolean :active

      t.timestamps

      t.index  :created_by, name: "fk_mst_tax_rate_users1_idx"
      t.index  :tax_id, name: "fk_mst_tax_rate_mst_tax1_idx"

    end

    create_table :spt_ticket_spare_part_non_stock, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :spare_part_id, "INT UNSIGNED NOT NULL"
      t.column :inv_product_id, "INT UNSIGNED NOT NULL"
      t.column :approved_by, "INT UNSIGNED NULL"
      t.column :approved_inv_product_id, "INT UNSIGNED NULL"
      t.boolean :estimation_required, null: false, default: false
      t.boolean :approval_required, null: false, default: false
      t.boolean :approved, null: false, default: false
      t.datetime :approved_at

      t.index :inv_product_id, name: "fk_spt_ticket_spare_part_mst_inv_product1"
      t.index :approved_by, name: "fk_spt_ticket_spare_part_users12"
      t.index :approved_inv_product_id, name: "fk_spt_ticket_spare_part_mst_inv_product2"
      t.index :spare_part_id, name: "fk_spt_ticket_spare_part_store_spt_ticket_spare_part1_idx"
      t.timestamps

    end

    add_column :spt_ticket_estimation, :invoiced, :integer#, null: false
    add_column :spt_ticket_estimation, :quoted, :integer#, null: false

    remove_foreign_key :spt_ticket_estimation, name: "fk_spt_ticket_estimation_spt_ticket_payment_received1"
    remove_column :spt_ticket_estimation, :adv_payment_received_id

    remove_foreign_key :spt_act_print_invoice, name: "FK_spt_act_print_invoice_spt_invoice"
    add_index :spt_act_print_invoice, :invoice_id, name: "fk_spt_act_print_invoice_spt_ticket_invoice1_idx"

    remove_foreign_key :spt_ticket_payment_received, name: "fk_spt_ticket_payment_received_spt_invoice1"
    add_index :spt_ticket_payment_received, :invoice_id, name: "fk_spt_ticket_payment_received_spt_ticket_invoice1_idx"

    add_column :spt_ticket_payment_received, :customer_quotation_id, "INT UNSIGNED NULL DEFAULT NULL"
    [
      {name: "fk_spt_ticket_cutomer_qutation_users1", column: "created_by", reference_table: :users, table: :spt_ticket_customer_quotation},
      {name: "fk_spt_ticket_cutomer_qutation_spt_ticket1", column: "ticket_id", reference_table: :spt_ticket, table: :spt_ticket_customer_quotation},
      {name: "fk_spt_ticket_cutomer_qutation_mst_currency1", column: "currency_id", reference_table: :mst_currency, table: :spt_ticket_customer_quotation},
      {name: "fk_spt_ticket_customer_quotation_mst_spt_payment_term1", column: :payment_term_id, reference_table: :mst_spt_payment_term, table: :spt_ticket_customer_quotation},
      {name: "fk_spt_ticket_customer_qutation_estimation_spt_ticket_estimat1", column: :estimation_id, reference_table: :spt_ticket_estimation, table: :spt_ticket_customer_quotation_estimation },
      {name: "fk_spt_ticket_customer_quotation_estimation_spt_ticket_cutome1", column: :customer_quotation_id, reference_table: :spt_ticket_customer_quotation, table: :spt_ticket_customer_quotation_estimation },
      {name: "fk_spt_ticket_cutomer_qutation_users10", column: :created_by, reference_table: :users, table: :spt_ticket_invoice },
      {name: "fk_spt_ticket_cutomer_qutation_spt_ticket10", column: :ticket_id, reference_table: :spt_ticket, table: :spt_ticket_invoice },
      {name: "fk_spt_ticket_cutomer_qutation_mst_currency10", column: :currency_id, reference_table: :mst_currency, table: :spt_ticket_invoice },
      {name: "fk_spt_ticket_invoice_mst_spt_payment_term1", column: :payment_term_id, reference_table: :mst_spt_payment_term, table: :spt_ticket_invoice },
      {name: "fk_spt_ticket_invoice_estimation_spt_ticket_invoice1", column: :invoice_id, reference_table: :spt_ticket_invoice, table: :spt_ticket_invoice_estimation},
      {name: "fk_spt_ticket_invoice_estimation_spt_ticket_estimation1", column: :estimation_id, reference_table: :spt_ticket_estimation, table: :spt_ticket_invoice_estimation},
      {name: "fk_spt_ticket_invoice_advance_payment_spt_ticket_invoice1", column: :invoice_id, reference_table: :spt_ticket_invoice, table: :spt_ticket_invoice_advance_payment},
      {name: "fk_spt_ticket_invoice_advance_payment_spt_ticket_payment_rece1", column: :payment_received_id, reference_table: :spt_ticket_payment_received, table: :spt_ticket_invoice_advance_payment},
      {name: "fk_spt_ticket_estimation_additional_tax_mst_tax1", column: :tax_id, reference_table: :mst_tax, table: :spt_ticket_estimation_additional_tax},
      {name: "fk_spt_ticket_estimation_additional_tax_spt_ticket_estimation1", column: :estimation_additional_id, reference_table: :spt_ticket_estimation_additional, table: :spt_ticket_estimation_additional_tax, more_options: {on_delete: :restrict}},
      {name: "fk_spt_ticket_estimation_additional_tax_mst_tax10", column: :tax_id, reference_table: :mst_tax, table: :spt_ticket_estimation_part_tax},
      {name: "fk_spt_ticket_estimation_part_tax_spt_ticket_estimation_part1", column: :estimation_part_id, reference_table: :spt_ticket_estimation_part, table: :spt_ticket_estimation_part_tax, more_options: {on_delete: :restrict}},
      {name: "fk_spt_ticket_estimation_additional_tax_mst_tax100", column: :tax_id, reference_table: :mst_tax, table: :spt_ticket_estimation_external_tax},
      {name: "fk_spt_ticket_estimation_external_tax_spt_ticket_estimation_e1", column: :estimation_external_id, reference_table: :spt_ticket_estimation_external, table: :spt_ticket_estimation_external_tax, more_options: {on_delete: :restrict}},
      {name: "fk_mst_tax_rate_users1", column: :created_by, reference_table: :users, table: :mst_tax_rate},
      {name: "fk_mst_tax_rate_mst_tax1", column: :tax_id, reference_table: :mst_tax, table: :mst_tax_rate},
      {name: "fk_spt_act_print_invoice_spt_ticket_invoice1", column: :invoice_id, reference_table: :spt_ticket_invoice, table: :spt_act_print_invoice},
      {name: "fk_spt_ticket_payment_received_spt_ticket_invoice1", column: :invoice_id, reference_table: :spt_ticket_invoice, table: :spt_ticket_payment_received},
      {name: "fk_spt_ticket_payment_received_spt_ticket_cutomer_quotation1", column: :customer_quotation_id, reference_table: :spt_ticket_customer_quotation, table: :spt_ticket_payment_received},
      {name: "fk_spt_ticket_spare_part_mst_inv_product120", column: :inv_product_id, table: :spt_ticket_spare_part_non_stock, reference_table: :mst_inv_product},
      {name: "fk_spt_ticket_spare_part_users1210", column: :approved_by, table: :spt_ticket_spare_part_non_stock, reference_table: :users},
      {name: "fk_spt_ticket_spare_part_mst_inv_product210", column: :approved_inv_product_id, table: :spt_ticket_spare_part_non_stock, reference_table: :mst_inv_product},
      {name: "fk_spt_ticket_spare_part_store_spt_ticket_spare_part10", column: :spare_part_id, table: :spt_ticket_spare_part_non_stock, reference_table: :spt_ticket_spare_part},
    ]
    .each do |f|
      add_foreign_key f[:table], f[:reference_table], {name: f[:name], column: f[:column]}.merge(f[:more_options].to_h)
    end
  end
end











