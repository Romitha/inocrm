class AddSptTicketInvoiceTerminate < ActiveRecord::Migration
  def change
  	create_table :spt_ticket_invoice_terminate, id: false do |t|
  		t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"

  		t.column :invoice_id, "INT UNSIGNED NOT NULL"
  		t.column :terminate_job_payment_id, "INT UNSIGNED NOT NULL"
  	end

  	add_column :spt_act_terminate_job_payment, :invoiced, :integer, null: false, default: 0

  	add_index :spt_ticket_invoice_terminate, :terminate_job_payment_id, name: "fk_spt_ticket_invoice_terminate_spt_act_terminate_job_payme_idx"
  	add_index :spt_ticket_invoice_terminate, :invoice_id, name: "fk_spt_ticket_invoice_terminate_spt_ticket_invoice1_idx"

    add_foreign_key :spt_ticket_invoice_terminate, :spt_act_terminate_job_payment, column: :terminate_job_payment_id, name: :fk_spt_ticket_invoice_terminate_spt_act_terminate_job_payment1, primary_key: :ticket_action_id
    add_foreign_key :spt_ticket_invoice_terminate, :spt_ticket_invoice, column: :invoice_id, name: :fk_spt_ticket_invoice_terminate_spt_ticket_invoice1

  end
end
