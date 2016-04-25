class AddSptNewTablesFromDevage < ActiveRecord::Migration
  def change
    create_table :spt_act_action_taken, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"
      t.text :action, null: false
      t.timestamps
    end

    create_table :spt_act_assign_regional_support_center, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)" 
      t.column :regional_support_center_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :spt_act_assign_ticket, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"  
      t.column :sbu_id, "int(10) UNSIGNED"
      t.column :assign_to, "int(10) UNSIGNED"
      t.boolean :recorrection, null: false, default: false
      t.boolean :regional_support_center_job, null: false, default: false
      t.timestamps
    end

    create_table :spt_act_customer_feedback, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"
      t.boolean :re_opened, null: false, default: false
      t.boolean :unit_return_customer, null: false, default: false
      t.column :payment_received_id, "int(10) UNSIGNED"
      t.boolean :payment_completed, null: false, default: false
      t.boolean :ticket_terminated, null: false, default: false
      t.column :feedback_id, "int(10) UNSIGNED"
      t.text :feedback_description
      t.timestamps
    end

    create_table :spt_act_deliver_unit, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)" 
      t.column :ticket_deliver_unit_id, "int(10) UNSIGNED NOT NULL"
      t.column :deliver_to_id, "int(10) UNSIGNED"
      t.text :deliver_note
      t.text :receive_note
      t.timestamps
    end

    create_table :spt_act_edit_serial_request, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"  
      t.text :reason, null: false
      t.timestamps
    end

    create_table :spt_act_finish_job, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"  
      t.text :resolution, null: false
      t.timestamps
    end

    create_table :spt_act_fsr, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"  
      t.boolean :print_fsr, null: false, default: false
      t.column :fsr_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :spt_act_hold, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"  
      t.column :reason_id, "int(10) UNSIGNED NOT NULL"
      t.boolean :sla_pause, null: false, default: false
      t.column :un_hold_action_id, "int(10) UNSIGNED DEFAULT 0"
      t.timestamps
    end

    create_table :spt_act_hp_case_action, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"  
      t.string :case_id, null: false
      t.text :case_note
      t.timestamps
    end

    create_table :spt_act_inform_customer, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"
      t.column :contact_type_id, "int(10) UNSIGNED NOT NULL"
      t.text :note
      t.timestamps
    end

    create_table :spt_act_job_estimate, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)" 
      t.column :supplier_id, "int(10) UNSIGNED"
      t.text :note
      t.column :ticket_estimation_id, "int(10) UNSIGNED"
      t.timestamps
    end

    create_table :spt_act_payment_received, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)" 
      t.column :ticket_payment_received_id, "int(10) UNSIGNED NOT NULL"
      t.boolean :invoice_completed, null: false, default: false
      t.timestamps
    end

    create_table :spt_act_qc, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)" 
      t.boolean :approved, null: false, default: false
      t.text :reject_reason
      t.timestamps
    end

    create_table :spt_act_re_assign_request, id: false do |t|  #syntex error _ not -
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)" 
      t.column :reason_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :spt_act_request_on_loan_spare_part, id: false do |t|  #syntex error _ not -
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)" 
      t.column :ticket_on_loan_spare_part_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :spt_act_request_spare_part, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)" 
      t.column :ticket_spare_part_id, "int(10) UNSIGNED NOT NULL"
      t.column :part_terminate_reason_id, "int(10) UNSIGNED"
      t.column :reject_return_part_reason_id, "int(10) UNSIGNED"
      t.timestamps
    end

    # create_table :spt_act_terminate_issue_invoice, id: false do |t|
    #   t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)" 
    #   t.boolean :invoice_completed, null: false, default: false
    #   t.boolean :unit_returned, null: false, default: false
    #   t.boolean :payment_completed, null: false, default: false
    #   t.column :payment_received_id, "int(10) UNSIGNED"
    #   t.timestamps
    # end

    create_table :spt_act_terminate_job, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)" 
      t.column :reason_id, "int(10) UNSIGNED NOT NULL"
      t.boolean :foc_requested, null: false, default: true
      t.boolean :foc_approved, null: false, default: false
      t.column :foc_approved_action_id, "int(10) UNSIGNED"
      t.timestamps
    end

    create_table :spt_act_terminate_job_payment, id: false do |t|
      t.column :id, "INT(10) UNSIGNED NOT NULL, PRIMARY KEY (id)" 
      t.column :ticket_action_id, "INT(10) UNSIGNED NOT NULL" 
      t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
      t.column :payment_item_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.decimal :amount_before_adjust, precision: 10, scale: 2
      t.column :adjust_reason_id, "int(10) UNSIGNED"
      t.column :adjust_action_id, "int(10) UNSIGNED"
      t.column :currency_id, "int(10) UNSIGNED NOT NULL"
      t.boolean :ticket_terminated, null: false, default: false
      t.timestamps
    end

    create_table :spt_act_ticket_close_approve, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)" 
      t.boolean :approved, null: false, default: 0
      t.column :reject_reason_id, "int(10) UNSIGNED"
      t.column :job_belongs_to, "int(10) UNSIGNED"
      t.timestamps
    end

    create_table :spt_act_warranty_extend, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)" 
      t.boolean :extended, null: false, default: 0
      t.column :reject_reason_id, "int(10) UNSIGNED"
      t.text :reject_note
      t.timestamps
    end

    create_table :spt_contact_report_person, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :title_id, "int(10) UNSIGNED NOT NULL"
      t.string :name, null: false                                      #250
      t.timestamps
    end

    create_table :spt_contact_report_person_contact_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :contact_report_person_id, "int(10) UNSIGNED NOT NULL"
      t.column :contact_type_id, "int(10) UNSIGNED NOT NULL"
      t.string :value, null: false                                       #250
      t.timestamps
    end

    create_table :spt_contract, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :customer_id, "int(10) UNSIGNED NOT NULL"
      t.string :contract_no
      t.boolean :contract_b2b
      t.datetime :contract_start_at
      t.datetime :contract_end_at
      t.text :remarks
      t.column :sla_id, "int(10) UNSIGNED NOT NULL"
      t.boolean :active, null: false, default: false
      t.datetime :created_at
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :spt_contract_product, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :contract_id, "int(10) UNSIGNED NOT NULL"
      t.column :product_serial_id, "int(10) UNSIGNED NOT NULL"
      t.column :installed_location_id, "int(10) UNSIGNED"
      t.text :remarks
      t.column :sla_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :spt_customer, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :title_id, "int(10) UNSIGNED NOT NULL"
      t.string :name, null: false
      t.string :address1, null: false                                    #250
      t.string :address2                                   #250
      t.string :address3                                   #250
      t.string :address4                                   #250
      t.column :last_ticket_id, "int(10) UNSIGNED"
      t.column :organization_id, "int(10) UNSIGNED"
      t.column :district_id, "int(10) UNSIGNED"
      t.timestamps
    end

    create_table :spt_customer_contact_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :customer_id, "int(10) UNSIGNED NOT NULL"
      t.column :contact_type_id, "int(10) UNSIGNED NOT NULL"
      t.string :value, null: false                           #250
      t.timestamps
    end

    create_table :spt_invoice, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.datetime :created_at, null: false
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.integer :invoice_no, null: false
      t.decimal :total_amount, null: false, precision: 10, scale: 2
      t.text :note
      t.column :currency_id, "int(10) UNSIGNED NOT NULL"
      t.integer :print_count, null: false, default: 0
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :spt_invoice_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :invoice_id, "int(10) UNSIGNED NOT NULL"
      t.integer :item_no, null: false
      t.string :description
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.timestamps
    end

    create_table :spt_joint_ticket, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
      t.column :joint_ticket_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :spt_print_history, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.integer :print_index, null: false
      t.datetime :print_at, null: false
      t.column :printed_by, "int(10) UNSIGNED"
      t.timestamps
    end

    create_table :spt_problem_category, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :name, null: false
      t.timestamps
    end

    create_table :spt_product_serial, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :serial_no, limit: 25, null: false
      t.column :product_brand_id, "int(10) UNSIGNED NOT NULL"
      t.column :product_category_id, "int(10) UNSIGNED NOT NULL"
      t.string :model_no
      t.string :product_no
      t.column :pop_status_id, "int(10) UNSIGNED"
      t.column :sold_country_id, "int(10) UNSIGNED"
      t.text :pop_note                                      
      t.string :pop_doc_url                                   #250
      t.boolean :corporate_product, null: false, default: false
      t.datetime :sold_at
      t.column :sold_by, "int(10) UNSIGNED"
      t.column :inventory_serial_item_id, "int(10) UNSIGNED"
      t.column :last_ticket_id, "int(10) UNSIGNED"
      t.timestamps
    end

    create_table :spt_product_serial_warranty, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :product_serial_id, "int(10) UNSIGNED NOT NULL"
      t.datetime :start_at
      t.datetime :end_at
      t.integer :period_part
      t.integer :period_labour
      t.integer :period_onsight
      t.column :warranty_type_id, "int(10) UNSIGNED NOT NULL"
      t.text :note                                          
      t.string :care_pack_product_no
      t.string :care_pack_reg_no
      t.timestamps
    end

    create_table :spt_regional_support_center, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :organization_id, "int(10) UNSIGNED NOT NULL"
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    create_table :spt_regional_support_center_engineer, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :regional_support_center_id, "int(10) UNSIGNED NOT NULL"
      t.column :engineer_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :spt_regular_customer, id: false do |t|               
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :customer_id, "int(10) UNSIGNED NOT NULL"
      t.column :contact_person1_id, "int(10) UNSIGNED"
      t.column :contact_person2_id, "int(10) UNSIGNED"
      t.column :reporter_id, "int(10) UNSIGNED"
      t.timestamps
    end

    create_table :spt_return_parts_bundle, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :product_brand_id, "int(10) UNSIGNED NOT NULL"
      t.string :bundle_no
      t.datetime :created_at, null: false
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.boolean :delivered, null: false, default: false
      t.datetime :delivered_at
      t.column :delivered_by, "int(10) UNSIGNED"
      t.text :note                                         
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :spt_so_po, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.datetime :created_at, null: false
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.integer :so_no, null: false
      t.text :note                                          
      t.decimal :po_no, precision: 50, scale: 0
      t.datetime :po_date
      t.column :product_brand_id, "int(10) UNSIGNED"
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.boolean :invoiced, null: false, default: false
      t.column :currency_id, "int(10) UNSIGNED NOT NULL"
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :spt_so_po_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :spt_so_po_id, "int(10) UNSIGNED NOT NULL"
      t.column :ticket_spare_part_id, "int(10) UNSIGNED"
      t.column :ticket_spare_part_item_id, "int(10) UNSIGNED"
      t.integer :item_no, null: false
      t.string :description
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.timestamps
    end

    create_table :spt_ticket, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.integer :ticket_no, null: false
      t.boolean :pop_updated_ticket, null: false, default: false
      t.boolean :contract_available, null: false, default: false
      t.column :contract_id, "int(10) UNSIGNED"
      t.datetime :created_at, null: false
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.integer :priority, null: false, default: 2
      t.column :sla_id, "int(10) UNSIGNED NOT NULL"
      t.column :status_id, "int(10) UNSIGNED NOT NULL"
      t.column :status_resolve_id, "int(10) UNSIGNED NOT NULL"
      t.boolean :status_hold, null: false, default: false
      t.column :hold_reason_id, "int(10) UNSIGNED"
      t.text :remarks                                       
      t.text :resolution_summary                            
      t.column :owner_engineer_id, "int(10) UNSIGNED"
      t.column :problem_category_id, "int(10) UNSIGNED NOT NULL"
      t.text :problem_description                           
      t.text :other_accessories                             
      t.column :informed_method_id, "int(10) UNSIGNED NOT NULL"
      t.column :job_type_id, "int(10) UNSIGNED NOT NULL"
      t.column :ticket_type_id, "int(10) UNSIGNED NOT NULL"
      t.boolean :regional_support_job, null: false, default: false
      t.column :repair_type_id, "int(10) UNSIGNED NOT NULL"
      t.column :warranty_type_id, "int(10) UNSIGNED NOT NULL"
      t.boolean :cus_chargeable, null: false, default: false
      t.column :customer_id, "int(10) UNSIGNED NOT NULL"
      t.column :contact_person1_id, "int(10) UNSIGNED NOT NULL"
      t.column :contact_person2_id, "int(10) UNSIGNED"
      t.column :reporter_id, "int(10) UNSIGNED"
      t.integer :inform_cp
      t.column :contact_type_id, "int(10) UNSIGNED"
      t.datetime :job_started_at
      t.column :job_started_action_id, "int(10) UNSIGNED"
      t.text :job_start_note                               
      t.boolean :job_finished, null: false, default: false
      t.datetime :job_finished_at
      t.boolean :job_closed, null: false, default: false
      t.datetime :job_closed_at
      t.datetime :ticket_closed_at
      t.integer :re_open_count, null: false, default: 0                             
      t.boolean :ticket_close_approval_required, null: false, default: true
      t.boolean :ticket_close_approval_requested, null: false, default: false
      t.boolean :ticket_close_approved, null: false, default: false
      t.boolean :qc_passed, null: false, default: false
      t.boolean :re_assigned, null: false, default: false
      t.boolean :ticket_terminated, null: false, default: false
      t.boolean :cus_payment_required, null: false, default: false
      t.boolean :cus_payment_completed, null: false, default: false
      t.decimal :final_amount_to_be_paid, precision: 10, scale: 2
      t.boolean :pop_updated, null: false, default: false
      t.column :base_currency_id, "int(10) UNSIGNED NOT NULL"
      t.column :manufacture_currency_id, "int(10) UNSIGNED NOT NULL"
      t.integer :ticket_print_count, null: false, default: 0
      t.integer :ticket_complete_print_count, null: false, default: 0
      t.integer :open_time_duration
      t.integer :open_time_duration_sla
      t.datetime :sla_finished_at
      t.decimal :slatime, null: false, precision: 8, scale: 2
      t.column :last_hold_action_id, "int(10) UNSIGNED"
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :spt_ticket_accessory, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
      t.column :accessory_id, "int(10) UNSIGNED NOT NULL"
      t.text :note                                         
      t.timestamps
    end

    create_table :spt_ticket_action, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
      t.column :action_id, "int(10) UNSIGNED NOT NULL"
      t.datetime :action_at, null: false
      t.column :action_by, "int(10) UNSIGNED NOT NULL"
      t.integer :re_open_index, null: false
      t.timestamps
    end

    create_table :spt_ticket_deliver_unit, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.datetime :created_at, null: false
      t.column :deliver_to_id, "int(10) UNSIGNED"
      t.boolean :delivered_to_sup, null: false, default: false
      t.datetime :delivered_to_sup_at
      t.column :delivered_to_sup_by, "int(10) UNSIGNED"
      t.boolean :collected, null: false, default: false
      t.datetime :collected_at
      t.column :collected_by, "int(10) UNSIGNED"
      t.boolean :received, null: false, default: false
      t.datetime :received_at
      t.column :received_by, "int(10) UNSIGNED"
      t.text :note                                         
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :spt_ticket_estimation, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
      t.datetime :requested_at
      t.column :requested_by, "int(10) UNSIGNED"
      t.datetime :estimated_at
      t.column :estimated_by, "int(10) UNSIGNED"
      t.text :note                                          
      t.decimal :advance_payment_amount, precision: 10, scale: 2
      t.boolean :foc_requested, null: false, default: false
      t.boolean :approval_required, null: false, default: false
      t.boolean :approved, null: false, default: false
      t.datetime :approved_at
      t.column :approved_by, "int(10) UNSIGNED"
      t.decimal :approved_adv_pmnt_amount, precision: 10, scale: 2
      t.boolean :foc_approved, null: false, default: false
      t.boolean :cust_approval_required, null: false, default: false
      t.boolean :cust_approved
      t.datetime :cust_approved_at
      t.column :cust_approved_by, "int(10) UNSIGNED"
      t.column :adv_payment_received_id, "int(10) UNSIGNED"
      t.column :status_id, "int(10) UNSIGNED NOT NULL"
      t.column :currency_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :spt_ticket_estimation_additional, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
      t.column :ticket_estimation_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :cost_price, precision: 10, scale: 2
      t.decimal :estimated_price, precision: 10, scale: 2
      t.boolean :below_margine, null: false, default: false
      t.decimal :approved_estimated_price, precision: 10, scale: 2
      t.column :additional_charge_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :spt_ticket_estimation_external, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
      t.column :ticket_estimation_id, "int(10) UNSIGNED NOT NULL"
      t.column :repair_by_id, "int(10) UNSIGNED"
      t.decimal :cost_price, precision: 10, scale: 2
      t.decimal :estimated_price, precision: 10, scale: 2
      t.integer :warranty_period
      t.boolean :below_margine, null: false, default: false
      t.decimal :approved_estimated_price, precision: 10, scale: 2
      t.timestamps
    end

    create_table :spt_ticket_estimation_part, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
      t.column :ticket_estimation_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :cost_price, precision: 10, scale: 2
      t.decimal :estimated_price, precision: 10, scale: 2
      t.boolean :below_margine, null: false, default: false
      t.integer :warranty_period
      t.column :ticket_spare_part_id, "int(10) UNSIGNED NOT NULL"
      t.column :supplier_id, "int(10) UNSIGNED"
      t.decimal :approved_estimated_price, precision: 10, scale: 2
      t.timestamps
    end

    create_table :spt_ticket_fsr, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
      t.datetime :created_at, null: false
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.datetime :work_started_at
      t.datetime :work_finished_at
      t.float :hours_worked
      t.float :down_time
      t.float :travel_hours
      t.float :engineer_time_travel
      t.float :engineer_time_on_site                 
      t.decimal :other_mileage, precision: 10, scale: 2
      t.decimal :other_repairs, precision: 10, scale: 2
      t.text :resolution
      t.string :completion_level, limit: 1
      t.boolean :approved, null: false, default: false
      t.column :approved_action_id, "int(10) UNSIGNED"
      t.text :remarks
      t.integer :print_count, null: false, default: 0                                  
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :spt_ticket_general_question_answer, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
      t.column :ticket_action_id, "int(10) UNSIGNED NOT NULL"
      t.column :general_question_id, "int(10) UNSIGNED NOT NULL"
      t.text :answer                                          
      t.timestamps
    end

    create_table :spt_ticket_on_loan_spare_part, id: false do |t|       
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
      t.column :ref_spare_part_id, "int(10) UNSIGNED NOT NULL"
      t.datetime :requested_at
      t.column :requested_by, "int(10) UNSIGNED"
      t.text :note
      t.column :store_id, "int(10) UNSIGNED"
      t.column :inv_product_id, "int(10) UNSIGNED"
      t.boolean :part_of_main_product, null: false, default: false
      t.column :main_inv_product_id, "int(10) UNSIGNED"
      t.boolean :part_terminated, null: false, default: false
      t.column :part_terminated_reason_id, "int(10) UNSIGNED"
      t.column :status_action_id, "int(10) UNSIGNED NOT NULL"
      t.column :status_use_id, "int(10) UNSIGNED NOT NULL"
      t.boolean :approved, null: false, default: false
      t.datetime :approved_at
      t.column :approved_by, "int(10) UNSIGNED"
      t.column :approved_inv_product_id, "int(10) UNSIGNED"
      t.column :approved_main_inv_product_id, "int(10) UNSIGNED"
      t.boolean :issued, null: false, default: false
      t.datetime :isssued_at
      t.column :issued_by, "int(10) UNSIGNED"
      t.column :inv_srn_id, "int(10) UNSIGNED"
      t.column :inv_srn_item_id, "int(10) UNSIGNED"
      t.boolean :received_eng, null: false, default: false
      t.datetime :received_eng_at
      t.column :received_eng_by, "int(10) UNSIGNED"
      t.datetime :repare_start
      t.datetime :repare_end
      t.string :return_part_serial_no 
      t.string :return_part_ct_no
      t.column :unused_reason_id, "int(10) UNSIGNED"
      t.boolean :part_returned, null: false, default: false
      t.datetime :part_returned_at
      t.column :part_returned_by, "int(10) UNSIGNED"
      t.column :inv_srr_id, "int(10) UNSIGNED"
      t.column :inv_srr_item_id, "int(10) UNSIGNED"
      t.boolean :ret_part_received, null: false, default: false
      t.datetime :ret_part_received_at
      t.column :ret_part_received_by, "int(10) UNSIGNED"
      t.boolean :return_part_damage, null: false, default: false
      t.column :return_part_damage_reason_id, "int(10) UNSIGNED"
      t.timestamps
    end

    create_table :spt_ticket_on_loan_spare_part_status_action, id: false do |t|      
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :on_loan_spare_part_id, "int(10) UNSIGNED NOT NULL"
      t.column :status_id, "int(10) UNSIGNED NOT NULL"
      t.column :done_by, "int(10) UNSIGNED"
      t.datetime :done_at, null: false, default: Time.now
      t.timestamps
    end

    create_table :spt_ticket_payment_received, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.datetime :received_at, null: false
      t.column :received_by, "int(10) UNSIGNED NOT NULL"
      t.text :note                                           
      t.column :type_id, "int(10) UNSIGNED NOT NULL"
      t.column :invoice_id, "int(10) UNSIGNED"
      t.column :currency_id, "int(10) UNSIGNED NOT NULL"
      # t.string :answer                                         #text not string
      t.timestamps
    end

    create_table :spt_ticket_problematic_question_answer, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
      t.column :ticket_action_id, "int(10) UNSIGNED NOT NULL"
      t.column :problematic_question_id, "int(10) UNSIGNED NOT NULL"
      t.text :answer
      t.timestamps
    end

    create_table :spt_ticket_product_serial, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
      t.column :product_serial_id, "int(10) UNSIGNED NOT NULL"
      t.column :ref_product_serial_id, "int(10) UNSIGNED"
      t.timestamps
    end

    create_table :spt_ticket_spare_part, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id,"int(10) UNSIGNED NOT NULL"
      t.column :status_action_id, "int(10) UNSIGNED NOT NULL"
      t.column :fsr_id, "int(10) UNSIGNED"
      t.string :spare_part_no, null: false
      t.string :spare_part_description, null: false
      t.string :faulty_serial_no 
      t.string :faulty_ct_no 
      t.text :note                                          
      t.boolean :cus_chargeable_part, null: false, default: false
      t.boolean :request_from_manufacture, null: false, default: true
      t.boolean :request_from_store, null: false, default: false
      t.boolean :part_terminated, null: false, default: false
      t.column :part_terminated_reason_id, "int(10) UNSIGNED"
      t.string :received_spare_part_no
      t.string :received_part_serial_no
      t.string :received_part_ct_no
      t.boolean :received_eng, null: false, default: 0
      t.datetime :repare_start
      t.datetime :repare_end
      t.string :return_part_serial_no
      t.string :return_part_ct_no
      t.column :status_use_id, "int(10) UNSIGNED NOT NULL"
      t.column :unused_reason_id, "int(10) UNSIGNED"
      t.boolean :part_returned, null: false, default: false
      t.boolean :returned_part_accepted, null: false, default: false
      t.boolean :close_approved, null: false, default: false
      t.column :close_approved_action_id, "int(10) UNSIGNED"
      t.timestamps
    end

    create_table :spt_ticket_spare_part_manufacture, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :spare_part_id, "int(10) UNSIGNED NOT NULL"
      t.string :event_no
      t.string :order_no
      t.boolean :event_closed, null: false, default: false
      t.decimal :payment_expected_manufacture, null: false, precision: 10, scale: 2
      t.boolean :collect_pending_manufacture, null: false, default: false
      t.boolean :collected_manufacture, null: false, default: false
      t.boolean :received_manufacture, null: false, default: false
      t.boolean :issued, null: false, default: false
      t.boolean :ready_to_bundle, null: false, default: false
      t.boolean :bundled, null: false, default: false
      t.column :return_parts_bundle_id, "int(10) UNSIGNED"
      t.column :add_bundle_by, "int(10) UNSIGNED"
      t.datetime :add_bundle_at
      t.boolean :po_completed, null: false, default: false
      t.column :manufacture_currency_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :spt_ticket_spare_part_status_action, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :spare_part_id, "int(10) UNSIGNED NOT NULL"
      t.column :status_id, "int(10) UNSIGNED NOT NULL"
      t.column :done_by, "int(10) UNSIGNED"
      t.datetime :done_at, null: false, default: Time.now         
      t.timestamps
    end

    create_table :spt_ticket_spare_part_store, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :spare_part_id, "int(10) UNSIGNED NOT NULL"
      t.column :store_id, "int(10) UNSIGNED"
      t.column :inv_product_id, "int(10) UNSIGNED"
      t.boolean :part_of_main_product, null: false, default: false
      t.column :mst_inv_product_id, "int(10) UNSIGNED"
      t.boolean :estimation_required, null: false, default: false
      t.integer :ticket_estimation_part_id
      t.boolean :store_requested, null: false, default: false
      t.datetime :store_requested_at
      t.column :store_requested_by, "int(10) UNSIGNED"
      t.boolean :store_request_approved, null: false, default: false
      t.datetime :store_request_approved_at
      t.column :store_request_approved_by, "int(10) UNSIGNED"
      t.column :approved_inv_product_id, "int(10) UNSIGNED"
      t.boolean :store_issued, null: false, default: false
      t.datetime :store_issued_at
      t.column :store_issued_by, "int(10) UNSIGNED"
      t.column :inv_srn_id, "int(10) UNSIGNED"
      t.column :inv_srn_item_id, "int(10) UNSIGNED"
      t.column :inv_srr_id, "int(10) UNSIGNED"
      t.column :inv_srr_item_id, "int(10) UNSIGNED"
      t.boolean :return_part_damage, null: false, default: false
      t.column :return_part_damage_reason_id, "int(10) UNSIGNED"
      t.timestamps
    end

    create_table :spt_ticket_extra_remark, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
      t.column :extra_remark_id, "int(10) UNSIGNED NOT NULL"
      t.text :note
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :spt_ticket_workflow_process, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
      t.string :process_id, null: false
      t.string :process_name
      t.timestamps
    end

    create_table :spt_act_print_invoice, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL , PRIMARY KEY (ticket_action_id)"
      t.column :invoice_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end
  end
end
