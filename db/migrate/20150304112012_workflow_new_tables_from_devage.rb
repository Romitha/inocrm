class WorkflowNewTablesFromDevage < ActiveRecord::Migration
  def change
    create_table :workflow_alert_roles, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :alert_id, "INT UNSIGNED"
      t.column :role_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :workflow_alert_users, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :alert_id, "INT UNSIGNED"
      t.column :user_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :workflow_alerts, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.datetime :created_at
      t.string :heading
      t.string :alert
      t.boolean :read
      t.integer :priority
      t.string :process_id
      t.string :task_id
      t.timestamps
    end

    create_table :workflow_mappings, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :process_id
      t.string :task_id
      t.string :url
      t.string :screen
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
      t.integer :inv_category_level
      t.integer :sup_sla_time
      t.decimal :sup_external_job_profit_margin
      t.decimal :sup_internal_part_profit_margin
      t.integer :sup_last_ticket_no
      t.timestamps
    end
  end
end
