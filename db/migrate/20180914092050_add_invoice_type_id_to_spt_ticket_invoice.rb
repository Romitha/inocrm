class AddInvoiceTypeIdToSptTicketInvoice < ActiveRecord::Migration
  def change
  	add_column :spt_ticket_invoice, :invoice_type_id,  "INT UNSIGNED NULL"

  	add_index :spt_ticket_invoice, :invoice_type_id, name: "ind_spt_ticket_invoice_invoice_type_id"
    add_foreign_key :spt_ticket_invoice, :mst_spt_invoice_type, name: "fk_spt_ticket_invoice_invoice_type_id", column: :invoice_type_id

  end
end
