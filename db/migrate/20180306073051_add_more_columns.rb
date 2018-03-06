class AddMoreColumns < ActiveRecord::Migration
  def change
  	add_column :mst_spt_customer_contact_type, :fixedline, :boolean
  end
end
