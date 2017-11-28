require "api_constraint"

Rails.application.routes.draw do

  root "todos#index"

  namespace :api, defaults: {format: :json} do
    # namespace :v1 do
    #   resources :systems
    # end

    scope module: :v1, constraints: ApiConstraint.new(default: true, version: "v1") do
      resources :systems

    end

  end

  resources :contracts do
    collection do
      patch "contracts"
      get "search_product"
      get "search_product_contract"
      get "customer_search"
      post "submit_selected_products"
      post "save_cus_products"
      post "payments_save"
      post "generate_contract_document"
      put "contract_update"
      put "edit_contract"
      put "update_payments"
      put "update_contract_product"
      post "upload_generated_document"
      delete "remove_generated_document"
    end
  end

  resources :warranties do
    collection do
      post "select_for_warranty"
      post "extend_warranty_update_extend_warranty"
    end
  end

  resources :q_and_as do
    collection do
      get "q_and_answer_record"
      patch "update_ticket_q_and_a"
    end
  end

  resources :reports do
    collection do
      get "quotation"
      get "excel_output"
      get "po_output"
      get "contract_report"
      get "contract_cost_analys_report" 
      get "contract_ticket_report"
    end
  end


  devise_for :users, skip: [:registrations, :passwords, :confirmations], :controllers => {:sessions => 'sessions'}

  concern :polymophicable do
    resources :addresses, except: [:index, :show, :new, :edit] do
      member do
        post "make_primary_address"
      end
    end

    resources :contact_numbers, except: [:index, :show, :new, :edit] do
      member do
        post "make_primary_contact_number"
      end
      collection do
        delete "destroy_customer_contact_detail"
      end
    end
  end

  concern :attachable do
    resources :document_attachments
  end

  resources :users, concerns: :polymophicable, only: []
  resources :organizations, concerns: :polymophicable do
    resources :designations
    resources :departments
    resources :roles_and_permissions do
      post "load_permissions"
      collection do
        post "assign_bpm_role"
      end
    end
    member do
      get "dashboard"
      put "relate"
      get "pin_relation"
      post "create_organization_contact_person"
      put "update_organization_contact_person"
      post "create_bank_detail"
      put "update_organization_bank_detail"
      delete "delete_organization_bank_detail"
      post "option_for_vat_number"
      patch "demote_as_department"
      delete "remove_department_org"
      put "inline_customer_contact_detail"
      post "dealer_types"
    end
    concerns :attachable

    collection do
      patch "temp_save_user_profile_image"
    end
  end

  resources :users, only: [:new, :update, :create] do
    collection do
      get "individual_customers"
      get "check_user_session"
    end
    member do
      get "initiate_user_profile_edit"
      get 'profile'
      put "upload_avatar"
      get "assign_role"
    end
  end


  resources :tickets do
    concerns :attachable
    collection do

      post "find_by_serial"
      post "save_cache_ticket"
      post "create_po"
      get "ticket_in_modal"
      get "new_product_brand"
      get "new_product_category"
      get "new_product"
      get "new_customer"
      get "contact_persons"
      get "remarks"
      get "paginate_ticket_histories"
      get "paginate_ticket_grn_items"
      get "paginate_payment_pending_tickets"
      get "edit-ticket", :action => :edit_ticket
      get "pop-approval"#, :action => :pop_note
      get "resolution"
      get "order_manufacture_parts", :action => :order_mf
      get "received_and_issued"
      get "return_manufacture_part"
      get "bundle_return_part" #same interface
      get "issue_store_part"
      get "deliver_bundle" #same interface
      get "terminate_invoice"
      get "collect_parts" #same interface
      get "return_store_part"
      get "deliver_parts_bundle"
      get "approve_store_parts"
      get "ticket_close_approval"
      get "assign-ticket", action: :assign_ticket
      get "estimate_job_final"
      get "estimate_job"
      get "ticket_spare_part_in_modal"
      get "estimate_the_part_internal"#"estimate_part"
      get "deliver_unit"
      get "job_below_margin_estimate_approval"#low_margin_estimate"
      get "workflow_diagram"
      get "suggesstion_data"
      get "edit_serial"
      match "extend_warranty", to: "tickets#extend_warranty", via: [:get, :post]
      get "close_event"#, to: "tickets#close_event", via: [:get, :post]
      get "check_fsr"
      get "customer_feedback"
      get "low_margin_estimate_parts_approval"
      get "invoice_for_chargeable"
      get "quality_control"
      get "invoice_advance_payment"
      get "load_estimation_grn_items"
      get "quality_control"
      get "advance_payment_invoice"
      get "customer_advance_payment"
      get "create_invoice_for_hp"
      get "terminate_job_foc_approval"
      get "customer_inquire"
      match "add_edit_contract", to: "tickets#add_edit_contract", via: [:get, :post, :put]
      delete "delete_add_edit_contract"
      get "inform_customer_in_modal"
      get "master_data"
      get "hp_po"
      get "view_po"
      get "view_delivered_bundle"
      get "approve_manufacture_parts"

      post "update_issue_store_parts"

      # post "save_add_edit_contract"

      get "alert"

      get "load_sbu"
      post "update_assign_engineer_ticket"
      post "remove_eng"

      get "ajax_show"
      put "edit_po_note"
      post "create_product_brand"
      post "create_new_category"
      post "create_new_product"
      post "create_product"
      post "create_customer"
      post "select_sla"
      post "create_sla"

      post "create_contact_persons"
      post "create_contact_person_record"
      post "create_problem_category"
      post "create_accessory"
      post "create_extra_remark"
      post "after_printer"
      post "get_template"

      put "product_update"
      put "ticket_update"
      put "update_edit_ticket"

      post "create_product_country"
      post "finalize_ticket_save"

      post "q_and_answer_save"

      post "join_tickets"
      post "update_assign_ticket"
      post "update_pop_approval"
      post "call_resolution_template"
      post "js_call_invoice_for_hp"
      post "js_call_invoice_item"
      post "js_call_view_more_inv_so"
      post "create_invoice_for_so"
      post "call_mf_order_template"
      post "call_alert_template"
      post "update_order_mfp_part_order"
      post "update_order_mfp_wrrnty_extnd_rqst"
      post "update_order_mfp_return_manufacture_part"
      post "update_order_mfp_termnt_prt_order"
      post "update_approve_store_parts"
      post "update_approve_manufacture_parts"
      post "update_deliver_bundle"
      post "update_bundle_return_part"
      post "update_edit_serial"
      post "update_close_event"

      post "update_received_and_issued"
      post "extend_warranty_update_reject_extend_warranty"
      post "update_return_manufacture_part"
      post "hold_unhold"
      post "update_estimation_part"
      post "update_return_store_part"
      post "update_ticket_close_approval"
      post "update_collect_parts"

    end

    member do
      post "update_start_action"
      post "update_re_assign"
      post 'update_change_ticket_cus_warranty'
      post 'update_change_ticket_repair_type'
      post 'update_hold'
      post 'update_un_hold'
      post 'update_edit_serial_no_request'
      post 'update_create_fsr'
      post 'update_edit_fsr'
      post 'update_terminate_job'
      post 'update_action_taken'
      post 'update_request_spare_part'
      post 'update_request_on_loan_spare_part'
      post 'update_hp_case_id'
      post 'update_resolved_job'
      post 'update_deliver_unit'
      post 'update_job_estimation_request'
      post 'update_recieve_unit'
      post 'update_check_fsr'
      post 'update_request_close_approval'
    end
  end

  resources :todos do
    collection do
      get "to_do_call"
      get "work_flow_mapping_sort"
    end
  end

  match "validate_resource", controller: "admins/dashboards", action: "validate_resource", via: [:post]
  namespace :admins do
    root "dashboards#index"
    resources :tickets do
      collection do
        get "problem_category"
        get "q_and_a"
        delete "delete_admin_reason"
        delete "delete_admin_accessory"
        delete "delete_admin_additional_charge"
        delete "delete_admin_spare_part_description"
        delete "delete_admin_ticket_start_action"
        delete "delete_admin_general_question"
        delete "delete_admin_customer_feedback"
        delete "delete_problem_category"
        delete "delete_q_and_a"
        delete "delete_dispatch_method"
        delete "delete_admin_payment_item"
        delete "delete_payment_term"
        delete "delete_tax"
        delete "delete_tax_rate"
        delete "delete_admin_brands_and_category"
        [
          :reason,
          :accessories,
          :additional_charge,
          :spare_part_description,
          :start_action,
          :customer_feedback,
          :general_question,
          :problem_and_category,
          :dispatch_method,
          :payment_item,
          :payment_term,
          :tax,
          :brands_and_category,
          :annexture
        ].each do |action|
          match "#{action.to_s}", action: action, via: [:get, :post, :put]
        end
      end
    end
    resources :employees do
      collection do
        delete "delete_admin_sbu"
        delete "delete_admin_sbu_engineer"
        [
          :sbu
        ].each do |action|
          match "#{action.to_s}", action: action, via: [:get, :post, :put] 
        end
      end
    end
    resources :organizations do
      collection do
        delete "delete_admin_regional_support_center"
        delete "delete_sbu_regional_engineer"
        delete "delete_admin_country"
        delete "delete_admin_sla"
        delete "delete_admin_industry_type"
        [
          :regional_support_center,
          :country,
          :sla,
          :store_and_branch,
          :industry_type,
        ].each do |action|
          match "#{action.to_s}", action: action, via: [:get, :post, :put] 
        end
      end
    end
    resources :users do
      collection do
        delete "delete_admin_title"
        [
          :title,
        ].each do |action|
          match "#{action.to_s}", action: action, via: [:get, :post, :put]
        end
      end
    end
    resources :searches do
      collection do
        get "search_customers_suppliers"
        get "search_gins"
        get "search_receives"
        get "search_returns"
        get "search_results"
        get "search_issues"
        get "search_grn"
        get "inventories"
        get "inventory_serial_item_history"
        get "search_inventory_serial_item"
        get "view_inventory_serial_item"

      end
    end

    resources :inventories do

      collection do

        get "gins"
        get "srrs"
        get "srns"
        get "prns"
        get "pos"
        # get "close_po"
        get "view_srn"
        get "view_prn"
        get "view_gin"
        get "grn"
        get "po"
        post "create_po"
        get "grn_main_part"
        match "upload_grn_file", action: :upload_grn_file, via: [:get, :post]
        post "initialize_grn"
        post "create_grn"
        patch "create_grn_for_main_part"
        post "initiate_grn_for_i_product"
        post "initiate_grn_for_srr"
        post "create_grn_for_i_product"

        post "create_additional_cost"
        post "update_grn_cost"

        get "srn"
        post "create_srn"

        get "prn"
        post "create_prn"
        post "submit_selected_products"
        post "filter_product_and_category"

        get "gin"
        # get "batch_or_serial_for_gin"
        match "batch_or_serial_for_gin", action: :batch_or_serial_for_gin, via: [:get, :post]

        post "create_gin"

        get 'srr'
        post 'create_srr'

        get "search_product_inventories"

        delete "delete_product_category"
        delete "delete_admin_brands_and_category"
        delete "delete_location_rack"
        delete "delete_location_shelf"
        delete "delete_location_bin"
        delete "delete_inventory_brand"
        delete "delete_inventory_product"
        delete "delete_inventory_product_category"
        delete "delete_inventory_category"
        delete "delete_inventory_product_form"
        delete "delete_product_condition"
        delete "delete_disposal_method"
        delete "delete_admin_inventory_reason"
        delete "delete_manufacture"
        delete "delete_inventory_unit"
        [
          :location,
          :inventory_product,
          :category,
          :inventory_brand,
          :inventory_product_category,
          :inventory_product_condition,
          :inventory_disposal_method,
          :inventory_reason,
          :inventory_manufacture,
          :inventory_unit,
          :product,
          :product_condition,
          :disposal_method,
          :reason,
          :manufacture,
          :unit,
          :inventory,
          :close_po,
          :close_srn,
          :close_prn,
        ].each do |action|
          match "#{action.to_s}", action: action, via: [:get, :post, :put]
        end

        get "filter_brand_product"
        get "serial_item_or_part"

      end
    end
    resources :dashboards do
      collection do
        post "reindex_all_model"
      end
    end
    resources :sales

    resources :roles do
      collection do
        post "filter_permissions"
        post "subject_attributes_form"
        [
          :permissions,
          :create_permissions,
          :attributes,
          # :filter_permissions,
        ].each do |action|
          match "#{action.to_s}", action: action, via: [:get, :post, :put]
        end
      end      
    end
  end

  # resources :roles do
  #   collection do
  #     get "permissions"
  #     post "create_permissions"
  #   end
  # end

  resources :inventories, except: [:index, :show, :create, :new, :update, :destroy, :edit] do
    collection do
      get "generate_serial_no"
      get "search_inventory_product"
      get "inventory_in_modal"
      get "search_inventories"
      get "load_serial_and_part"
      get "load_estimation"
      get "load_estimation_ticket_info"
      get "toggle_add_update_return_part"
      post "product_info"
      get "hp_po"
      post "load_serialparts"
      get "paginate_hp_po_sales_order"
      get "add_spare_parts_so_po_ajax"
      get "view_hp_po_sales_spare_parts_ajax"

      patch "update_estimation_part_customer_approval"
      patch "update_estimation_external_customer_approval"

      put "update_part_order"
      put "update_onloan_part_order"
      put "update_estimate_job"
      put "update_low_margin_estimate"
      put "update_delivery_unit"
      put "update_edit_serial"

      post "update_return_store_part"
      post "update_estimate_the_part_internal"
      post "update_low_margin_estimate_parts_approval"
    end
  end

  resources :invoices do
    collection do
      get "edit_quotation_ajax"
      get "edit_invoice_ajax"
      get "paginate_estimations"


      post "update_invoice_advance_payment"
      post "update_quality_control"
      post "update_estimate_job_final"
      post "update_customer_feedback"
      post "update_quotation"
      post "update_invoice"
      post "update_terminate_invoice"
      post "update_terminate_foc_approval"
      post "update_inform_customer"
    end

  end

end
