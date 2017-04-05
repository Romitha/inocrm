class AddNewColumnsForTable < ActiveRecord::Migration
  def change
  	add_column :company_config, :sup_st_parts_nc_need_approval, :boolean, null: false, default: true
  	add_column :company_config, :sup_st_parts_ch_need_approval, :boolean, null: false, default: true
  	add_column :company_config, :sup_mf_parts_nc_need_approval, :boolean, null: false, default: false
  	add_column :company_config, :sup_mf_parts_ch_need_approval, :boolean, null: false, default: false
   	add_column :company_config, :sup_estimation_need_approval, :boolean, null: false, default: false
  	add_column :company_config, :sup_mf_parts_collect_required, :boolean, null: false, default: true
  	add_column :company_config, :sup_mf_parts_return_required, :boolean, null: false, default: true
  	add_column :company_config, :sup_qc_required, :boolean, null: false, default: true
   	add_column :company_config, :sup_mf_parts_po_required, :boolean, null: false, default: true
  	add_column :company_config, :sup_contract_reminder_email, :string, limit: 200, null: true
  	add_column :company_config, :sup_contract_remind_bf_period, :integer, null: false, default: 90
   	add_column :company_config, :sup_contract_remind_af_period, :integer, null: false, default: 30
  	add_column :company_config, :sup_contract_remind_gap, :integer, null: false, default: 14
  	add_column :company_config, :sup_nc_estimation_required, :boolean, null: false, default: false
  	add_column :company_config, :last_account_code, :integer, null: false, default: 0
  
  	add_column :spt_product_serial, :note, "TEXT NULL"
  	add_column :spt_product_serial, :date_installation, :datetime, null: true


  	create_table :mst_spt_contract_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name, null: false, limit:200
      t.boolean :active, null:false, default: 1 
    end


    remove_column :spt_contract, :contract_start_at
    remove_column :spt_contract, :contract_end_at
		remove_column :spt_contract, :active

    add_column :spt_contract, :contract_start_at, :datetime, null:false
  	add_column :spt_contract, :contract_end_at, :datetime, null:false
  	add_column :spt_contract, :hold, :boolean, null:false, default:false
  	add_column :spt_contract, :owner_organization_id, "INT UNSIGNED NULL"
  	add_column :spt_contract, :amount, :decimal, precision: 10, scale: 2, null:true
  	add_column :spt_contract, :currency_id, "INT UNSIGNED NULL"
    add_column :spt_contract, :contract_type_id, "INT UNSIGNED NOT NULL"
   	add_column :spt_contract, :attachment_url, :string, limit:200, null:true
  	add_column :spt_contract, :last_remind_at, :datetime, null:true
  	add_column :spt_contract, :remind_required, :boolean, null:false, default: 1
  	
  	add_index :spt_contract, :owner_organization_id, name: "fk_spt_contract_organizations1_idx"
  	add_index :spt_contract, :currency_id, name: "fk_spt_contract_mst_currency1_idx"
  	add_index :spt_contract, :contract_type_id, name: "fk_spt_contract_mst_spt_contract_type1_idx"
  	
  	add_foreign_key(:spt_contract, :organizations, name: "fk_spt_contract_organizations1", column: :owner_organization_id)
 		add_foreign_key(:spt_contract, :mst_currency, name: "fk_spt_contract_mst_currency1", column: :currency_id)
 		execute "SET FOREIGN_KEY_CHECKS = 0"
 		add_foreign_key(:spt_contract, :mst_spt_contract_type, name: "fk_spt_contract_mst_spt_contract_type1", column: :contract_type_id)
 		execute "SET FOREIGN_KEY_CHECKS = 1"

 		add_column :spt_ticket_workflow_process, :re_open_index, :integer, null:false, default:1
  	

  	add_column :spt_ticket_engineer, :parent_engineer_id, "INT UNSIGNED NULL"
  	add_column :spt_ticket_engineer, :re_open_index, :integer, null:false, default:0
  	add_column :spt_ticket_engineer, :re_assignment_requested, :boolean, null:false, default:0
  	add_column :spt_ticket_engineer, :re_assignment, :boolean, null:false, default:0
  	add_column :spt_ticket_engineer, :job_terminated, :boolean, null:false, default:0
  	add_column :spt_ticket_engineer, :status, :integer, null:false, default:0
  	add_column :spt_ticket_engineer, :job_assigned_at, :datetime, null:true
  	add_column :spt_ticket_engineer, :job_started_at, :datetime, null:true
  	add_column :spt_ticket_engineer, :job_completed_at, :datetime, null:true
  	add_column :spt_ticket_engineer, :job_closed_at, :datetime, null:true
  	add_column :spt_ticket_engineer, :workflow_process_id, "INT UNSIGNED NULL"
  	add_column :spt_ticket_engineer, :job_close_approval_required, :boolean, null:false, default:1
  	add_column :spt_ticket_engineer, :job_close_approval_requested, :boolean, null:false, default:0
  	add_column :spt_ticket_engineer, :job_close_approved, :boolean, null:false, default:0
  	add_column :spt_ticket_engineer, :job_actual_time_spent, :integer, null:false, default:0
  	
  	add_index :spt_ticket_engineer, :parent_engineer_id, name: "fk_spt_ticket_engineer_spt_ticket_engineer1_idx"
  	add_index :spt_ticket_engineer, :workflow_process_id, name: "fk_spt_ticket_engineer_spt_ticket_workflow_process1_idx"
  	
  	add_foreign_key(:spt_ticket_engineer, :spt_ticket_engineer, name: "fk_spt_ticket_engineer_spt_ticket_engineer1", column: :parent_engineer_id)
 		add_foreign_key(:spt_ticket_engineer, :spt_ticket_workflow_process, name: "fk_spt_ticket_engineer_spt_ticket_workflow_process1", column: :workflow_process_id)
 		
 		add_column :spt_ticket, :owner_organization_id, "INT UNSIGNED NULL"
		add_index :spt_ticket, :owner_organization_id, name: "fk_spt_ticket_organizations1_idx"
  	add_foreign_key(:spt_ticket, :organizations, name: "fk_spt_ticket_organizations1", column: :owner_organization_id)
 		
 		add_column :spt_ticket_fsr, :customer_approved, :boolean, null:true
  	add_column :spt_ticket_fsr, :customer_approval_url, :string, limit:200, null:true
  	add_column :spt_ticket_fsr, :form_no, :string, limit:50, null:true
  	
  	add_column :spt_ticket_spare_part, :request_approval_required, :boolean, null:false, default:false
  	add_column :spt_ticket_spare_part, :request_approved, :boolean, null:false, default:false
  	add_column :spt_ticket_spare_part, :request_approved_at, :datetime, null:true
  	add_column :spt_ticket_spare_part, :request_approved_by, "INT UNSIGNED NULL"
  	
  	add_index :spt_ticket_spare_part, :request_approved_by, name: "fk_spt_ticket_spare_part_users2_idx"
  	add_foreign_key(:spt_ticket_spare_part, :users, name: "fk_spt_ticket_spare_part_users2", column: :request_approved_by)
 		
 		remove_column :spt_ticket_spare_part_store, :store_request_approved

 		remove_column :spt_ticket_spare_part_store, :store_request_approved_at
 		
 		remove_foreign_key :spt_ticket_spare_part_store, name: :fk_spt_ticket_spare_part_users121
 		remove_index :spt_ticket_spare_part_store, name: :fk_spt_ticket_spare_part_users121
    remove_column :spt_ticket_spare_part_store, :store_request_approved_by
    
    create_table :spt_contract_reminder, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :spt_contract_id,"INT UNSIGNED NOT NULL"
      t.datetime :created_at, null:false 
      t.string :type_value, null:false, limit:200
      t.column :type, "INT NOT NULL DEFAULT 1"
      t.index :spt_contract_id, name: "fk_spt_contract_reminder_spt_contract1_idx"
    end

    add_foreign_key :spt_contract_reminder, :spt_contract, name: "fk_spt_contract_reminder_spt_contract1", column: :spt_contract_id

    create_table :mst_spt_contract_template, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :body, null:true
      t.text :subject, null:true
      t.column :type, "INT NOT NULL DEFAULT 1"
    end

    create_table :spt_ticket_engineer_support, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :engineer_id, "INT UNSIGNED NOT NULL"
      t.column :user_id, "INT UNSIGNED NOT NULL"
     	t.index :engineer_id, name: "fk_spt_ticket_engineer_support_spt_ticket_engineer1_idx"
   		t.index :user_id, name: "fk_spt_ticket_engineer_support_users1_idx"
    end

    add_foreign_key :spt_ticket_engineer_support, :spt_ticket_engineer, name: "fk_spt_ticket_engineer_support_spt_ticket_engineer1", column: :engineer_id
    add_foreign_key :spt_ticket_engineer_support, :users, name: "fk_spt_ticket_engineer_support_users1", column: :user_id
  end
end