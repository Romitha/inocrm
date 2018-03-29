class Invoice < ActiveRecord::Base
  self.table_name = "spt_invoice"

  has_many :ticket_payment_receiveds
  has_many :tickets, through: :ticket_payment_receiveds

  has_many :invoice_items
  accepts_nested_attributes_for :invoice_items, allow_destroy: true
  has_many :act_print_invoices

  has_one :so_po

  validates_presence_of [:created_by, :currency_id, :invoice_no, :created_at]
end

class TicketInvoice < ActiveRecord::Base
  self.table_name = "spt_ticket_invoice"

  belongs_to :payment_term
  belongs_to :ticket
  belongs_to :currency
  belongs_to :created_by_ch_eng, class_name: "User", foreign_key: :created_by
  belongs_to :organization,-> { where(refers: "CRM_OWNER") }, foreign_key: :print_organization_id
  belongs_to :organization_bank_detail, foreign_key: :print_bank_detail_id
  belongs_to :print_currency, class_name: "Currency"

  has_many :ticket_invoice_estimations, foreign_key: :invoice_id
  has_many :ticket_estimations, through: :ticket_invoice_estimations

  has_many :ticket_invoice_terminates, foreign_key: :invoice_id
  has_many :act_terminate_job_payments, through: :ticket_invoice_terminates

  has_many :ticket_invoice_advance_payments, foreign_key: :invoice_id
  has_many :ticket_payment_receiveds, through: :ticket_invoice_advance_payments

  has_many :ticket_invoice_total_taxes, foreign_key: :invoice_id
  accepts_nested_attributes_for :ticket_invoice_total_taxes, allow_destroy: true
  has_many :taxes,through: :ticket_invoice_total_taxes

  def currency_type
    currency.code
  end

  before_save do |ticket_invoice|
   if ticket_invoice.persisted? and ticket_invoice.remark_changed? and ticket_invoice.remark.present?
      ticket_invoice_remark = "#{ticket_invoice.remark} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{User.cached_find_by_id(ticket_invoice.current_user_id).try(:full_name)}</span><br/>#{ticket_invoice.remark_was}"
    elsif ticket_invoice.new_record?
      ticket_invoice_remark = "#{ticket_invoice.remark} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{User.cached_find_by_id(ticket_invoice.current_user_id).try(:full_name)}</span>"
    else
      ticket_invoice_remark = ticket_invoice.remark_was
    end
    ticket_invoice.remark = ticket_invoice_remark
  end

  has_many :dyna_columns, as: :resourceable, autosave: true

  # has_many :invoices, foreign_key: "customer_id"

  [:current_user_id].each do |dyna_method|
    define_method(dyna_method) do
      dyna_columns.find_by_data_key(dyna_method).try(:data_value)
    end

    define_method("#{dyna_method}=") do |value|
      data = dyna_columns.find_or_initialize_by(data_key: dyna_method)
      data.data_value = (value.class==Fixnum ? value : value.strip)
      data.save
    end
  end

end

class TicketInvoiceAdvancePayment < ActiveRecord::Base
  self.table_name = "spt_ticket_invoice_advance_payment"

  belongs_to :ticket_invoice, foreign_key: :invoice_id
  belongs_to :ticket_payment_received, foreign_key: :payment_received_id
end

class TicketInvoiceEstimation < ActiveRecord::Base
  self.table_name = "spt_ticket_invoice_estimation"

  belongs_to :ticket_invoice, foreign_key: :invoice_id

  belongs_to :ticket_estimation, foreign_key: :estimation_id
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

  belongs_to :dispatch_method

  # validates_presence_of :feedback

end

class DispatchMethod < ActiveRecord::Base
  self.table_name = "mst_spt_dispatch_method"

  has_many :customer_feedbacks

  def is_used_anywhere?
    customer_feedbacks.any?
  end

end

class CustomerQuotation < ActiveRecord::Base
  self.table_name = "spt_ticket_customer_quotation"

  belongs_to :ticket
  belongs_to :payment_term
  belongs_to :currency
  belongs_to :organization, foreign_key: :print_organization_id
  belongs_to :organization_bank_detail, foreign_key: :print_bank_detail_id
  belongs_to :print_currency, class_name: "Currency"

  has_many :ticket_payment_receiveds
  accepts_nested_attributes_for :ticket_payment_receiveds, allow_destroy: true

  has_many :customer_quotation_estimations
  has_many :ticket_estimations, through: :customer_quotation_estimations
  has_many :act_quotations

  before_save do |customer_quotation|
   if customer_quotation.persisted? and customer_quotation.remark_changed? and customer_quotation.remark.present?
      customer_quotation_remark = "#{customer_quotation.remark} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{User.cached_find_by_id(customer_quotation.current_user_id).try(:full_name)}</span><br/>#{customer_quotation.remark_was}"
    elsif customer_quotation.new_record?
      customer_quotation_remark = "#{customer_quotation.remark} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{User.cached_find_by_id(customer_quotation.current_user_id).try(:full_name)}</span>"
    else
      customer_quotation_remark = customer_quotation.remark_was
    end
    customer_quotation.remark = customer_quotation_remark
  end

  has_many :dyna_columns, as: :resourceable, autosave: true

  # has_many :invoices, foreign_key: "customer_id"

  [:current_user_id].each do |dyna_method|
    define_method(dyna_method) do
      dyna_columns.find_by_data_key(dyna_method).try(:data_value)
    end

    define_method("#{dyna_method}=") do |value|
      data = dyna_columns.find_or_initialize_by(data_key: dyna_method)
      data.data_value = (value.class==Fixnum ? value : value.strip)
      data.save
    end
  end

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

  def is_used_anywhere?
    ticket_invoices.any? or customer_quotations.any?
  end

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

class ContractPaymentReceived < ActiveRecord::Base
  self.table_name = "spt_contract_payment_received"
  belongs_to :ticket_contract, foreign_key: :contract_id
end