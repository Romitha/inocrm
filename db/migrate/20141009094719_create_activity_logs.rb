class CreateActivityLogs < ActiveRecord::Migration
  def change
    create_table :activity_logs, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :user
      t.string :role
      t.string :browser
      t.string :os
      t.string :ip_address
      t.string :event
      t.string :reference_url
      #t.references :reference
      t.column :reference_id, "int(10) UNSIGNED"
      #t.string :reference_type
      t.timestamps
    end
  end
end
