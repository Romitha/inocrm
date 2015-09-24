Rails.application.routes.draw do

  root "todos#index"

  resources :warranties do
    collection do
      post "select_for_warranty"
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

      get "new_product_brand"
      get "new_product_category"
      get "new_product"
      get "new_customer"
      get "contact_persons"
      get "remarks"
      get "paginate_ticket_histories"

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

      get "edit-ticket", :action => :edit_ticket
      get "pop-approval"#, :action => :pop_note

      get "resolution"
      get "order_mf"
      get "receive_and_issued"
      get "return_to_stores"
      get "assign-ticket", action: :assign_ticket
      get "estimate_job"
      get "deliver_unit"
      get "low_margin_estimate"
      get "workflow_diagram"
      get "suggesstion_data"

      get "create_parts_bundle"
      get "return_parts_bundle"
      get "close_event"

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
      get "organizations"
      get "employees"
      get "accessories"
      get "about-us", :action => :about_us
      match "tickets/brands_and_categories", to: "admins#brands_and_categories", via: [:get, :post]
      match "tickets/problem_category", to: "admins#problem_category", via: [:get, :post]
      match "tickets/q_and_a", to: "admins#q_and_a", via: [:get, :post]
      # namespace "/tickets" do
      #   get 'q_and_a', :action => :ticket_q_and_a
      # end
    end
  end

  resources :inventories, except: [:index, :show, :create, :new, :update, :destroy, :edit] do
    collection do
      get "inventory_in_modal"
      get "search_inventories"
      put "update_part_order"
      put "update_onloan_part_order"
      get "load_estimation"
      patch "update_estimation_part_customer_approval"
      patch "update_estimation_external_customer_approval"

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
