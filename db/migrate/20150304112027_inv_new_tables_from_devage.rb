class InvNewTablesFromDevage < ActiveRecord::Migration
  def change
    create_table :inv_inventory_serial_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      # t.column :product_id, "INT UNSIGNED"
      # t.integer :batch_id
      # t.string :serial_no
      # t.string :remarks
      # t.integer :product_condition_id
      # t.integer :batch_serial_info_id
      # t.boolean :scavenge
      # t.boolean :parts_compleated
      # t.boolean :issuable_condition
      # t.boolean :used
      # t.boolean :repaired
      # t.decimal :additional_cost
      t.timestamps
    end
    
    create_table :inv_srn, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      # t.column :store_id, "INT UNSIGNED"
      # t.column :request_location_id, "INT UNSIGNED"
      # t.datetime :requested_date
      # t.datetime :requierd_date
      # t.string :remarks
      # t.string :srn_no
      # t.column :store_id, "INT UNSIGNED"
      # t.boolean :closed
      t.timestamps
    end

    create_table :inv_srn_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      # t.column :srn_id, "INT UNSIGNED"
      # t.column :product_id, "INT UNSIGNED"
      # t.decimal :quantity
      # t.string :remarks
      # t.boolean :returnable
      # t.boolean :return_compleated
      # t.boolean :issue_terminated
      # t.datetime :issue_terminated_date
      # t.column :issue_terminated_reason_id, "INT UNSIGNED"
      # t.column :issue_terminated_user_id, "INT UNSIGNED"
      # t.boolean :spare_part
      # t.boolean :closed
      t.timestamps
    end
    
    create_table :inv_srr, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      # t.column :store_id, "INT UNSIGNED"
      # t.column :request_location_id, "INT UNSIGNED"
      # t.datetime :requested_date
      # t.string :remarks
      # t.string :srr_no
      # t.column :user_groups_id, "INT UNSIGNED"
      # t.boolean :closed
      t.timestamps
    end

    create_table :inv_srr_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      # t.column :srr_id, "INT UNSIGNED"
      # t.column :product_id, "INT UNSIGNED"
      # t.decimal :quantity
      # t.integer :product_condition_id
      # t.column :return_reason_id, "INT UNSIGNED"
      # t.column :returnable_srn_item_id, "INT UNSIGNED"
      # t.boolean :spare_part
      # t.string :remarks
      # t.boolean :closed
      t.timestamps
    end
  end
end
