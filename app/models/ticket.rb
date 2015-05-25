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

  belongs_to :contact_person1, foreign_key: :contact_person1_id
  belongs_to :contact_person2, foreign_key: :contact_person2_id
  belongs_to :report_person, foreign_key: :reporter_id

  has_many :ticket_product_serial, foreign_key: :ticket_id
  has_many :products, through: :ticket_product_serial

  has_many :q_and_answers, foreign_key: :ticket_id
  has_many :q_and_as, through: :q_and_answers
  accepts_nested_attributes_for :q_and_answers, allow_destroy: true

  has_many :ge_q_and_answers
  accepts_nested_attributes_for :ge_q_and_answers, allow_destroy: true

  has_many :ticket_accessories, foreign_key: :ticket_id
  has_many :accessories, through: :ticket_accessories
  accepts_nested_attributes_for :ticket_accessories, allow_destroy: true

  belongs_to :customer, class_name: "Customer", foreign_key: "customer_id"
  belongs_to :sla_time, foreign_key: :sla_id

  has_many :dyna_columns, as: :resourceable

  has_many :joint_tickets
  accepts_nested_attributes_for :joint_tickets, allow_destroy: true

  has_one :user_ticket_action, foreign_key: :action_id

  validates_presence_of [:ticket_no, :priority, :status_id, :problem_description, :informed_method_id, :job_type_id, :ticket_type_id, :warranty_type_id, :base_currency_id, :problem_category_id]

  validates_numericality_of [:ticket_no, :priority]

  [:initiated_by, :initiated_by_id].each do |dyna_method|
    define_method(dyna_method) do
      dyna_columns.find_by_data_key(dyna_method).try(:data_value)
    end

    define_method("#{dyna_method}=") do |value|
      data = dyna_columns.find_or_initialize_by(data_key: dyna_method)
      data.data_value = (value.class==Fixnum ? value : value.strip)
    end
  end

  before_create :update_ticket_no

  def update_ticket_no
    self.ticket_no = (self.class.order("created_at desc").first.ticket_no.to_i+1)
  end

end

class TicketType < ActiveRecord::Base
  self.table_name = "mst_spt_ticket_type"

  has_many :tickets, foreign_key: :ticket_type_id

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

  has_many :q_and_as, foreign_key: :problem_category_id
  accepts_nested_attributes_for :q_and_as, allow_destroy: true

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
end

class TicketAccessory < ActiveRecord::Base
  self.table_name = "spt_ticket_accessory"

  belongs_to :accessory
  belongs_to :ticket
end

class JointTicket < ActiveRecord::Base
  self.table_name = "spt_joint_ticket"

  belongs_to :ticket
end