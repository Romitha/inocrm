class AddSupLastInvoiceNoToCompanyConfig < ActiveRecord::Migration
  def change
    add_column :company_config, :sup_last_invoice_no, "INT UNSIGNED NULL DEFAULT 0"
    add_column :company_config, :sup_last_receipt_no, "INT UNSIGNED NULL DEFAULT 0"
    add_column :spt_ticket_payment_received, :receipt_no, "INT UNSIGNED NULL DEFAULT 0"
    add_column :spt_ticket_payment_received, :payment_type, "INT UNSIGNED NULL DEFAULT 0"
    add_column :spt_ticket_payment_received, :payment_note, :text
    add_column :spt_ticket_payment_received, :receipt_description, :text
    add_column :spt_ticket_payment_received, :receipt_print_count, "INT UNSIGNED NULL DEFAULT 0"
    add_column :mst_spt_templates, :receipt, :text
    add_column :mst_spt_templates, :receipt_request_type, :string, default: "PRINT_SPPT_RECEIPT" # value is PRINT_SPPT_INVOICE

  end
end