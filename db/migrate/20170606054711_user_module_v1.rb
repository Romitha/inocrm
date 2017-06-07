class UserModuleV1 < ActiveRecord::Migration
  def change
    add_column :organizations, :contact_person1_id, "INT UNSIGNED NULL"
    add_column :organizations, :contact_person2_id, "INT UNSIGNED NULL"
    add_column :organizations, :contract_no_value, :string, limit:50, null:true
    
    add_column :company_config, :sup_last_contract_serial_no, :integer, null:false, default:0
    add_column :company_config, :sup_contract_no_auto, :boolean, default: false, null: false

    add_column :mst_spt_product_brand, :contract_no_value, :string, limit:50, null:true
    
    add_column :mst_spt_product_category, :contract_no_value, :string, limit:50, null:true

    add_column :spt_product_serial, :name, :string, limit:200, null:true
    add_column :spt_product_serial, :description, :string, limit:200, null:true

    add_column :spt_contact_report_person, :oraganization_contact_person_id, "INT UNSIGNED NULL"

    add_column :mst_spt_contract_type, :chargeable, :integer, null:false, default:0
    add_column :mst_spt_contract_type, :contract_no_value, :string, limit:50, null:true

    add_column :spt_contract, :organization_contact_id,"INT UNSIGNED NOT NULL"
    add_column :spt_contract, :contact_address_id,"INT UNSIGNED NOT NULL"
    add_column :spt_contract, :organization_bill_id,"INT UNSIGNED NOT NULL"
    add_column :spt_contract, :bill_address_id,"INT UNSIGNED NOT NULL"
    add_column :spt_contract, :product_brand_id,"INT UNSIGNED NOT NULL"
    add_column :spt_contract, :product_category_id,"INT UNSIGNED NOT NULL"
    add_column :spt_contract, :contact_person_id,"INT UNSIGNED NOT NULL"
    add_column :spt_contract, :process_at, :datetime, null:false
    add_column :spt_contract, :legacy_contract_no, :string, limit:50, null:true
    add_column :spt_contract, :additional_charges, :integer, null:true
    add_column :spt_contract, :season, :integer, null:true
    add_column :spt_contract, :accepted_at, :datetime, null:true
    add_column :spt_contract, :documnet_received, :boolean, null:true
    add_column :spt_contract, :payment_type_id, "INT UNSIGNED NOT NULL"
    add_column :spt_contract, :payment_completed,:boolean, null:false, default:false
    add_column :spt_contract, :document_generated_count, :integer, null:false, default:false
    add_column :spt_contract, :last_doc_generated_at, :datetime, null:true
    add_column :spt_contract, :last_doc_generated_by, "INT UNSIGNED NULL"
    
    add_column :spt_contract_product, :amount, :decimal, precision: 10, scale: 2, null:true
    add_column :spt_contract_product, :discount_amount, :decimal, precision: 10, scale: 2, null:true

    add_column :spt_ticket_engineer_support, :job_actual_time_spent, :integer, null:false, default:0




    create_table :organization_treepath, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ancestor_id, "INT UNSIGNED NOT NULL"
      t.column :descendant_id, "INT UNSIGNED NOT NULL"

      t.index :ancestor_id, name: "fk_organization_treepath_organizations1_idx"
      t.index :descendant_id, name: "fk_organization_treepath_organizations2_idx"
    end

    create_table :oraganization_contact_person, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
    end

    create_table :oraganization_contact_addresses, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"  
    end

    create_table :mst_spt_contract_payment_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name, limit: 200, null:false
      t.boolean :active, null:false, default:true
      t.column :max_payment_installment, "INT NOT NULL DEFAULT 0"
    end

    create_table :mst_spt_product_brand_cost, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :product_brand_id, "INT UNSIGNED NOT NULL"
      t.decimal :engineer_cost, precision: 8, scale: 2, null:false, default:0
      t.decimal :support_engineer_cost, precision: 8, scale: 2, null:false, default:0
      t.column :currency_id, "INT UNSIGNED NOT NULL"
      t.datetime :updated_at, null:false
      t.column :updated_by, "INT UNSIGNED NOT NULL"
    end
    
    create_table :spt_ticket_total_cost, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED NOT NULL"
      t.decimal :engineer_cost, precision: 10, scale: 2, null:false, default:0
      t.decimal :support_engineer_cost, precision: 10, scale: 2, null:false, default:0
      t.decimal :part_cost, precision: 10, scale: 2, null:false, default:0
      t.decimal :additional_cost, precision: 10, scale: 2, null:false, default:0
      t.decimal :external_cost, precision: 10, scale: 2, null:false, default:0
      t.column :engineer_time_spent, :integer, null:false, default:0
      t.column :support_engineer_time_spent, :integer, null:false, default:0
      t.datetime :updated_at, null:false
    end

    create_table :spt_ticket_fsr_support_eng, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :fsr_id, "INT UNSIGNED NOT NULL"
      t.column :engineer_support_id, "INT UNSIGNED NOT NULL"
      t.float :hours_worked
    end

    create_table :spt_contract_document, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :contract_id, "INT UNSIGNED NOT NULL"
      t.text :document_url
      t.datetime :created_at, null:false
      t.column :created_by, "INT UNSIGNED NULL"
      t.datetime :updated_at
      t.column :updated_by, "INT UNSIGNED NULL"
    end

    create_table :mst_spt_contract_brand_document, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :product_brand_id, "INT UNSIGNED NOT NULL"
      t.string :code, limit: 10, null:false
      t.string :name, limit: 100, null:false
      t.string :description, limit: 225
      t.text :document
      t.datetime :created_at, null:false
      t.column :created_by, "INT UNSIGNED NULL"
      t.datetime :updated_at
      t.column :updated_by, "INT UNSIGNED NULL"
      t.string :document_file_name, limit: 225, null:false
    end
    
    create_table :spt_contract_attachment, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :contract_id, "INT UNSIGNED NOT NULL"
      t.text :attachment_url
      t.datetime :created_at, null:false
      t.column :created_by, "INT UNSIGNED NULL"
      t.datetime :updated_at
      t.column :updated_by, "INT UNSIGNED NULL"
    end

    create_table :spt_contract_payment_received, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :contract_id, "INT UNSIGNED NOT NULL"
      t.column :payment_installment, :integer
      t.datetime :payment_received_at, null:false
      t.decimal :amount, precision: 10, scale: 2, null:false, default:0
      t.datetime :created_at, null:false
      t.column :created_by, "INT UNSIGNED NOT NULL"
      t.string :invoice_no, limit: 50
      t.text :remarks
    end


    
    [
      { table: :organizations, column: :contact_person1_id, options: {name: "fk_organizations_oraganization_contact_person1_idx"} },
      { table: :organizations, column: :contact_person2_id, options: {name: "fk_organizations_oraganization_contact_person2_idx"} },
      { table: :spt_contact_report_person, column: :oraganization_contact_person_id, options: {name: "fk_spt_contact_report_person_oraganization_contact_person1_idx"} },
      { table: :spt_contract, column: :contact_address_id, options: {name: "fk_spt_contract_oraganization_contact_addresses1_idx"} },
      { table: :spt_contract, column: :bill_address_id, options: {name: "fk_spt_contract_oraganization_contact_addresses2_idx"} },
      { table: :spt_contract, column: :product_category_id, options: {name: "fk_spt_contract_mst_spt_product_category1_idx"} },
      { table: :spt_contract, column: :organization_contact_id, options: {name: "fk_spt_contract_organizations2_idx"} },
      { table: :spt_contract, column: :organization_bill_id, options: {name: "fk_spt_contract_organizations3_idx"} },
      { table: :spt_contract, column: :product_brand_id, options: {name: "fk_spt_contract_mst_spt_product_brand1_idx"} },
      { table: :spt_contract, column: :contact_person_id, options: {name: "fk_spt_contract_oraganization_contact_person1_idx"} },
      { table: :spt_contract, column: :payment_type_id, options: {name: "fk_spt_contract_mst_spt_contract_payment_type1_idx"} },
      { table: :spt_contract, column: :last_doc_generated_by, options: {name: "fk_spt_contract_users2_idx"} },
      { table: :mst_spt_product_brand_cost, column: :updated_by, options: {name: "fk_mst_spt_sla_users1_idx"} },
      { table: :mst_spt_product_brand_cost, column: :product_brand_id, options: {name: "fk_mst_spt_product_brand_cost_rate_mst_spt_product_brand1_idx"} },
      { table: :mst_spt_product_brand_cost, column: :currency_id, options: {name: "fk_mst_spt_product_brand_cost_rate_mst_currency1_idx"} },
      { table: :spt_ticket_total_cost, column: :ticket_id, options: {name: "fk_spt_ticket_cost_spt_ticket1_idx"} },
      { table: :spt_ticket_fsr_support_eng, column: :fsr_id, options: {name: "fk_spt_ticket_fsr_support_eng_spt_ticket_fsr1_idx"} },
      { table: :spt_ticket_fsr_support_eng, column: :engineer_support_id, options: {name: "fk_spt_ticket_fsr_support_eng_spt_ticket_engineer_support1_idx"} },
      { table: :spt_contract_document, column: :created_by, options: {name: "fk_spt_contract_documents_users1_idx"} },
      { table: :spt_contract_document, column: :updated_by, options: {name: "fk_spt_contract_documents_users2_idx"} },
      { table: :spt_contract_document, column: :contract_id, options: {name: "fk_spt_contract_document_spt_contract1_idx"} },
      { table: :mst_spt_contract_brand_document, column: :created_by, options: {name: "fk_spt_contract_documents_users1_idx"} },
      { table: :mst_spt_contract_brand_document, column: :updated_by, options: {name: "fk_spt_contract_documents_users2_idx"} },
      { table: :mst_spt_contract_brand_document, column: :product_brand_id, options: {name: "fk_mst_spt_contract_brand_document_mst_spt_product_brand1_idx"} },
      { table: :spt_contract_attachment, column: :created_by, options: {name: "fk_spt_contract_documents_users1_idx"} },
      { table: :spt_contract_attachment, column: :updated_by, options: {name: "fk_spt_contract_documents_users2_idx"} },
      { table: :spt_contract_attachment, column: :contract_id, options: {name: "fk_spt_contract_document_spt_contract1_idx"} },
      { table: :spt_contract_payment_received, column: :contract_id, options: {name: "fk_mst_spt_contract_payment_type_copy1_spt_contract1_idx"} },
      { table: :spt_contract_payment_received, column: :created_by, options: {name: "fk_spt_contract_payment_receive_users1_idx"} },
    ]
    .each do |f|
      add_index f[:table], f[:column], f[:options]
    end
    execute "SET FOREIGN_KEY_CHECKS = 0"

    [
      { table: :organizations, reference_table: :oraganization_contact_person, name: "fk_organizations_oraganization_contact_person1", column: :contact_person1_id },
      { table: :organizations, reference_table: :oraganization_contact_person, name: "fk_organizations_oraganization_contact_person2", column: :contact_person2_id },
      { table: :organization_treepath, reference_table: :organizations, name: "fk_organization_treepath_organizations1", column: :ancestor_id },
      { table: :organization_treepath, reference_table: :organizations, name: "fk_organization_treepath_organizations2", column: :descendant_id },
      { table: :spt_contact_report_person, reference_table: :oraganization_contact_person, name: "fk_spt_contact_report_person_oraganization_contact_person1", column: :oraganization_contact_person_id },
      { table: :spt_contract, reference_table: :oraganization_contact_addresses, name: "fk_spt_contract_oraganization_contact_addresses1", column: :contact_address_id },
      { table: :spt_contract, reference_table: :oraganization_contact_addresses, name: "fk_spt_contract_oraganization_contact_addresses2", column: :bill_address_id },
      { table: :spt_contract, reference_table: :mst_spt_product_category, name: "fk_spt_contract_mst_spt_product_category1", column: :product_category_id },
      { table: :spt_contract, reference_table: :organizations, name: "fk_spt_contract_organizations2", column: :organization_contact_id },
      { table: :spt_contract, reference_table: :organizations, name: "fk_spt_contract_organizations3", column: :organization_bill_id },
      { table: :spt_contract, reference_table: :mst_spt_product_brand, name: "fk_spt_contract_mst_spt_product_brand1", column: :product_brand_id },
      { table: :spt_contract, reference_table: :oraganization_contact_person, name: "fk_spt_contract_oraganization_contact_person1", column: :contact_person_id },
      { table: :spt_contract, reference_table: :mst_spt_contract_payment_type, name: "fk_spt_contract_mst_spt_contract_payment_type1", column: :payment_type_id },
      { table: :spt_contract, reference_table: :users, name: "fk_spt_contract_users2", column: :last_doc_generated_by },
      { table: :mst_spt_product_brand_cost, reference_table: :users, name: "fk_mst_spt_sla_users10", column: :updated_by },
      { table: :mst_spt_product_brand_cost, reference_table: :mst_spt_product_brand, name: "fk_mst_spt_product_brand_cost_rate_mst_spt_product_brand1", column: :currency_id },
      { table: :spt_ticket_total_cost, reference_table: :spt_ticket, name: "fk_spt_ticket_cost_spt_ticket1", column: :ticket_id },
      { table: :spt_ticket_fsr_support_eng, reference_table: :spt_ticket_fsr, name: "fk_spt_ticket_fsr_support_eng_spt_ticket_fsr1", column: :fsr_id },
      { table: :spt_ticket_fsr_support_eng, reference_table: :spt_ticket_engineer_support, name: "fk_spt_ticket_fsr_support_eng_spt_ticket_engineer_support1", column: :engineer_support_id },
      { table: :spt_contract_document, reference_table: :users, name: "fk_spt_contract_documents_users1", column: :created_by },
      { table: :spt_contract_document, reference_table: :users, name: "fk_spt_contract_documents_users2", column: :updated_by },
      { table: :spt_contract_document, reference_table: :spt_contract, name: "fk_spt_contract_document_spt_contract1", column: :contract_id },
      { table: :mst_spt_contract_brand_document, reference_table: :users, name: "fk_spt_contract_documents_users10", column: :created_by },
      { table: :mst_spt_contract_brand_document, reference_table: :users, name: "fk_spt_contract_documents_users20", column: :updated_by },
      { table: :mst_spt_contract_brand_document, reference_table: :mst_spt_product_brand, name: "fk_mst_spt_contract_brand_document_mst_spt_product_brand1", column: :product_brand_id },
      { table: :spt_contract_attachment, reference_table: :users, name: "fk_spt_contract_documents_users11", column: :created_by },
      { table: :spt_contract_attachment, reference_table: :users, name: "fk_spt_contract_documents_users21", column: :updated_by },
      { table: :spt_contract_attachment, reference_table: :spt_contract, name: "fk_spt_contract_document_spt_contract10", column: :contract_id },
      { table: :spt_contract_payment_received, reference_table: :spt_contract, name: "fk_mst_spt_contract_payment_type_copy1_spt_contract1", column: :contract_id },
      { table: :spt_contract_payment_received, reference_table: :users, name: "fk_spt_contract_payment_receive_users1", column: :created_by },
    ]
    .each do |f|
      add_foreign_key f[:table], f[:reference_table], name: f[:name], column: f[:column]
    end
    execute "SET FOREIGN_KEY_CHECKS = 1"

  end
end
