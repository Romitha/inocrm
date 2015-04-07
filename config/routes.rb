Rails.application.routes.draw do


  resources :invoices

  root "organizations#index"

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

      post "create_product_brand"
      post "create_new_category"
      post "create_new_product"
      post "create_product"
      post "create_customer"
      post "select_sla"
      post "create_sla"

      post "create_contact_persons"
      post "create_contact_person_record"
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
