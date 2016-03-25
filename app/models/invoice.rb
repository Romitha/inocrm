class Invoice < ActiveRecord::Base
  self.table_name = "spt_invoice"

  has_many :ticket_payment_receiveds
  has_many :tickets, through: :ticket_payment_receiveds

  has_many :invoice_items
  has_many :act_print_invoices
end

class TicketInvoice < ActiveRecord::Base
  self.table_name = "spt_ticket_invoice"

  belongs_to :payment_term
  belongs_to :ticket
  belongs_to :currency

  has_many :ticket_invoice_estimations
  has_many :ticket_invoice_terminates, foreign_key: :invoice_id
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
  self.table_name = "spt_ticket_customer_quotation"

  belongs_to :ticket
  belongs_to :payment_term
  belongs_to :currency

  has_many :ticket_payment_receiveds
  accepts_nested_attributes_for :ticket_payment_receiveds, allow_destroy: true

  has_many :customer_quotation_estimations
  has_many :ticket_estimations, through: :customer_quotation_estimations
  has_many :act_quotations

end

class CustomerQuotationEstimation < ActiveRecord::Base
  self.table_name = "spt_ticket_customer_quotation_estimation"

  belongs_to :customer_quotation
  belongs_to :ticket_estimation, foreign_key: :estimation_id

  has_many :ticket_payment_receiveds
  accepts_nested_attributes_for :ticket_payment_receiveds, allow_destroy: true

end

class PaymentTerm < ActiveRecord::Base
  self.table_name = "mst_spt_payment_term"

  has_many :ticket_invoices
  has_many :customer_quotations

end

class TicketInvoiceEstimation < ActiveRecord::Base
  self.table_name = "spt_ticket_invoice_estimation"

  belongs_to :ticket_invoice, foreign_key: :invoice_id

  belongs_to :ticket_estimation, foreign_key: :estimation_id
end

class TicketInvoiceTerminate < ActiveRecord::Base
  self.table_name = "spt_ticket_invoice_terminate"

  belongs_to :act_terminate_job_payment, foreign_key: :terminate_job_payment_id
  belongs_to :ticket_invoice, foreign_key: :invoice_id
end