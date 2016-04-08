class AddSptTicketInvoiceTotalTax < ActiveRecord::Migration
  def change
    create_table :spt_ticket_invoice_total_tax, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"

      t.column :invoice_id, "INT UNSIGNED NOT NULL"
      t.column :tax_id, "INT UNSIGNED NOT NULL"
      t.decimal :amount, scale: 2, precision: 10, default: 0, null: false
      t.index :invoice_id, name: "fk_spt_ticket_invoice_total_tax_spt_ticket_invoice1_idx"
      t.index :tax_id, name: "fk_spt_ticket_invoice_total_tax_mst_tax1_idx"
    end
  
    add_column :spt_ticket_invoice, :total_cost, :decimal, default: 0, null: false, scale: 2, precision: 10
    add_column :spt_ticket, :final_invoice_id, "INT UNSIGNED NULL"
    add_index :spt_ticket, :final_invoice_id, name: "fk_spt_ticket_spt_ticket_invoice1_idx"

    add_foreign_key :spt_ticket_invoice_total_tax, :spt_ticket_invoice, column: :invoice_id, name: "fk_spt_ticket_invoice_total_tax_spt_ticket_invoice1"
    add_foreign_key :spt_ticket_invoice_total_tax, :mst_tax, column: :tax_id, name: "fk_spt_ticket_invoice_total_tax_mst_tax1"
    add_foreign_key :spt_ticket, :spt_ticket_invoice, column: :final_invoice_id, name: "fk_spt_ticket_spt_ticket_invoice1"
  end
end