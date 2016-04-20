class WorkflowNewTablesFromDevage < ActiveRecord::Migration
  def change
    create_table :workflow_alert_roles, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :alert_id, "int(10) UNSIGNED NOT NULL"
      t.string :bpm_role_code, null: false
      t.timestamps
    end

    create_table :workflow_alert_users, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :alert_id, "int(10) UNSIGNED NOT NULL"
      t.column :user_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end

    create_table :workflow_alerts, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :heading, null: false
      t.text :alert, null: false
      t.boolean :read, null: false, default: false
      t.integer :priority, null: false, default: 1
      t.string :process_id, null: false
      t.string :task_id, null: false
      t.timestamps
    end

    create_table :workflow_mappings, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :process_name, null: false
      t.string :task_name, null: false
      t.string :url, null: false
      t.string :screen
      t.string :first_header_title, null: false
      t.string :second_header_title_name
      t.string :input_variables
      t.string :output_variables
      # t.column :alert_id, "INT UNSIGNED"
      # t.column :user_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :instant_message, id: false do |t|
      t.column :msgid, "INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (msgid)"
      t.integer :DeviceGroupId
      t.string :Image_url
      t.string :Text_msg                                  #250
      t.integer :Repeat_count
      t.integer :Msg_status
      t.datetime :show_time
      t.timestamps
    end

    create_table :company_config, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      # t.string :category1_caption
      # t.string :category1_caption
      # t.string :category1_caption
      # t.integer :category_level
      # t.integer :suport_sla_time
      # t.decimal :external_job_profit_margin
      # t.decimal :internal_part_profit_margin
      t.column :sup_sla_id, "int(10) UNSIGNED NULL"
      t.integer :inv_category_level, default: 3, null: false
      #t.integer :sup_sla_time, null: false
      t.decimal :sup_external_job_profit_margin, null: false, precision: 5, scale: 2, default: 0.000
      t.decimal :sup_internal_part_profit_margin, null: false, precision: 5, scale: 2, default: 0.000
      t.integer :sup_last_ticket_no, null: false, default: 0
      t.timestamps
    end

    create_table :workflow_header_titles, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :process_id, "INT UNSIGNED NOT NULL DEFAULT 0"
      t.string :h1, default: 0
      t.string :h2, default: 0
      t.string :h3, default: 0
      t.string :h4, default: 0
      t.string :h5, default: 0
      t.string :h6, default: 0
      t.string :h7, default: 0
      t.string :h8, default: 0
      t.string :h9, default: 0
      t.string :h10, default: 0
      t.timestamps
    end
  end
end