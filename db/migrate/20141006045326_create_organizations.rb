class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
    	t.string :name, :null =>false
    	t.string :short_name, :null =>false
      t.integer :state
      t.integer :status
      t.string :vat_number
      t.integer :vat_parent, :default => "0", :null =>false
    	t.string :web_site
    	t.integer :created_by
      t.integer :updated_by
      t.datetime :deleted_at
      t.integer :deleted_by
      # t.text :logo
    	t.string :code, :null =>false
      t.integer :account_id
      t.timestamps
    end
  end
end
