class Tax < ActiveRecord::Base
  self.table_name = "mst_tax"

  has_many :ticket_estimation_additional_taxes
  has_many :ticket_estimation_external_taxes
  has_many :ticket_estimation_part_taxes
  has_many :tax_rates

  has_many :ticket_invoice_total_taxes, foreign_key: :tax_id
  accepts_nested_attributes_for :ticket_invoice_total_taxes, allow_destroy: true
  has_many :ticket_invoices, through: :ticket_invoice_total_taxes

end

class TaxRate < ActiveRecord::Base
  self.table_name = "mst_tax_rate"
  belongs_to :tax, foreign_key: :tax_id

  # has_many :ticket_estimation_additional_taxes
  # has_many :ticket_estimation_external_taxes
  # has_many :ticket_estimation_part_taxes

end

class TicketEstimationAdditionalTax < ActiveRecord::Base
  self.table_name = "spt_ticket_estimation_additional_tax"

  belongs_to :ticket_estimation_additional
  belongs_to :tax
end

class TicketEstimationExternalTax <ActiveRecord::Base
  self.table_name = "spt_ticket_estimation_external_tax"

  belongs_to :ticket_estimation_external
  belongs_to :tax
end

class TicketEstimationPartTax <ActiveRecord::Base
  self.table_name = "spt_ticket_estimation_part_tax"

  belongs_to :ticket_estimation_part
  belongs_to :tax

end

class TicketInvoiceTotalTax < ActiveRecord::Base
	self.table_name = "spt_ticket_invoice_total_tax"

	belongs_to :ticket_invoice, foreign_key: :invoice_id
	belongs_to :tax, foreign_key: :tax_id
end