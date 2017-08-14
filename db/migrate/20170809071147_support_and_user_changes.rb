class SupportAndUserChanges < ActiveRecord::Migration
  def change
    remove_foreign_key :spt_contact_report_person, name: :fk_spt_contact_report_person_oraganization_contact_person1
    remove_index :spt_contact_report_person, name: :fk_spt_contact_report_person_oraganization_contact_person1_idx
    remove_column :spt_contact_report_person, :oraganization_contact_person_id
    
    remove_foreign_key :addresses, name: :fk_oraganization_contact_addresses_mst_titles1
    remove_index :addresses, name: :fk_oraganization_contact_addresses_mst_titles1_idx
    remove_column :addresses, :contact_person_title_id

    remove_foreign_key :contact_numbers, name: :fk_contact_numbers_mst_contact_type
    remove_index :contact_numbers, name: :fk_contact_numbers_type_idx

    remove_foreign_key :contact_numbers, name: :fk_contact_numbers_mst_country
    remove_index :contact_numbers, name: :fk_contact_numbers_country_idx
    remove_column :contact_numbers, :country_id

    remove_foreign_key :contact_numbers, name: :fk_contact_numbers_mst_province
    remove_index :contact_numbers, name: :fk_contact_numbers_province_idx
    remove_column :contact_numbers, :province_id

    remove_foreign_key :contact_numbers, name: :fk_contact_numbers_mst_district
    remove_index :contact_numbers, name: :fk_contact_numbers_district_idx
    remove_column :contact_numbers, :district_id

    remove_index :spt_contract, name: :contract_no

    remove_foreign_key :spt_contract, name: :fk_spt_contract_oraganization_contact_addresses1
    remove_index :spt_contract, name: :fk_spt_contract_oraganization_contact_addresses1_idx 

    remove_foreign_key :spt_contract, name: :fk_spt_contract_oraganization_contact_addresses2
    remove_index :spt_contract, name: :fk_spt_contract_oraganization_contact_addresses2_idx
    
    remove_foreign_key :spt_contract, name: :fk_spt_contract_oraganization_contact_person1
    remove_index :spt_contract, name: :fk_spt_contract_oraganization_contact_person1_idx

    remove_foreign_key :spt_ticket_workflow_process, name: :FK__spt_ticket
    remove_index :spt_ticket_workflow_process, name: :FK__spt_ticket

    remove_column :addresses, :contact_person_name
    remove_column :addresses, :primary
    
    remove_column :contact_numbers, :category
    remove_column :contact_numbers, :primary


    add_column :spt_ticket_invoice, :updated_by, "INT UNSIGNED NULL"
    add_column :spt_ticket_invoice, :print_organization_id, "INT UNSIGNED NULL"
    add_column :spt_ticket_invoice, :print_bank_detail_id, "INT UNSIGNED NULL"
    add_column :spt_ticket_invoice, :print_currency_id, "INT UNSIGNED NULL"
    add_column :spt_ticket_invoice, :print_exchange_rate, :decimal, scale: 3, precision: 8

    add_column :spt_ticket_customer_quotation, :updated_by, "INT UNSIGNED NULL"
    add_column :spt_ticket_customer_quotation, :print_organization_id, "INT UNSIGNED NULL"
    add_column :spt_ticket_customer_quotation, :print_bank_detail_id, "INT UNSIGNED NULL"
    add_column :spt_ticket_customer_quotation, :print_currency_id, "INT UNSIGNED NULL"
    add_column :spt_ticket_customer_quotation, :print_exchange_rate, :decimal, scale: 3, precision: 8
    
    add_column :spt_contact_report_person, :organization_contact_person_id, "INT UNSIGNED NULL"
    
    add_column :addresses, :primary_address, :boolean
    
    add_column :spt_ticket_workflow_process, :engineer_id, "INT UNSIGNED NULL"
    add_column :spt_ticket_workflow_process, :estimation_id, "INT UNSIGNED NULL"
    add_column :spt_ticket_workflow_process, :spare_part_id, "INT UNSIGNED NULL"
    add_column :spt_ticket_workflow_process, :on_loan_spare_part_id, "INT UNSIGNED NULL"
    
    # add_column :spt_ticket_engineer, :task_description, :text

    add_column :mst_contact_type_validate, :pattern, :string, limit:255
    
    add_column :contact_numbers, :primary_contact, :boolean

    drop_table :oraganization_contact_person
    drop_table :oraganization_contact_addresses

    create_table :organization_bank_detail, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :organization_id, "INT UNSIGNED NOT NULL"
      t.string :description, limit:255, null: false
      t.string :bank_name, limit:255, null: false
      t.string :account_no, limit:100, null: false
      t.string :bank_address, limit:500
      t.string :swift_code, limit:100
      t.string :bank_name, limit:255
      t.column :created_by, "INT UNSIGNED NOT NULL"
      t.datetime :created_at, null: false
      t.column :updated_by, "INT UNSIGNED NOT NULL"
      t.datetime :updated_at

      t.index :created_by, name: "fk_bank_detail_users1_idx"
      t.index :updated_by, name: "fk_bank_detail_users2_idx"
      t.index :organization_id, name: "fk_bank_detail_organizations1_idx"
    end

    [
      { table: :spt_ticket_invoice, column: :updated_by, options: {name: "fk_spt_ticket_invoice_users1_idx"} },
      { table: :spt_ticket_invoice, column: :print_currency_id, options: {name: "fk_spt_ticket_invoice_mst_currency1_idx"} },
      { table: :spt_ticket_invoice, column: :print_organization_id, options: {name: "fk_spt_ticket_invoice_organizations1_idx"} },
      { table: :spt_ticket_invoice, column: :print_bank_detail_id, options: {name: "fk_spt_ticket_invoice_organization_bank_detail1_idx"} },
    
      { table: :spt_ticket_customer_quotation, column: :updated_by, options: {name: "fk_spt_ticket_customer_quotation_users1_idx"} },
      { table: :spt_ticket_customer_quotation, column: :print_currency_id, options: {name: "fk_spt_ticket_customer_quotation_mst_currency1_idx"} },
      { table: :spt_ticket_customer_quotation, column: :print_organization_id, options: {name: "fk_spt_ticket_customer_quotation_organizations1_idx"} },
      { table: :spt_ticket_customer_quotation, column: :print_bank_detail_id, options: {name: "fk_spt_ticket_customer_quotation_organization_bank_detail1_idx"} },
      
      { table: :spt_contact_report_person, column: :organization_contact_person_id, options: {name: "fk_spt_contact_report_person_organization_contact_person1_idx"} },
      
      { table: :spt_contract, column: :contact_person_id, options: {name: "contact_person_id"} },
      { table: :spt_contract, column: :bill_address_id, options: {name: "fk_addresses2"} },
      { table: :spt_contract, column: :contact_address_id, options: {name: "fk_addresses1"} },
      
      { table: :spt_ticket_workflow_process, column: :ticket_id, options: {name: "fk_spt_join_ticket_spt_ticket1"} },
      { table: :spt_ticket_workflow_process, column: :engineer_id, options: {name: "fk_spt_ticket_workflow_process_spt_ticket_engineer1_idx"} },
      { table: :spt_ticket_workflow_process, column: :estimation_id, options: {name: "fk_spt_ticket_workflow_process_spt_ticket_estimation1_idx"} },
      { table: :spt_ticket_workflow_process, column: :spare_part_id, options: {name: "fk_spt_ticket_workflow_process_spt_ticket_spare_part1_idx"} },
      { table: :spt_ticket_workflow_process, column: :on_loan_spare_part_id, options: {name: "fk_spt_ticket_workflow_process_spt_ticket_on_loan_spare_par_idx"} },
      
      { table: :contact_numbers, column: :type_id, options: {name: "fk_contact_numbers_type_idx"} },      
    ]
    .each do |f|
      add_index f[:table], f[:column], f[:options]
    end


    execute "SET FOREIGN_KEY_CHECKS = 0"
    [
      { table: :spt_ticket_invoice, reference_table: :users, name: "fk_spt_ticket_invoice_users1", column: :updated_by },
      { table: :spt_ticket_invoice, reference_table: :mst_currency, name: "fk_spt_ticket_invoice_mst_currency1", column: :print_currency_id },
      { table: :spt_ticket_invoice, reference_table: :organizations, name: "fk_spt_ticket_invoice_organizations1", column: :print_organization_id },
      { table: :spt_ticket_invoice, reference_table: :organization_bank_detail, name: "fk_spt_ticket_invoice_organization_bank_detail1", column: :print_bank_detail_id },
    
      { table: :spt_ticket_customer_quotation, reference_table: :users, name: "fk_spt_ticket_customer_quotation_users1", column: :updated_by },
      { table: :spt_ticket_customer_quotation, reference_table: :mst_currency, name: "fk_spt_ticket_customer_quotation_mst_currency1", column: :print_currency_id },
      { table: :spt_ticket_customer_quotation, reference_table: :organizations, name: "fk_spt_ticket_customer_quotation_organizations1", column: :print_organization_id },
      { table: :spt_ticket_customer_quotation, reference_table: :organization_bank_detail, name: "fk_spt_ticket_customer_quotation_organization_bank_detail1", column: :print_bank_detail_id },
      
      { table: :spt_contact_report_person, reference_table: :organization_contact_person, name: "fk_spt_contact_report_person_organization_contact_person1", column: :organization_contact_person_id },
      
      { table: :spt_contract, reference_table: :organization_contact_person, name: "spt_contract_ibfk_1", column: :contact_person_id },
      { table: :spt_contract, reference_table: :addresses, name: "fk_billing_address1", column: :bill_address_id },
      { table: :spt_contract, reference_table: :addresses, name: "spt_contract_ibfk_2", column: :contact_address_id },
      
      { table: :spt_ticket_workflow_process, reference_table: :spt_ticket, name: "fk_spt_join_ticket_spt_ticket11", column: :ticket_id },
      { table: :spt_ticket_workflow_process, reference_table: :spt_ticket_engineer, name: "fk_spt_ticket_workflow_process_spt_ticket_engineer1", column: :engineer_id },
      { table: :spt_ticket_workflow_process, reference_table: :spt_ticket_estimation, name: "fk_spt_ticket_workflow_process_spt_ticket_estimation1", column: :estimation_id },
      { table: :spt_ticket_workflow_process, reference_table: :spt_ticket_spare_part, name: "fk_spt_ticket_workflow_process_spt_ticket_spare_part1", column: :spare_part_id },
      { table: :spt_ticket_workflow_process, reference_table: :spt_ticket_on_loan_spare_part, name: "fk_spt_ticket_workflow_process_spt_ticket_on_loan_spare_part1", column: :on_loan_spare_part_id },
      
      { table: :contact_numbers, reference_table: :mst_contact_types, name: "fk_contact_numbers_mst_contact_type", column: :type_id },
      
      { table: :organization_bank_detail, reference_table: :users, name: "fk_bank_detail_users1", column: :created_by },
      { table: :organization_bank_detail, reference_table: :users, name: "fk_bank_detail_users2", column: :updated_by },
      { table: :organization_bank_detail, reference_table: :organizations, name: "fk_bank_detail_organizations1", column: :organization_id },
    ]
    .each do |f|
      add_foreign_key f[:table], f[:reference_table], name: f[:name], column: f[:column]
    end
    execute "SET FOREIGN_KEY_CHECKS = 1"

    
  end
end
