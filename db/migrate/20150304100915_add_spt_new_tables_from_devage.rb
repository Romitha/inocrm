class AddSptNewTablesFromDevage < ActiveRecord::Migration
  def change
  	create_table :spt_act_action_taken, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.text :action
  		t.timestamps
  	end

  	create_table :spt_act_assign_regional_support_center, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.column :regional_support_center_id, "INT UNSIGNED"
  		t.timestamps
  	end

  	create_table :spt_act_assign_ticket, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.column :sbu_id, "INT UNSIGNED"
  		t.column :assign_to, "INT UNSIGNED"
  		t.boolean :recorrection
  		t.boolean :regional_support_center_job
  		t.timestamps
  	end

  	create_table :spt_act_customer_feedback, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.boolean :re_opened        										      
  		t.boolean :unit_return_customer
  		t.column :payment_received_id, "INT UNSIGNED"
  		t.boolean :payment_completed
  		t.column :feedback_id, "INT UNSIGNED"
  		t.text :feedback_description        					      
  		t.timestamps
  	end

  	create_table :spt_act_deliver_unit, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.column :ticket_deliver_unit_id, "INT UNSIGNED"
  		t.column :deliver_to_id, "INT UNSIGNED"
  		t.text :deliver_note        									     
  		t.text :recive_note        										      
  		t.timestamps
  	end

  	create_table :spt_act_edit_serial_request, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.text :reason        												      
  		t.timestamps
  	end

  	create_table :spt_act_finish_job, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.text :resolution        										     
  		t.timestamps
  	end

  	create_table :spt_act_fsr, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.boolean :print_fsr
  		t.column :fsr_id, "INT UNSIGNED"
  		t.timestamps
  	end

  	create_table :spt_act_hold, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.column :reason_id, "INT UNSIGNED"
  		t.boolean :sla_pause
  		t.timestamps
  	end

  	create_table :spt_act_hp_case_action, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.string :case_id
  		t.text :case_note        											      
  		t.timestamps
  	end

  	create_table :spt_act_inform_customer, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.column :contact_type_id, "INT UNSIGNED"
  		t.text :note        													      
  		t.timestamps
  	end

  	create_table :spt_act_job_estimate, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.column :supplier_id, "INT UNSIGNED"
  		t.text :note        													      
  		t.column :ticket_estimation_id, "INT UNSIGNED"
  		t.timestamps
  	end

  	create_table :spt_act_payment_received, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.column :ticket_payment_received_id, "INT UNSIGNED"
  		t.boolean :invoice_completed
  		t.timestamps
  	end

  	create_table :spt_act_qc, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.boolean :approved
  		t.text :reject_reason        												
  		t.timestamps
  	end

  	create_table :spt_act_re_assign_request, id: false do |t|  #syntex error _ not -
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.column :reason_id, "INT UNSIGNED"
  		t.timestamps
  	end

  	create_table :spt_act_request_on_loan_spare_part, id: false do |t|  #syntex error _ not -
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.column :ticket_on_loan_spare_part_id, "INT UNSIGNED"
  		t.timestamps
  	end

  	create_table :spt_act_request_spare_part, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.column :ticket_spare_part_id, "INT UNSIGNED"
  		t.column :terminate_reason_id, "INT UNSIGNED"
  		t.column :reject_return_part_reason_id, "INT UNSIGNED"
  		t.timestamps
  	end

  	create_table :spt_act_terminate_issue_invoice, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.boolean :invoice_completed
  		t.boolean :unit_returned
  		t.boolean :payment_completed
  		t.column :payment_received_id, "INT UNSIGNED"
  		t.timestamps
  	end

  	create_table :spt_act_terminate_job, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.column :reason_id, "INT UNSIGNED"
  		t.boolean :foc_requested
  		t.boolean :foc_approved
  		t.column :foc_approved_action_id, "INT UNSIGNED"
  		t.timestamps
  	end

  	create_table :spt_act_terminate_job_payment, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.column :ticket_id, "INT UNSIGNED"
  		t.column :payment_item_id, "INT UNSIGNED"
  		t.decimal :amount
      t.decimal :amount_before_adjust
  		t.column :adjust_reason_id, "INT UNSIGNED"
  		t.column :adjust_action_id, "INT UNSIGNED"
  		t.column :currency_id, "INT UNSIGNED"
  		t.timestamps
  	end

  	create_table :spt_act_ticket_close_approve, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.boolean :approved
  		t.column :reject_reason_id, "INT UNSIGNED"
  		t.column :job_belongs_to, "INT UNSIGNED"
  		t.timestamps
  	end

  	create_table :spt_act_warranty_extend, id: false do |t|
  		t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"    #check
  		t.boolean :extended
  		t.column :reject_reason_id, "INT UNSIGNED"
  		t.text :reject_note        													
  		t.timestamps
  	end

  	create_table :spt_contact_report_person, id: false do |t|
  		t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
  		t.column :title_id, "INT UNSIGNED"
  		t.string :name                                      #250
  		t.timestamps
  	end

  	create_table :spt_contact_report_person_contact_type, id: false do |t|
  		t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
  		t.column :contact_report_person_id, "INT UNSIGNED"
  		t.column :contact_type_id, "INT UNSIGNED"
  		t.string :value        													     #250
  		t.timestamps
  	end

  	create_table :spt_contract, id: false do |t|
  		t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
  		t.column :customer_id, "INT UNSIGNED"
  		t.string :contract_no
  		t.boolean :contract_b2b
  		t.datetime :contract_start_at
  		t.datetime :contract_end_at
  		t.text :remarks       													   
  		t.integer :sla
  		t.boolean :active
  		t.datetime :created_at
  		t.column :created_by, "INT UNSIGNED"
  		t.timestamps
  	end

  	create_table :spt_contract_product, id: false do |t|
  		t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
  		t.column :contract_id, "INT UNSIGNED"
  		t.column :product_serial_id, "INT UNSIGNED"
  		t.column :installed_location_id, "INT UNSIGNED"
  		t.text :remarks       													   
  		t.integer :sla
  		t.timestamps
  	end

    create_table :spt_cus_recieved_note_print_history, id: false do |t|     #received not recieved
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :print_history_id, "INT UNSIGNED"
      t.column :ticket_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :spt_cus_returned_note_print_history, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :print_history_id, "INT UNSIGNED"
      t.column :ticket_id, "INT UNSIGNED"
      t.timestamps
    end

  	create_table :spt_customer, id: false do |t|
  		t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
  		t.column :title_id, "INT UNSIGNED"
  		t.string :name
  		t.string :address1       													   #250
  		t.string :address2       													   #250
  		t.string :address3       													   #250
  		t.string :address4       													   #250
  		t.column :last_ticket_id, "INT UNSIGNED"
  		t.column :organization_id, "INT UNSIGNED"
  		t.timestamps
  	end

  	create_table :spt_customer_contact_type, id: false do |t|
  		t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
  		t.column :customer_id, "INT UNSIGNED"
  		t.column :contact_type_id, "INT UNSIGNED"
  		t.string :value        													     #250
  		t.timestamps
  	end

    create_table :spt_fsr_print_history, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :print_history_id, "INT UNSIGNED"
      t.column :fsr_id, "INT UNSIGNED"
      t.timestamps
    end

  	create_table :spt_invoice, id: false do |t|
  		t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
  		t.datetime :created_at
  		t.column :created_by, "INT UNSIGNED"
  		t.integer :invoice_no
  		t.decimal :total_amount
  		t.text :note        													     
  		t.column :currency_id, "INT UNSIGNED"
  		t.timestamps
  	end

  	create_table :spt_invoice_item, id: false do |t|
  		t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
  		t.column :invoice_id, "INT UNSIGNED"
  		t.integer :item_no
  		t.string :description 
  		t.decimal :amount
  		t.timestamps
  	end

    create_table :spt_invoice_print_history, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :print_history_id, "INT UNSIGNED"
      t.column :invoice_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :spt_joint_ticket, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED"
      t.column :joint_ticket_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :spt_print_history, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.integer :print_index
      t.datetime :print_at
      t.column :printed_by, "INT UNSIGNED"
      t.timestamps
    end

    create_table :spt_problem_category, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :name
      t.timestamps
    end

    create_table :spt_product_serial, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :serial_no, limit: 25       
      t.column :product_brand_id, "INT UNSIGNED"
      t.column :product_category_id, "INT UNSIGNED"
      t.string :model_no
      t.string :product_no
      t.column :pop_status_id, "INT UNSIGNED"
      t.column :sold_country_id, "INT UNSIGNED"
      t.text :pop_note                                      
      t.string :pop_doc_url                                   #250
      t.boolean :corporate_product
      t.datetime :sold_at
      t.column :sold_by, "INT UNSIGNED"
      t.column :inventory_serial_item_id, "INT UNSIGNED"
      t.column :last_ticket_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :spt_product_serial_warranty, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :product_serial_id, "INT UNSIGNED"
      t.datetime :start_at
      t.datetime :end_at
      t.integer :period_part
      t.integer :period_labour
      t.integer :corporate_onsight
      t.column :warranty_type_id, "INT UNSIGNED"
      t.text :note                                          
      t.string :care_pack_product_no
      t.string :care_pack_reg_no
      t.timestamps
    end

    create_table :spt_regional_support_center, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :organization_id, "INT UNSIGNED"
      t.boolean :active
      t.timestamps
    end

    create_table :spt_regular_customer, id: false do |t|               
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :customer_id, "INT UNSIGNED"
      t.column :contact_person1_id, "INT UNSIGNED"
      t.column :contact_person2_id, "INT UNSIGNED"
      t.column :reporter_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :spt_return_parts_bundle, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :product_brand_id, "INT UNSIGNED"
      t.string :bundle_no
      t.datetime :created_at
      t.column :created_by, "INT UNSIGNED"
      t.boolean :delivered
      t.datetime :delivered_at
      t.column :delivered_by, "INT UNSIGNED"
      t.text :note                                         
      t.timestamps
    end

    create_table :spt_so_po, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.datetime :created_at
      t.column :created_by, "INT UNSIGNED"
      t.integer :so_no
      t.text :note                                          
      t.decimal :po_no
      t.datetime :po_date
      t.column :product_brand_id, "INT UNSIGNED"
      t.decimal :amount
      t.boolean :invoiced
      t.column :currency_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :spt_so_po_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :spt_so_po_id, "INT UNSIGNED"
      t.column :ticket_spare_part_id, "INT UNSIGNED"
      t.column :ticket_spare_part_item_id, "INT UNSIGNED"
      t.integer :item_no
      t.string :description
      t.decimal :amount
      t.timestamps
    end

    create_table :spt_ticket, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.integer :ticket_no
      t.boolean :pop_updated_ticket
      t.boolean :contract_available
      t.column :contract_id, "INT UNSIGNED"
      t.datetime :created_at
      t.column :created_by, "INT UNSIGNED"
      t.integer :priority
      t.integer :sla_time
      t.column :status_id, "INT UNSIGNED"
      t.column :status_resolve_id, "INT UNSIGNED"
      t.boolean :status_hold
      t.column :hold_reason_id, "INT UNSIGNED"
      t.text :remarks                                       
      t.text :resolution_summary                            
      t.column :owner_engineer_id, "INT UNSIGNED"
      t.column :problem_category_id, "INT UNSIGNED"
      t.text :problem_description                           
      t.text :other_accessories                             
      t.column :informed_method_id, "INT UNSIGNED"
      t.column :job_type_id, "INT UNSIGNED"
      t.column :ticket_type_id, "INT UNSIGNED"
      t.boolean :regional_support_job
      t.column :repair_type_id, "INT UNSIGNED"
      t.column :warranty_type_id, "INT UNSIGNED"
      t.boolean :cus_chargeable
      t.column :customer_id, "INT UNSIGNED"
      t.column :contact_person1_id, "INT UNSIGNED"
      t.column :contact_person2_id, "INT UNSIGNED"
      t.column :reporter_id, "INT UNSIGNED"
      t.integer :inform_cp
      t.column :contact_type_id, "INT UNSIGNED"
      t.datetime :job_started_at
      t.column :job_started_action_id, "INT UNSIGNED"
      t.text :job_start_note                               
      t.boolean :job_finished
      t.boolean :job_closed
      t.datetime :job_closed_at
      t.datetime :ticket_closed_at
      t.integer :re_open_count                                
      t.boolean :ticket_close_approval_required
      t.boolean :ticket_close_approval_requested
      t.boolean :ticket_close_approved
      t.boolean :qc_passed
      t.boolean :re_assigned                                  
      t.boolean :terminated
      t.boolean :cus_payment_required
      t.boolean :cus_payment_completed
      t.decimal :final_amount_to_be_paid
      t.boolean :pop_updated
      t.column :base_currency_id, "INT UNSIGNED"
      t.column :manufacture_currency_id, "INT UNSIGNED"
      t.integer :cus_received_note_print_count
      t.integer :cus_returned_note_print_count
      t.integer :open_time_duration
      t.integer :open_time_duration_sla
      t.timestamps
    end

    create_table :spt_ticket_accessory, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED"
      t.column :accessory_id, "INT UNSIGNED"
      t.text :note                                         
      t.timestamps
    end

    create_table :spt_ticket_action, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED"
      t.column :action_id, "INT UNSIGNED"
      t.datetime :action_at
      t.column :action_by, "INT UNSIGNED"
      t.integer :re_open_count                              
      t.timestamps
    end

    create_table :spt_ticket_deliver_unit, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED"
      t.column :created_by, "INT UNSIGNED"
      t.datetime :created_at
      t.column :deliver_to_id, "INT UNSIGNED"
      t.boolean :delivered_to_sup
      t.datetime :delivered_to_sup_at
      t.column :delivered_to_sup_by, "INT UNSIGNED"
      t.boolean :collected
      t.datetime :collected_at
      t.column :collected_by, "INT UNSIGNED"
      t.boolean :received
      t.datetime :received_at
      t.column :received_by, "INT UNSIGNED"
      t.text :note                                         
      t.timestamps
    end

    create_table :spt_ticket_estimation, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED"
      t.datetime :requested_at
      t.column :requested_by, "INT UNSIGNED"
      t.datetime :estimated_at
      t.column :estimated_by, "INT UNSIGNED"
      t.text :note                                          
      t.decimal :advance_payment_amount
      t.boolean :foc_requested
      t.boolean :approval_required
      t.boolean :approved
      t.datetime :approved_at
      t.column :approved_by, "INT UNSIGNED"
      t.decimal :approved_adv_pmnt_amount
      t.boolean :foc_approved
      t.boolean :cust_approval_required
      t.boolean :cust_approved
      t.datetime :cust_approved_at
      t.column :cust_approved_by, "INT UNSIGNED"
      t.column :adv_payment_received_id, "INT UNSIGNED"
      t.column :status_id, "INT UNSIGNED"
      t.column :currency_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :spt_ticket_estimation_additional, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED"
      t.column :ticket_estimation_id, "INT UNSIGNED"
      t.decimal :cost_price
      t.decimal :estimated_price
      t.boolean :below_margine
      t.decimal :approved_estimated_price
      t.column :additional_charge_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :spt_ticket_estimation_external, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED"
      t.column :ticket_estimation_id, "INT UNSIGNED"
      t.column :repair_by_id, "INT UNSIGNED"
      t.decimal :cost_price
      t.decimal :estimated_price
      t.integer :warranty_period
      t.boolean :below_margine
      t.decimal :approved_estimated_price
      t.timestamps
    end

    create_table :spt_ticket_estimation_part, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED"
      t.column :ticket_estimation_id, "INT UNSIGNED"
      t.decimal :cost_price
      t.decimal :estimated_price
      t.boolean :below_margine
      t.integer :warranty_period
      t.column :ticket_spare_part_id, "INT UNSIGNED"
      t.column :supplier_id, "INT UNSIGNED"
      t.decimal :approved_estimated_price
      t.timestamps
    end

    create_table :spt_ticket_fsr, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED"
      t.datetime :created_at
      t.column :created_by, "INT UNSIGNED"
      t.datetime :work_started_at
      t.datetime :work_finished_at
      t.float :hours_worked
      t.float :down_time
      t.float :travel_hours
      t.float :engineer_time_travel
      t.float :engineer_time_on_site                 
      t.decimal :other_mileage
      t.decimal :other_repairs
      t.string :resolution
      t.string :code, limit: 1
      t.boolean :approved
      t.column :approved_action_id, "INT UNSIGNED"
      t.text :remarks
      t.integer :print_count                                     
      t.timestamps
    end

    create_table :spt_ticket_general_question_answer, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED"
      t.column :ticket_action_id, "INT UNSIGNED"
      t.column :general_question_id, "INT UNSIGNED"
      t.text :answer                                          
      t.timestamps
    end

    create_table :spt_ticket_on_loan_spare_part, id: false do |t|       
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED"
      t.column :ref_spare_part_id, "INT UNSIGNED"
      t.datetime :requested_at
      t.column :requested_by, "INT UNSIGNED"
      t.text :note
      t.column :store_id, "INT UNSIGNED"
      t.column :inv_product_id, "INT UNSIGNED"
      t.boolean :part_of_main_product
      t.column :main_inv_product_id, "INT UNSIGNED"
      t.boolean :terminated
      t.column :terminated_reason_id, "INT UNSIGNED"
      t.column :status_action_id, "INT UNSIGNED"
      t.column :status_use_id, "INT UNSIGNED"
      t.boolean :approved
      t.datetime :approved_at
      t.column :approved_by, "INT UNSIGNED"
      t.column :appoved_inv_product_id, "INT UNSIGNED"
      t.column :approved_main_inv_product_id, "INT UNSIGNED"
      t.boolean :issued
      t.datetime :isssued_at
      t.column :issued_by, "INT UNSIGNED"
      t.column :inv_srn_id, "INT UNSIGNED"
      t.column :inv_srn_item_id, "INT UNSIGNED"
      t.boolean :received_eng
      t.datetime :received_eng_at
      t.column :received_eng_by, "INT UNSIGNED"
      t.datetime :repare_start
      t.datetime :repare_end
      t.string :return_part_serial_no 
      t.string :return_part_ct_no
      t.column :unused_reason_id, "INT UNSIGNED"
      t.boolean :part_returned
      t.datetime :part_returned_at
      t.column :part_returned_by, "INT UNSIGNED"
      t.column :inv_srr_id, "INT UNSIGNED"
      t.column :inv_srr_item_id, "INT UNSIGNED"
      t.boolean :ret_part_received
      t.datetime :ret_part_received_at
      t.column :ret_part_received_by, "INT UNSIGNED"
      t.boolean :return_part_damage
      t.column :return_part_damage_reason_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :spt_ticket_on_loan_spare_part_status_action, id: false do |t|      
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :on_loan_spare_part_id, "INT UNSIGNED"
      t.column :status_id, "INT UNSIGNED"
      t.column :done_by, "INT UNSIGNED"
      t.datetime :done_at
      t.timestamps
    end

    create_table :spt_ticket_payment_received, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED"
      t.decimal :amount
      t.datetime :received_at
      t.column :received_by, "INT UNSIGNED"
      t.text :note                                           
      t.column :type_id, "INT UNSIGNED"
      t.column :invoice_id, "INT UNSIGNED"
      t.column :currency_id, "INT UNSIGNED"
      # t.string :answer                                         #text not string
      t.timestamps
    end

    create_table :spt_ticket_problematic_question_answer, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED"
      t.column :ticket_action_id, "INT UNSIGNED"
      t.column :problematic_question_id, "INT UNSIGNED"
      t.text :answer
      t.timestamps
    end

    create_table :spt_ticket_product_serial, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED"
      t.column :product_serial_id, "INT UNSIGNED"
      t.column :ref_product_serial_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :spt_ticket_spare_part, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED"
      t.column :status_action_id, "INT UNSIGNED"
      t.column :fsr_id, "INT UNSIGNED"
      t.string :spare_part_no 
      t.string :spare_part_description 
      t.string :faulty_serial_no 
      t.string :faulty_ct_no 
      t.text :note                                          
      t.boolean :cus_chargeable_part
      t.boolean :request_from_manufacture
      t.boolean :request_from_store
      t.boolean :terminated
      t.column :terminated_reason_id, "INT UNSIGNED"
      t.string :received_spare_part_no
      t.string :received_part_serial_no
      t.string :received_part_ct_no
      t.boolean :received_eng
      t.datetime :repare_start
      t.datetime :repare_end
      t.string :return_part_serial_no
      t.string :return_part_ct_no
      t.column :status_use_id, "INT UNSIGNED"
      t.column :unused_reason_id, "INT UNSIGNED"
      t.boolean :part_returned
      t.boolean :returned_part_accepted
      t.boolean :close_approved
      t.column :close_approved_action_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :spt_ticket_spare_part_manufacture, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :spare_part_id, "INT UNSIGNED"
      t.string :event_no
      t.string :order_no
      t.boolean :event_closed
      t.decimal :payment_expected_manufacture
      t.boolean :collect_pending_manufacture
      t.boolean :collected_manufacture
      t.boolean :received_manufacture
      t.boolean :issued
      t.boolean :ready_to_bundle
      t.boolean :bundled
      t.column :return_parts_bundle_id, "INT UNSIGNED"
      t.column :add_bundle_by, "INT UNSIGNED"
      t.datetime :add_bundle_at
      t.boolean :po_completed
      t.column :manufacture_currency_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :spt_ticket_spare_part_status_action, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :spare_part_id, "INT UNSIGNED"
      t.column :status_id, "INT UNSIGNED"
      t.column :done_by, "INT UNSIGNED"
      t.datetime :done_at                               
      t.timestamps
    end

    create_table :spt_ticket_spare_part_store, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :spare_part_id, "INT UNSIGNED"
      t.column :store_id, "INT UNSIGNED"
      t.column :inv_product_id, "INT UNSIGNED"
      t.boolean :part_of_main_product
      t.column :mst_inv_product_id, "INT UNSIGNED"
      t.boolean :estimation_required
      t.integer :ticket_estimation_part_id
      t.boolean :store_requested
      t.datetime :store_requested_at
      t.column :store_requested_by, "INT UNSIGNED"
      t.boolean :store_request_approved
      t.datetime :store_request_approved_at
      t.column :store_request_approved_by, "INT UNSIGNED"
      t.column :approved_inv_product_id, "INT UNSIGNED"
      t.boolean :store_issued
      t.datetime :store_issued_at
      t.column :store_issued_by, "INT UNSIGNED"
      t.column :inv_srn_id, "INT UNSIGNED"
      t.column :inv_srn_item_id, "INT UNSIGNED"
      t.column :inv_srr_id, "INT UNSIGNED"
      t.column :inv_srr_item_id, "INT UNSIGNED"
      t.boolean :return_part_damage
      t.column :return_part_damage_reason_id, "INT UNSIGNED"
      t.timestamps
    end
  end
end
