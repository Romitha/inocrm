class Invoice < ActiveRecord::Base
  self.table_name = "spt_invoice"

  has_many :ticket_payment_receiveds
  has_many :tickets, through: :ticket_payment_receiveds

  has_many :invoice_items
end

class TerminateInvoice < ActiveRecord::Base
  self.table_name = "spt_act_terminate_issue_invoice"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id
  belongs_to :ticket_payment_received, foreign_key: :payment_received_id
end

class InvoiceItem < ActiveRecord::Base
  self.table_name = "spt_invoice_item"

  belongs_to :invoice
  belongs_to :ticket_payment_received, foreign_key: :payment_received_id
end
