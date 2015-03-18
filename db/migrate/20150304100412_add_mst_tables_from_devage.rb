class AddMstTablesFromDevage < ActiveRecord::Migration
  def change
    create_table :mst_country, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :Country
      t.string :code
      t.timestamps
    end

    create_table :mst_currency, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :currency
      t.string :code
      t.string :symbol
      t.boolean :base_currency
      t.timestamps
    end

    create_table :mst_inv_product, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      # t.column :cat1_mast_id, "INT UNSIGNED"
      # t.column :cat2_mast_id, "INT UNSIGNED"
      # t.column :cat3_mast_id, "INT UNSIGNED"
      # t.decimal :serial_no
      # t.integer :serial_no_order
      # t.string :legacy_code
      # t.text :description                       #varbinary
      # t.string :model_no
      # t.string :product_no
      # t.integer :unit_id
      # t.boolean :FIFO
      # t.boolean :active
      # t.boolean :spare_part
      # t.string :spare_part_no
      t.timestamps
    end

    create_table :mst_inv_reason, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      # t.string :reason
      t.timestamps
    end

    create_table :mst_organizations_types, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code
      t.string :name                               #text not string
      t.timestamps
    end

    create_table :mst_spt_accessory, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :accessory
      t.timestamps
    end

    create_table :mst_spt_action, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.integer :action_no
      t.string :action_description                        #250
      t.string :task_id
      t.column :groups_id, "INT UNSIGNED"
      t.boolean :hide
      t.timestamps
    end

    create_table :mst_spt_additional_charge, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :additional_charge
      t.decimal :default_cost_price
      t.decimal :default_estimated_price
      t.timestamps
    end

    create_table :mst_spt_contact_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 2
      t.string :name
      t.timestamps
    end

    create_table :mst_spt_customer_contact_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      t.boolean :mobile     
      t.boolean :email      
      t.timestamps
    end

    create_table :mst_spt_customer_feedback, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :feedback   #250
      t.timestamps
    end

    create_table :mst_spt_estimation_status, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 3
      t.string :name
      t.timestamps
    end

    create_table :mst_spt_general_question, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :question          
      t.string :code, limit: 2
      t.boolean :active
      t.column :action_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :mst_spt_job_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 2
      t.string :name
      t.timestamps
    end

    create_table :mst_spt_payment_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      t.decimal :default_amount
      t.timestamps
    end

    create_table :mst_spt_payment_received_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 2
      t.string :name
      t.timestamps
    end

    create_table :mst_spt_pop_status, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 3
      t.string :name
      t.timestamps
    end

    create_table :mst_spt_problematic_question, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :problem_category_id, "INT UNSIGNED"
      t.text :question         
      t.string :answer_type, limit: 2
      t.boolean :active
      t.column :action_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :mst_spt_product_brand, id: false do |t|     
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      t.integer :sla_time
      t.column :organization_id, "INT UNSIGNED"
      t.integer :parts_return_days
      t.string :warenty_date_formate
      t.column :currency_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :mst_spt_product_category, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :product_brand_id, "INT UNSIGNED"             
      t.string :name
      t.integer :sla_time
      t.timestamps
    end

    create_table :mst_spt_reason, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :reason         
      t.boolean :hold
      t.boolean :sla_pause
      t.boolean :re_asign_request
      t.boolean :terminate_job
      t.boolean :terminate_spare_part
      t.boolean :warenty_extended
      t.boolean :spare_part_unused
      t.boolean :reject_returned_part
      t.boolean :reject_close
      t.boolean :adjust_terminate_job_payment
      t.timestamps
    end

    create_table :mst_spt_sbu, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :sbu                         #250
      t.timestamps
    end

    create_table :mst_spt_sbu_engineer, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :sbu_id, "INT UNSIGNED"
      t.column :engineer_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :mst_spt_spare_part_description, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :description                 #250
      t.timestamps
    end

    create_table :mst_spt_spare_part_status_action, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 3
      t.string :name
      t.integer :manufacture_type_index
      t.integer :store_nc_type_index
      t.integer :store_ch_type_index
      t.integer :on_loan_type_index               
      t.timestamps
    end

    create_table :mst_spt_spare_part_status_use, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 3
      t.string :name
      t.timestamps
    end

    create_table :mst_spt_templates, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :invoice
      t.text :cus_received_note
      t.text :cus_return_note
      t.text :fsr
      t.timestamps
    end

    create_table :mst_spt_ticket_informed_method, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 2
      t.string :name
      t.timestamps
    end

    create_table :mst_spt_ticket_repair_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 2
      t.string :name
      t.timestamps
    end

    create_table :mst_spt_ticket_start_action, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :action                      #250
      t.boolean :active
      t.timestamps
    end

    create_table :mst_spt_ticket_status, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 3
      t.string :name
      t.timestamps
    end

    create_table :mst_spt_ticket_status_resolve, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 3
      t.string :name
      t.timestamps
    end

    create_table :mst_spt_ticket_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 2
      t.string :name
      t.timestamps
    end

    create_table :mst_spt_warranty_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 2
      t.string :name
      t.timestamps
    end

    create_table :mst_title, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :title
      t.timestamps
    end
  end
end
