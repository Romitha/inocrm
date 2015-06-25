class AddMstTablesFromDevage < ActiveRecord::Migration
  def change
    create_table :mst_country, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :Country, null: false
      t.string :code, null: false
      t.timestamps
    end
    create_table :mst_currency, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :currency, null: false
      t.string :code, null: false
      t.string :symbol, null: false
      t.boolean :base_currency, null: false, default:false
      t.timestamps
    end
    create_table :mst_inv_product, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :category3_id, "INT UNSIGNED NOT NULL"
      t.decimal :serial_no, null: false, precision: 6, scale: 2
      t.integer :serial_no_order, null: false
      t.string :sku
      t.string :legacy_code
      t.text :description                    #varbinary
      t.string :model_no
      t.string :product_no
      t.column :unit_id, "INT UNSIGNED NOT NULL"
      t.boolean :fifo, null:false, default:true
      t.boolean :active, null:false, default:true
      t.boolean :spare_part, null:false, default:false
      t.string :spare_part_no
      t.column :created_by, "INT UNSIGNED NOT NULL"
      t.column :updated_by, "INT UNSIGNED"
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :mst_inv_reason, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :reason, null:false
      t.boolean :srn_issue_terminate, null:false, default:false
      t.boolean :damage,  null:false, default:false
      t.boolean :srr,  null:false, default:false
      t.boolean :disposal,  null:false, default:false
      t.column :created_by, "INT UNSIGNED NOT NULL"
      t.column :updated_by, "INT UNSIGNED"
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :mst_organizations_types, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, null:false
      t.string :name, null:false
      t.timestamps
    end

    create_table :mst_spt_accessory, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :accessory, null:false
      t.timestamps
    end

    create_table :mst_spt_action, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.integer :action_no, null:false
      t.string :action_description, null:false                        #250
      t.string :task_id
      t.column :groups_id,"INT UNSIGNED"
      t.boolean :hide, null:false, default:false
      t.timestamps
    end

    create_table :mst_spt_additional_charge, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :additional_charge, null:false
      t.decimal :default_cost_price, precision: 10, scale: 2
      t.decimal :default_estimated_price, precision: 10, scale: 2
      t.timestamps
    end

    create_table :mst_spt_contact_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 2, null:false
      t.string :name, null:false
      t.timestamps
    end

    create_table :mst_spt_customer_contact_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name, null:false
      t.boolean :mobile, null:false, default:false
      t.boolean :email, null:false, default:false
      t.timestamps
    end

    create_table :mst_spt_customer_feedback, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :feedback, null:false   #250
      t.timestamps
    end

    create_table :mst_spt_estimation_status, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 3, null:false
      t.string :name, null:false
      t.timestamps
    end

    create_table :mst_spt_general_question, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :question, null:false         
      t.string :answer_type, limit: 2, null:false, default:"YN"
      t.boolean :active, null:false, default:true
      t.column :action_id, "INT UNSIGNED NOT NULL"
      t.boolean :compulsory, null:false, default:false
      t.timestamps
    end

    create_table :mst_spt_job_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 2, null:false
      t.string :name, null:false
      t.timestamps
    end

    create_table :mst_spt_payment_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name, null:false
      t.decimal :default_amount, precision: 10, scale: 2
      t.timestamps
    end

    create_table :mst_spt_payment_received_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 2, null:false
      t.string :name, null:false
      t.timestamps
    end

    create_table :mst_spt_pop_status, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 3, null:false
      t.string :name, null:false
      t.timestamps
    end

    create_table :mst_spt_problematic_question, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :problem_category_id, "INT UNSIGNED NOT NULL"
      t.text :question, null:false        
      t.string :answer_type, limit: 2, null:false, default:"YN"
      t.boolean :active, null:false, default:true
      t.column :action_id, "INT UNSIGNED NOT NULL"
      t.boolean :compulsory, null:false, default:false
      t.timestamps
    end

    create_table :mst_spt_product_brand, id: false do |t|     
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name, null:false
      t.column :sla_id, "INT UNSIGNED NOT NULL"
      t.column :organization_id, "INT UNSIGNED"
      t.integer :parts_return_days, null:false, default:7
      t.string :warranty_date_format
      t.column :currency_id, "INT UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :mst_spt_product_category, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :product_brand_id, "INT UNSIGNED NOT NULL"           
      t.string :name, null:false
      t.column :sla_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :mst_spt_reason, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :reason, null:false
      t.boolean :hold, null:false, default:false
      t.boolean :sla_pause, null:false, default:false
      t.boolean :re_assign_request, null:false, default:false
      t.boolean :terminate_job, null:false, default:false
      t.boolean :terminate_spare_part, null:false, default:false
      t.boolean :warranty_extend, null:false, default:false
      t.boolean :spare_part_unused, null:false, default:false
      t.boolean :reject_returned_part, null:false, default:false
      t.boolean :reject_close, null:false, default:false
      t.boolean :adjust_terminate_job_payment, null:false, default:false
      t.timestamps
    end

    create_table :mst_spt_sbu, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :sbu, null:false                        #250
      t.timestamps
    end

    create_table :mst_spt_sbu_engineer, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :sbu_id, "INT UNSIGNED NOT NULL"
      t.column :engineer_id, "INT UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :mst_spt_spare_part_description, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :description, null:false                #250
      t.timestamps
    end

    create_table :mst_spt_spare_part_status_action, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 3, null:false
      t.string :name, null:false
      t.integer :manufacture_type_index, null:false, default:0 
      t.integer :store_nc_type_index, null:false, default:0 
      t.integer :store_ch_type_index, null:false, default:0 
      t.integer :on_loan_type_index, null:false, default:0              
      t.timestamps
    end

    create_table :mst_spt_spare_part_status_use, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 3, null:false
      t.string :name, null:false
      t.timestamps
    end

    create_table :mst_spt_templates, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :invoice
      t.string :invoice_request_type
      t.text :ticket
      t.string :ticket_request_type
      t.text :ticket_complete
      t.string :ticket_complete_request_type
      t.text :fsr
      t.string :fsr_request_type
      t.timestamps
    end

    create_table :mst_spt_ticket_informed_method, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 2, null:false
      t.string :name, null:false
      t.timestamps
    end

    create_table :mst_spt_ticket_repair_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 2, null:false
      t.string :name, null:false
      t.timestamps
    end

    create_table :mst_spt_ticket_start_action, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :action, null:false                      #250
      t.boolean :active, null:false, default:true
      t.timestamps
    end

    create_table :mst_spt_ticket_status, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 3, null:false
      t.string :name, null:false
      t.string :colour
      t.timestamps
    end

    create_table :mst_spt_ticket_status_resolve, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 3, null:false
      t.string :name, null:false
      t.timestamps
    end

    create_table :mst_spt_ticket_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 2, null:false
      t.string :name, null:false
      t.timestamps
    end

    create_table :mst_spt_warranty_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, limit: 2, null:false
      t.string :name, null:false
      t.timestamps
    end

    create_table :mst_title, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :title
      t.timestamps
    end

    create_table :mst_bpm_role, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :module_id, "int(10) UNSIGNED NOT NULL DEFAULT 0 "
      t.string :code, default: 0, null: false
      t.string :name, default: 0, null: false
      t.timestamps
    end

    create_table :mst_district, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name, null: false
      t.timestamps
    end

    create_table :mst_inv_bin, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :description, null: false
      t.column :shelf_id, "INT UNSIGNED NOT NULL"
      t.column :created_by, "INT UNSIGNED NOT NULL"
      t.column :updated_by, "INT UNSIGNED"
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :mst_inv_category1, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, null: false
      t.string :name, null: false
      t.column :created_by, "INT UNSIGNED NOT NULL"
      t.column :updated_by, "INT UNSIGNED"
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :mst_inv_category2, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :category1_id, "INT UNSIGNED NOT NULL"
      t.string :code
      t.string :name
      t.column :created_by, "INT UNSIGNED NOT NULL"
      t.column :updated_by, "INT UNSIGNED"
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :mst_inv_category3, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :category2_id, "INT UNSIGNED NOT NULL"
      t.string :code
      t.string :name
      t.column :created_by, "INT UNSIGNED NOT NULL"
      t.column :updated_by, "INT UNSIGNED"
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :mst_inv_category_caption, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.integer :level, default: 1, null: false
      t.string :caption, null: false
      t.timestamps
    end

    create_table :mst_inv_disposal_method, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :disposal_method, null: false
      t.column :created_by, "INT UNSIGNED NOT NULL"
      t.column :updated_by, "INT UNSIGNED"
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :mst_inv_manufacture, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :manufacture, null:false
      t.column :created_by, "INT UNSIGNED NOT NULL"
      t.column :updated_by, "INT UNSIGNED"
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :mst_inv_product_condition, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :condition, null:false
      t.column :created_by, "INT UNSIGNED"
      t.column :updated_by, "INT UNSIGNED"
      t.timestamps
    end

    create_table :mst_inv_rack, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :description, null:false
      t.column :location_id, "INT UNSIGNED NOT NULL"
      t.string :aisle_image
      t.column :created_by, "INT UNSIGNED"
      t.column :updated_by, "INT UNSIGNED"
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :mst_inv_product_info, id: false do |t|
      t.column :product_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (product_id)"
      t.string :picture
      t.string :abc_class, limit:1
      t.boolean :issue_fractional_allowed, null:false, default:false
      t.column :secondary_unit_id, "INT UNSIGNED"
      t.decimal :secondery_unit_convertion, precision: 13, scale: 6
      t.boolean :per_secondery_unit_conversion
      t.column :country_id, "INT UNSIGNED"
      t.column :manufacture_id, "INT UNSIGNED"
      t.boolean :need_serial
      t.decimal :average_cost, precision: 13, scale: 2
      t.decimal :standard_cost, precision: 13, scale: 2
      t.column :currency_id, "INT UNSIGNED"
      t.text :remarks
      t.timestamps
    end

    create_table :mst_inv_serial_item_status, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, null:false
      t.string :name, null:false
      t.timestamps
    end

    create_table :mst_inv_shelf, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :description, null:false
      t.column :rack_id, "INT UNSIGNED NOT NULL"
      t.column :created_by, "INT UNSIGNED NOT NULL"
      t.column :updated_by, "INT UNSIGNED"
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :mst_inv_unit, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :description, null:false
      t.string :unit
      t.column :base_unit_id, "INT UNSIGNED"
      t.decimal :base_unit_conversion, precision: 13, scale: 6
      t.boolean :per_base_unit
      t.column :created_by, "INT UNSIGNED"
      t.column :updated_by, "INT UNSIGNED"
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

    create_table :mst_inv_warranty_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, null:false
      t.string :name, null:false
      t.timestamps
    end

    create_table :mst_module, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, null:false
      t.string :name, null:false
      t.timestamps
    end

    create_table :mst_spt_extra_remark, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.text :extra_remark, null:false
      t.timestamps
    end

    create_table :mst_spt_sla, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :description, null:false
      t.decimal :sla_time, null:false, precision: 8, scale: 2, default:0.00
      t.column :created_by, "INT UNSIGNED NOT NULL"
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end

  end
end