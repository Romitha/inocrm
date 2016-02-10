class AddSupLastInvoiceNoToCompanyConfig < ActiveRecord::Migration
  def change
    add_column :company_config, :sup_last_invoice_no, :integer, default: 0
  end
end
