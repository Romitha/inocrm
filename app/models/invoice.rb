class Invoice < ActiveRecord::Base
	belongs_to :customer, class_name: "User"#, foreign_key: "customer_id"
end

class TerminateInvoice < ActiveRecord::Base
	self.table_name = "spt_act_terminate_issue_invoice"

	belongs_to :user_ticket_action, foreign_key: :ticket_action_id
	belongs_to :ticket_payment_received, foreign_key: :payment_received_id
end
