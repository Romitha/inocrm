class AddInvLastGinNoToCompanyConfig < ActiveRecord::Migration
  def change
  	add_column :company_config, :inv_last_po_no, :integer, null: false, default: 0
  end
end
