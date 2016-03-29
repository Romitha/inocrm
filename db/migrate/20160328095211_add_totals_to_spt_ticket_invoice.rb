class AddTotalsToSptTicketInvoice < ActiveRecord::Migration
  def change
    add_column :spt_ticket_invoice, :total_amount, :decimal, scale: 2, precision: 10, null: false, default: 0
    add_column :spt_ticket_invoice, :total_advance_recieved, :decimal, scale: 2, precision: 10, null: false, default: 0
    add_column :spt_ticket_invoice, :total_deduction, :decimal, scale: 2, precision: 10, null: false, default: 0
    add_column :spt_ticket_invoice, :net_total_amount, :decimal, scale: 2, precision: 10, null: false, default: 0
  end
end
