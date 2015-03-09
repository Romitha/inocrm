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
      t.string :alert
      t.boolean :read
      t.integer :priority
      t.timestamps
    end

    create_table :instant_message, id: false do |t|
      t.column :msgid, "NOT NULL AUTO_INCREMENT, PRIMARY KEY (msgid)"
      t.integer :DeviceGroupId
      t.string :Image_url
      t.string :Text_msg                                  #text not string
      t.integer :Repeat_count
      t.integer :Msg_status
      t.datetime :show_time
      t.timestamps
    end

    create_table :company_config, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :category1_caption
      t.string :category1_caption
      t.string :category1_caption
      t.integer :category_level
      t.integer :suport_sla_time
      t.decimal :external_job_profit_margin
      t.decimal :internal_part_profit_margin
      t.timestamps
    end
  end
end
