class InvNewTablesFromDevage < ActiveRecord::Migration
  def change

    create_table :inv_batch_warranty, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :batch_id, "int(10) UNSIGNED NOT NULL"
      t.column :warranty_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :inv_damage, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :store_id, "int(10) UNSIGNED NOT NULL"
      t.column :product_id, "int(10) UNSIGNED NOT NULL"
      t.column :grn_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :grn_batch_id, "int(10) UNSIGNED"
      t.column :grn_serial_item_id, "int(10) UNSIGNED"
      t.boolean :spare_part, null: false, default: false
      t.column :serial_part_id, "int(10) UNSIGNED"
      t.decimal :quantity, null: false, precision: 13, scale: 3
      t.decimal :unit_cost, null: false, precision: 13, scale: 2
      t.column :currency_id, "int(10) UNSIGNED NOT NULL"
      t.column :srr_item_id, "int(10) UNSIGNED"
      t.column :product_condition_id, "int(10) UNSIGNED"
      t.text :remarks
      t.column :damage_reason_id, "int(10) UNSIGNED NOT NULL"
      t.column :damage_request_id, "int(10) UNSIGNED"
      t.column :damage_request_source_id, "int(10) UNSIGNED"
      t.decimal :repair_quantity, null: false, precision: 13, scale: 3
      t.decimal :spare_quantity, null: false, precision: 13, scale: 3
      t.decimal :disposal_quantity, null: false, precision: 13, scale: 3
      t.decimal :disposed_quantity, null: false, precision: 13, scale: 3, default: 0.000
      t.column :disposal_method_id, "int(10) UNSIGNED"
      t.column :created_by, "int(10) UNSIGNED"
      t.datetime :created_at, null: false
    end

    create_table :inv_damage_request, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :store_id, "int(10) UNSIGNED NOT NULL"
      t.column :product_id, "int(10) UNSIGNED NOT NULL"
      t.text :remarks
      t.column :damage_reason_id, "int(10) UNSIGNED NOT NULL"
      t.boolean :approved1
      t.boolean :approved2
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.column :approved1_by, "int(10) UNSIGNED"
      t.column :approved2_by, "int(10) UNSIGNED"
      t.datetime :approved1_at
      t.datetime :approved2_at
      t.string :status, limit:2, null: false, default: "st"
      t.datetime :created_at, null: false
    end
    
    create_table :inv_damage_request_source, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :damage_request_id, "int(10) UNSIGNED NOT NULL"
      t.column :grn_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :grn_batch_id, "int(10) UNSIGNED"
      t.column :grn_serial_item_id, "int(10) UNSIGNED"
      t.decimal :requested_quantity, null: false, precision: 13, scale: 3
      t.decimal :approved1_quantity, precision: 13, scale: 3
      t.decimal :approved2_quantity, precision: 13, scale: 3
      t.decimal :unit_cost, null: false, precision: 13, scale: 2
      t.column :currency_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :approved1_repair_quantity, precision: 13, scale: 3
      t.decimal :approved1_spare_quantity, precision: 13, scale: 3
      t.decimal :approved1_disposal_quantity, precision: 13, scale: 3
      t.decimal :approved2_repair_quantity, precision: 13, scale: 3
      t.decimal :approved2_spare_quantity, precision: 13, scale: 3
      t.decimal :approved2_disposal_quantity, precision: 13, scale: 3
      t.column :approved1_disposal_method_id, "int(10) UNSIGNED"
      t.column :approved2_disposal_method_id, "int(10) UNSIGNED"
      t.timestamps
    end

    create_table :inv_disposal, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :store_id, "int(10) UNSIGNED NOT NULL"
      t.column :product_id, "int(10) UNSIGNED NOT NULL"
      t.column :disposal_request_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :disposed_quantity, null: false, precision: 13, scale: 3
      t.text :remarks
      t.column :disposal_method_id, "int(10) UNSIGNED NOT NULL"
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.datetime :inspected_at
      t.column :inspected_by, "int(10) UNSIGNED"
      t.datetime :created_at, null: false
    end

    create_table :inv_disposal_request, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :store_id, "int(10) UNSIGNED NOT NULL"
      t.column :product_id, "int(10) UNSIGNED NOT NULL"
      t.column :disposal_reason_id, "int(10) UNSIGNED NOT NULL"
      t.text :remarks
      t.boolean :approved, null: false, default: false
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.column :approved_by, "int(10) UNSIGNED"
      t.datetime :approved_at
      t.string :status, limit:2, null: false, default: "st"
      t.column :requested_disposal_method_id, "int(10) UNSIGNED NOT NULL"
      t.column :approved_disposal_method_id, "int(10) UNSIGNED"
      t.datetime :created_at, null: false
    end

    create_table :inv_disposal_request_source, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :disposal_request_id, "int(10) UNSIGNED NOT NULL"
      t.column :damage_id, "int(10) UNSIGNED"
      t.column :grn_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :grn_batch_id, "int(10) UNSIGNED"
      t.column :grn_serial_item_id, "int(10) UNSIGNED"
      t.decimal :requested_quantity, null: false, precision: 13, scale: 3
      t.decimal :approved_quantity, precision: 13, scale: 3
      t.decimal :balance_disposal_quantity, precision: 13, scale: 3
      t.timestamps
    end

    create_table :inv_disposal_source, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :disposal_id, "int(10) UNSIGNED NOT NULL"
      t.column :damage_id, "int(10) UNSIGNED"
      t.column :grn_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :grn_batch_id, "int(10) UNSIGNED"
      t.column :grn_serial_item_id, "int(10) UNSIGNED"
      t.decimal :quantity, null: false, precision: 13, scale: 3
      t.timestamps
    end

    create_table :inv_gin, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :store_id, "int(10) UNSIGNED NOT NULL"
      t.column :srn_id, "int(10) UNSIGNED NOT NULL"
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.text :remarks
      t.datetime :created_at, null: false
    end

    create_table :inv_gin_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :product_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :issued_quantity, null: false, precision: 13, scale: 3
      t.column :gin_id, "int(10) UNSIGNED NOT NULL"
      t.column :srn_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :product_condition_id, "int(10) UNSIGNED NOT NULL"
      t.text :remarks
      t.decimal :average_cost, precision: 13, scale: 2
      t.decimal :standard_cost, precision: 13, scale: 2
      t.column :currency_id, "int(10) UNSIGNED"
      t.decimal :returned_quantity, null: false, precision: 13, scale: 3
      t.boolean :returnable, null: false, default: false
      t.boolean :return_completed, null: false, default: false
      t.boolean :spare_part, null: false, default: false
      t.timestamps
    end

    create_table :inv_gin_source, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :gin_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :grn_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :grn_batch_id, "int(10) UNSIGNED"
      t.column :grn_serial_item_id, "int(10) UNSIGNED"
      t.column :serial_part_id, "int(10) UNSIGNED"
      t.decimal :issued_quantity, null: false, precision: 13, scale: 3
      t.decimal :unit_cost, precision: 13, scale: 2
      t.decimal :returned_quantity, null: false, precision: 13, scale: 3
      t.timestamps
    end

    create_table :inv_grn, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :store_id, "int(10) UNSIGNED NOT NULL"
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.string :grn_no
      t.text :remarks
      t.column :srn_id, "int(10) UNSIGNED"
      t.column :po_id, "int(10) UNSIGNED"
      t.datetime :created_at, null: false
    end

    create_table :inv_grn_batch, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :grn_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :inventory_batch_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :recieved_quantity, null: false, precision: 13, scale: 3
      t.decimal :remaining_quantity, null: false, precision: 13, scale: 3
      t.decimal :reserved_quantity, null: false, precision: 13, scale: 3, default: 0.000
      t.decimal :damage_quantity, null: false, precision: 13, scale: 3, default: 0.000
      t.timestamps
    end

    create_table :inv_grn_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :grn_id, "int(10) UNSIGNED NOT NULL"
      t.column :srn_item_id, "int(10) UNSIGNED"
      t.column :product_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :recieved_quantity, null: false, precision: 13, scale: 3
      t.decimal :remaining_quantity, null: false, precision: 13, scale: 3
      t.decimal :reserved_quantity, null: false, precision: 13, scale: 3, default: 0.000
      t.decimal :damage_quantity, null: false, precision: 13, scale: 3, default: 0.000
      t.text :remarks
      t.decimal :unit_cost, null: false, precision: 13, scale: 2
      t.decimal :current_unit_cost, null: false, precision: 13, scale: 2
      t.column :currency_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :average_cost, precision: 13, scale: 2
      t.decimal :standard_cost, precision: 13, scale: 2
      t.column :po_item_id, "int(10) UNSIGNED"
      t.decimal :po_unit_quantity, precision: 13, scale: 3
      t.decimal :po_unit_cost, precision: 13, scale: 2
      t.timestamps
    end

    create_table :inv_grn_item_current_unit_cost_history, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :grn_item_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :current_unit_cost, null: false, precision: 13, scale: 2
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :inv_grn_serial_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :grn_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :serial_item_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :inv_inventory, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :store_id, "int(10) UNSIGNED NOT NULL"
      t.column :product_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :stock_quantity, null: false, precision: 13, scale: 3
      t.decimal :available_quantity, null: false, precision: 13, scale: 3
      t.decimal :reserved_quantity, null: false, precision: 13, scale: 3, default: 0.000
      t.decimal :reorder_level, precision: 13, scale: 3
      t.decimal :reorder_quantity, precision: 13, scale: 3
      t.decimal :max_quantity, precision: 13, scale: 3
      t.decimal :safty_stock_quantity, precision: 13, scale: 3
      t.integer :lead_time_in_days
      t.integer :reorder_period_in_days
      t.column :bin_id, "int(10) UNSIGNED"
      t.text :remarks
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.datetime :updatd_at
      t.column :updated_by, "int(10) UNSIGNED"
      t.datetime :created_at, null: false
    end

    create_table :inv_inventory_batch, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :inventory_id, "int(10) UNSIGNED NOT NULL"
      t.column :product_id, "int(10) UNSIGNED NOT NULL"
      t.string :lot_no
      t.string :batch_no
      t.text :remarks
      t.datetime :manufatured_date
      t.datetime :expiry_date
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.datetime :created_at, null: false
    end

    create_table :inv_inventory_serial_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :inventory_id, "int(10) UNSIGNED NOT NULL"
      t.column :product_id, "int(10) UNSIGNED NOT NULL"
      t.column :batch_id, "int(10) UNSIGNED NOT NULL"
      t.string :serial_no, null: false
      t.text :remarks
      t.column :product_condition_id, "int(10) UNSIGNED NOT NULL"
      t.boolean :scavenge, null: false, default: false
      t.boolean :parts_not_completed, null: false, default: false
      t.boolean :damage, null: false, default: false
      t.boolean :used, null: false, default: false
      t.boolean :repaired, null: false, default: false
      t.boolean :reserved, null: false, default: false
      t.boolean :disposed, null: false, default: false
      t.column :inv_status_id, "int(10) UNSIGNED NOT NULL"
      t.string :ct_no
      t.datetime :manufatured_date
      t.datetime :expiry_date
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.datetime :updated_at
      t.column :updated_by, "int(10) UNSIGNED"
      t.datetime :created_at, null: false
    end


    create_table :inv_inventory_serial_part, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :serial_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :product_id, "int(10) UNSIGNED NOT NULL"
      t.string :serial_no, null: false
      t.text :remarks
      t.column :product_condition_id, "int(10) UNSIGNED NOT NULL"
      t.boolean :scavenge, null: false, default: false
      t.boolean :parts_not_completed, null: false, default: false
      t.boolean :damage, null: false, default: false
      t.boolean :used, null: false, default: false
      t.boolean :repaired, null: false, default: false
      t.boolean :reserved, null: false, default: false
      t.boolean :disposed, null: false, default: false
      t.column :inv_status_id, "int(10) UNSIGNED NOT NULL"
      t.string :ct_no
      t.datetime :manufatured_date
      t.datetime :expiry_date
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.datetime :updated_at
      t.column :updated_by, "int(10) UNSIGNED"
      t.datetime :created_at, null: false
    end

    create_table :inv_prn, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :store_id, "int(10) UNSIGNED NOT NULL"
      t.datetime :required_at
      t.string :prn_no
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.text :remarks
      t.boolean :closed, null: false, default: false
      t.datetime :created_at, null: false
    end

    create_table :inv_prn_grn_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :prn_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :grn_item_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :grn_quantity, null: false, precision: 13, scale: 3
      t.timestamps
    end

    create_table :inv_prn_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :prn_id, "int(10) UNSIGNED NOT NULL"
      t.column :product_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :quantity, null: false, precision: 13, scale: 3
      t.text :remarks
      t.boolean :closed, null: false, default: false
      t.timestamps
    end

    create_table :inv_sbn, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :store_id, "int(10) UNSIGNED NOT NULL"
      t.column :requested_location_id, "int(10) UNSIGNED"
      t.datetime :required_at
      t.text :remarks
      t.string :sbn_no
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.boolean :closed, null: false, default: false
      t.datetime :created_at, null: false
    end

    create_table :inv_sbn_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :sbn_id, "int(10) UNSIGNED NOT NULL"
      t.column :product_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :quantity, null: false, precision: 13, scale: 3
      t.text :remarks
      t.decimal :balance_quantity, null: false, precision: 13, scale: 3
      t.boolean :closed, null: false, default: false
      t.timestamps
    end

    create_table :inv_sbn_item_source, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :sbn_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :grn_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :grn_batch_id, "int(10) UNSIGNED"
      t.column :grn_serial_item_id, "int(10) UNSIGNED"
      t.column :serial_part_id, "int(10) UNSIGNED"
      t.decimal :quantity, null: false, precision: 13, scale: 3
      t.decimal :unit_cost, null: false, precision: 13, scale: 2
      t.column :currency_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :balance_quantity, null: false, precision: 13, scale: 3
      t.boolean :reserve_terminated, null: false, default: false
      t.datetime :reserve_terminated_at
      t.column :reserve_terminated_by, "int(10) UNSIGNED"
      t.timestamps
    end

    create_table :inv_serial_additional_cost, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :serial_item_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :cost, null: false, precision: 13, scale: 2
      t.column :currency_id, "int(10) UNSIGNED NOT NULL"
      t.text :note
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.datetime :created_at, null: false
    end

    create_table :inv_serial_part_additional_cost, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :serial_part_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :cost, null: false, precision: 13, scale: 2
      t.column :currency_id, "int(10) UNSIGNED NOT NULL"
      t.text :note
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.datetime :created_at, null: false
    end

    create_table :inv_serial_part_warranty, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :serial_part_id, "int(10) UNSIGNED NOT NULL"
      t.column :warranty_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :inv_serial_warranty, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :serial_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :warranty_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :inv_srn, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :store_id, "int(10) UNSIGNED NOT NULL"
      t.column :requested_location_id, "int(10) UNSIGNED"
      t.datetime :required_at
      t.text :remarks
      t.string :srn_no
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.column :requested_module_id, "int(10) UNSIGNED NOT NULL"
      t.boolean :closed, null: false, default: false
      t.datetime :created_at, null: false
    end

    create_table :inv_srn_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :srn_id, "int(10) UNSIGNED NOT NULL"
      t.column :product_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :quantity, null: false, precision: 13, scale: 3
      t.text :remarks
      t.boolean :returnable, null: false, default: false
      t.boolean :return_completed
      t.boolean :issue_terminated, null: false, default: false
      t.datetime :issue_terminated_at
      t.column :issue_terminated_reason_id, "int(10) UNSIGNED"
      t.column :issue_terminated_by, "int(10) UNSIGNED"
      t.boolean :spare_part, null: false, default: false
      t.boolean :closed, null: false, default: false
      t.timestamps
    end

    create_table :inv_srn_sbn_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.decimal :srn_quantity, null: false, precision: 13, scale: 3
      t.column :srn_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :sbn_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :sbn_item_source_id, "int(10) UNSIGNED"
      t.timestamps
    end

    create_table :inv_srr, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :store_id, "int(10) UNSIGNED NOT NULL"
      t.column :requested_location_id, "int(10) UNSIGNED"
      t.text :remarks
      t.string :srr_no
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.boolean :closed, null: false, default: false
      t.column :requested_module_id, "int(10) UNSIGNED NOT NULL"
      t.datetime :created_at, null: false
    end

    create_table :inv_srr_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :srr_id, "int(10) UNSIGNED NOT NULL"
      t.column :product_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :quantity, null: false, precision: 13, scale: 3
      t.column :product_condition_id, "int(10) UNSIGNED NOT NULL"
      t.column :return_reason_id, "int(10) UNSIGNED NOT NULL"
      t.column :returnable_srn_item_id, "int(10) UNSIGNED"
      t.boolean :spare_part, null: false, default: false
      t.text :remarks
      t.boolean :closed, null: false, default: false
      t.timestamps
    end

    create_table :inv_srr_item_source, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :srr_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :gin_source_id, "int(10) UNSIGNED NOT NULL"
      t.decimal :returned_quantity, null: false, precision: 13, scale: 3
      t.decimal :unit_cost, null: false, precision: 13, scale: 2
      t.column :currency_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :inv_stock_taking, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :store_id, "int(10) UNSIGNED NOT NULL"
      t.string :order_by, limit:2, null: false, default: "IC"
      t.text :remarks
      t.string :status, limit:2, null: false, default: "ST"
      t.boolean :cancel, null: false, default: false
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.datetime :stock_taken_at
      t.column :stock_taken_by, "int(10) UNSIGNED"
      t.string :attached_document_url
      t.column :store_keeper_by, "int(10) UNSIGNED"
      t.column :inspected1_by, "int(10) UNSIGNED"
      t.column :inspected2_by, "int(10) UNSIGNED"
      t.column :inspected3_by, "int(10) UNSIGNED"
      t.column :inspected4_by, "int(10) UNSIGNED"
      t.datetime :reconciled_at
      t.integer :variance_count
      t.datetime :created_at, null: false
    end

    create_table :inv_stock_taking_grn_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :stock_taking_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :grn_item_id, "int(10) UNSIGNED NOT NULL"
      t.column :grn_batch_id, "int(10) UNSIGNED"
      t.column :grn_serial_item_id, "int(10) UNSIGNED"
      t.decimal :sys_remaining_qnt, null: false, precision: 13, scale: 3
      t.decimal :phys_remaining_qnt, precision: 13, scale: 3
      t.decimal :sys_not_issue_cond_qnt, precision: 13, scale: 3
      t.decimal :phy_not_issue_cond_qnt, precision: 13, scale: 3
      t.text :remarks
      t.text :variance_reason
      t.decimal :req_remaining_qnt, precision: 13, scale: 3
      t.decimal :req_not_issue_cond_qnt, precision: 13, scale: 3
      t.decimal :appr_remaining_qnt, precision: 13, scale: 3
      t.decimal :appr_not_issue_cond_qnt, precision: 13, scale: 3
      t.timestamps
    end

    create_table :inv_stock_taking_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :stock_taking_id, "int(10) UNSIGNED NOT NULL"
      t.column :product_id, "int(10) UNSIGNED NOT NULL"
      t.boolean :active_item, null: false, default: true
      t.decimal :sys_stock_quantity, null: false, precision: 13, scale: 3
      t.decimal :sys_disposal_stock_qnt, null: false, precision: 13, scale: 3
      t.decimal :phys_stock_qnt, precision: 13, scale: 3
      t.decimal :physl_disposal_stock_qnt, precision: 13, scale: 3
      t.boolean :print_with_grn, null: false, default: false
      t.integer :print_order_no
      t.text :remarks
      t.timestamps
    end

    create_table :inv_warranty, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.datetime :start_at
      t.datetime :end_at
      t.integer :period_part
      t.integer :period_labour
      t.integer :period_onsight
      t.column :warranty_type_id, "int(10) UNSIGNED NOT NULL"
      t.text :remarks
      t.column :created_by, "int(10) UNSIGNED NOT NULL"
      t.datetime :created_at, null: false
    end
  end
end
