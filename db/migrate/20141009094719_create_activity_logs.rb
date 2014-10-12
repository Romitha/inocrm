class CreateActivityLogs < ActiveRecord::Migration
  def change
    create_table :activity_logs do |t|
      t.string :user
      t.string :role
      t.string :browser
      t.string :os
      t.string :ip_address
      t.string :event
      t.string :reference_url
      t.references :reference
      t.timestamps
    end
  end
end
