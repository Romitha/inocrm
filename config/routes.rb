Rails.application.routes.draw do

  root "todos#index"

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
      get "remove_relation"
      post "option_for_vat_number"
      patch "demote_as_department"
      delete "remove_department_org"
    end
    concerns :attachable
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
      post "customer_summary"
      post "comment_methods"
      post "reply_ticket"

      post "find_by_serial"

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
      post "create_product_country"
      post "finalize_ticket_save"

      post "q_and_answer_save"

      post "join_tickets"
      post "update_assign_ticket"
      post "update_pop_approval"
      post "call_resolution_template"
      post "call_mf_order_template"
      post "call_alert_template"

      # post "order_manufacture_parts_edit_serial_no"
      # post "update_order_mfp_hold"
      post "update_order_mfp_part_order"
      post "update_order_mfp_wrrnty_extnd_rqst"
      post "update_order_mfp_return_manufacture_part"
      post "update_order_mfp_termnt_prt_order"
      post "update_approve_store_parts"
      post "update_deliver_bundle"
      post "update_bundle_return_part"
      # post "update_order_mfp_edit_serial_no"
      post "update_edit_serial"
      post "update_close_event"

      post "update_received_and_issued"
      # get "close_event"
      post "extend_warranty_update_reject_extend_warranty"
      post "update_return_manufacture_part"
      post "hold_unhold"
      post "update_estimation_part"
      post "update_return_store_part"
      post "update_ticket_close_approval"
      post "update_collect_parts"

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
      get "add_edit_contract"
      get "inform_customer_in_modal"
      get "master_data"

      get "alert"

      get "ajax_show"
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

  resources :admins do
    concerns :attachable
    collection do
      get "total-tickets", :action => :total_tickets
      get "today-open-tickets", :action => :today_open_tickets
      get "today-closed-tickets", :action => :today_closed_tickets
      get "open-tickets", :action => :open_tickets
      get "closed-tickets", :action => :closed_tickets
      get "total-products", :action => :total_products
      get "reason"
      post "update_reason"
      get "organizations"
      get "employees"
      get "accessories"
      post "update_accessories"
      get "country"
      post "update_country"
      get "additional_charge"
      post "update_additional_charge"
      get "customer_feedback"
      post "update_customer_feedback"
      get "general_question"
      post "update_general_question"
      get "payment_item"
      post "update_payment_item"
      get "payment_item"
      post "update_payment_item"
      get "sbu"
      post "sbu_update"
      get "regional_support_center"
      post "update_regional_support_center"
      get "spare_part_description"
      post "update_spare_part_description"
      get "ticket_start_action"
      post "update_ticket_start_action"
      get "sla"
      post "update_sla"
      get "title"
      post "update_title"

      get "inventory_location"
      get "inventory_product"
      get "inventory_category"
      get "inventory_product_condition"
      get "inventory_disposal_method"
      get "inventory_reason"
      get "inventory_manufacture"
      get "inventory_unit"
      post "update_inventory_location"
      post "update_inventory_product"
      post "update_inventory_category"
      post "update_inventory_product_condition"
      post "update_inventory_disposal_method"
      post "update_inventory_reason"
      post "update_inventory_manufacture"
      post "update_inventory_unit"
      put "inventory_location_update"
      put "inventory_category_update"


      get "pop_status"
      post "update_pop_status"
      get "about-us", :action => :about_us
      match "tickets/brands_and_categories", to: "admins#brands_and_categories", via: [:get, :post]
      match "tickets/problem_category", to: "admins#problem_category", via: [:get, :post]
      match "tickets/q_and_a", to: "admins#q_and_a", via: [:get, :post]
      # namespace "/tickets" do
      #   get 'q_and_a', :action => :ticket_q_and_a
      # end

      put "inline_update"
      put "inline_update_product_info"
      put "inline_update_product_condition"
      put "inline_update_disposal_method"
      put "inline_update_inventory_reason"
      put "inline_update_inventory_location_rack"
      put "inline_update_inventory_location_shelf"
      put "inline_update_inventory_location_bin"
      put "inline_update_inventory_brand"
      put "inline_update_inventory_product"
      put "inline_update_inventory_category"
      get "delete_location_rack"
      get "delete_location_shelf"
      get "delete_location_bin"
      get "delete_inventory_brand"
      get "delete_inventory_product"
      get "delete_inventory_category"
      get "delete_inventory_product_form"
      
    end
  end

  resources :inventories, except: [:index, :show, :create, :new, :update, :destroy, :edit] do
    collection do
      get "inventory_in_modal"
      get "search_inventories"
      get "load_serial_and_part"
      get "load_estimation"
      get "load_estimation_ticket_info"
      get "toggle_add_update_return_part"
      # get "inventory_location"
      # get "inventory_product"
      # get "inventory_category"
      # get "inventory_product_condition"
      # get "inventory_disposal_method"
      # get "inventory_reason"
      # get "inventory_manufacture"
      # get "inventory_unit"
      get "inventory_master_data"
      get "hp_po"
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
      
      # post "update_inventory_product"
      # post "update_inventory_category"
      # post "update_inventory_product_condition"
      # post "update_inventory_disposal_method"
      # post "update_inventory_reason"
      # post "update_inventory_manufacture"
      # post "update_inventory_unit"

      # post "update_inventory_location"
      post "update_issue_store_parts"

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
      post "update_inform_customer"
    end
  end
     
  # get 'auth/index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:


  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
