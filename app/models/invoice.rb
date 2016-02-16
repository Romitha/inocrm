class Invoice < ActiveRecord::Base
  self.table_name = "spt_invoice"

  has_many :ticket_payment_receiveds
  has_many :tickets, through: :ticket_payment_receiveds

  has_many :invoice_items
end

class TicketInvoice < ActiveRecord::Base
  self.table_name = "spt_ticket_invoice"

  belongs_to :payment_term

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

class CustomerFeedback < ActiveRecord::Base
  self.table_name = "spt_act_customer_feedback"

  belongs_to :feedback

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  belongs_to :ticket_payment_received, foreign_key: :payment_received_id

end

class CustomerQuotation < ActiveRecord::Base
  self.table_name = "spt_ticket_customet_quotation"

  belongs_to :ticket
  belongs_to :payment_term
  belongs_to :currency

end

class PaymentTerm < ActiveRecord::Base
  self.table_name = "mst_spt_payment_term"

  has_many :ticket_invoices
  has_many :customer_quotations

end
