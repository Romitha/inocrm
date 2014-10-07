class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
    	t.string :name
    	t.string :short_name
    	t.string :website
    	t.string :vat_number
    	t.string :refers
      t.timestamps
    end
  end
end
