class WorkflowNewTablesFromDevage < ActiveRecord::Migration
  def change
  	 create_table :workflow_alert_roles, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :alert_id, "INT UNSIGNED"
      t.column :role_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :workflow_alert_roles, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :alert_id, "INT UNSIGNED"
      t.column :user_id, "INT UNSIGNED"
      t.timestamps
    end

    create_table :workflow_alert_roles, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :alert
      t.integer :read
      t.integer :priority
      t.timestamps
    end
  end
end
