class AddMoreColumns < ActiveRecord::Migration
  def change
  	add_column :mst_spt_customer_contact_type, :fixedline, :boolean, null: false, default: false
  end
end
