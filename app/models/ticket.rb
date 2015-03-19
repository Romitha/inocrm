class Ticket < ActiveRecord::Base

  self.table_name = "spt_ticket"

  belongs_to :ticket_type, foreign_key: :ticket_type_id
  belongs_to :warranty_type, foreign_key: :warranty_type_id
  belongs_to :job_type, foreign_key: :job_type_id
  belongs_to :inform_method, foreign_key: :informed_method_id
  belongs_to :problem_category, foreign_key: :problem_category_id
  belongs_to :ticket_contact_type, foreign_key: :contact_type_id
  belongs_to :ticket_contract, foreign_key: :contract_id
  belongs_to :ticket_status, foreign_key: :status_id
  belongs_to :ticket_currency, foreign_key: :base_currency_id
  belongs_to :customer, foreign_key: :customer_id

  has_many :ticket_product_serial, foreign_key: :product_serial_id
  has_many :products, through: :ticket_product_serial

  # belongs_to :organization
  # belongs_to :department
  belongs_to :customer, class_name: "Customer", foreign_key: "customer_id"

  has_many :agent_ticket_infos
  has_many :agents, through: :agent_ticket_infos

  has_many :document_attachments, as: :attachable
  accepts_nested_attributes_for :document_attachments, allow_destroy: true

  has_many :comments

  validates_presence_of [:due_date_time, :customer, :initiated_through, :ticket_type, :customer, :initiated_through, :ticket_type, :status, :subject, :department, :agents, :priority, :description,]

  has_many :dyna_columns, as: :resourceable

  validates_presence_of [:ticket_no, :pop_updated_ticket, :contract_available, :created_at, :created_by, :priority, :sla_time, :status_id, :status_resolve_id, :status_hold, :problem_category_id, :informed_method_id, :job_type_id, :ticket_type_id, :regional_support_job, :repair_type_id, :warranty_type_id, :cus_chargeable, :customer_id, :contact_person1_id, :job_finished, :job_closed, :re_open_count, :ticket_close_approval_required, :ticket_close_approval_requested, :ticket_close_approved, :qc_passed, :re_assigned, :terminated, :cus_payment_required, :cus_payment_completed, :pop_updated, :base_currency_id, :manufacture_currency_id, :cus_recieved_note_print_count, :cus_returned_note_print_count]

  validates_numericality_of [:open_time_duration, :cus_returned_note_print_count, :open_time_duration_sla, :cus_recieved_note_print_count, :ticket_no, :priority, :sla_time, :inform_cp, :re_open_count]

  [:initiated_by, :initiated_by_id].each do |dyna_method|
    define_method(dyna_method) do
      dyna_columns.find_by_data_key(dyna_method).try(:data_value)
    end

    define_method("#{dyna_method}=") do |value|
      data = dyna_columns.find_or_initialize_by(data_key: dyna_method)
      data.data_value = (value.class==Fixnum ? value : value.strip)
    end
  end

  def assigned
    assigned_ticket = agent_ticket_infos.find_by_visibility("assigned")
    assigned_ticket && assigned_ticket.agent
  end

  after_create :set_assignee

  def  set_assignee
    agent_ticket_infos.first.update_attribute :visibility, "assigned"
  end
end

class TicketType < ActiveRecord::Base
  self.table_name = "mst_spt_ticket_type"

  has_many :tickets, foreign_key: :ticket_type_id

  validates_presence_of [:code, :name]
end

class WarrantyType < ActiveRecord::Base
  self.table_name = "mst_spt_warranty_type"

  has_many :tickets, foreign_key: :warranty_type_id

  validates_presence_of [:code, :name]
end

class JobType < ActiveRecord::Base
  self.table_name = "mst_spt_job_type"

  has_many :tickets, foreign_key: :job_type_id

  validates_presence_of [:code, :name]
end

class InformMethod < ActiveRecord::Base
  self.table_name = "mst_spt_ticket_informed_method"

  has_many :tickets, foreign_key: :informed_method_id

  validates_presence_of [:code, :name]
end

class ProblemCategory < ActiveRecord::Base
  self.table_name = "spt_problem_category"

  has_many :tickets, foreign_key: :problem_category_id

  validates_presence_of [:name]
end

class TicketContactType < ActiveRecord::Base
  self.table_name = "mst_spt_contact_type"

  has_many :tickets, foreign_key: :contact_type_id

  validates_presence_of [:code, :name]
end

class TicketContract < ActiveRecord::Base
  self.table_name = "spt_contract"

  has_many :tickets, foreign_key: :contract_id

  validates_presence_of [:customer_id, :sla, :active, :created_at, :created_by]

  validates_numericality_of [:sla]
end

class TicketStatus < ActiveRecord::Base
  self.table_name = "mst_spt_ticket_status"

  has_many :tickets, foreign_key: :status_id

  validates_presence_of [:code, :name]
end

class TicketCurrency < ActiveRecord::Base
  self.table_name = "mst_currency"

  has_many :tickets, foreign_key: :base_currency_id

  validates_presence_of [:currency, :code, :symbol, :base_currency]
end

class TicketProductSerial < ActiveRecord::Base
  self.table_name = "spt_ticket_product_serial"

  belongs_to :ticket, foreign_key: :ticket_id
  belongs_to :product, foreign_key: :product_serial_id

  validates_presence_of [:ticket_id, :product_serial_id]
end

