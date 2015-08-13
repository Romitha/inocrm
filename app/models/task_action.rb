class TaskAction < ActiveRecord::Base
  self.table_name = "mst_spt_action"

  has_many :q_and_as, foreign_key: :action_id

  has_many :ge_q_and_as, foreign_key: :action_id

  has_many :user_ticket_actions, foreign_key: :action_id
end

class UserTicketAction < ActiveRecord::Base
  self.table_name = "spt_ticket_action"

  has_many :q_and_answers, foreign_key: :ticket_action_id

  has_many :ge_q_and_answers, foreign_key: :ticket_action_id

  belongs_to :ticket
  belongs_to :task_action, foreign_key: :action_id

  has_many :user_assign_ticket_actions, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :user_assign_ticket_actions, allow_destroy: true

  has_many :assign_regional_support_centers, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :assign_regional_support_centers, allow_destroy: true

  has_one :hp_case, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :hp_case, allow_destroy: true

  has_one :action_warranty_repair_type, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :action_warranty_repair_type, allow_destroy: true

  has_one :ticket_re_assign_request, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :ticket_re_assign_request, allow_destroy: true

  has_one :ticket_action_taken, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :ticket_action_taken, allow_destroy: true

  has_one :ticket_finish_job, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :ticket_finish_job, allow_destroy: true

  has_one :ticket_terminate_job, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :ticket_terminate_job, allow_destroy: true

  has_many :ticket_terminate_job_payments, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :ticket_terminate_job_payments, allow_destroy: true

  has_one :act_hold, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :act_hold, allow_destroy: true

  has_one :act_fsr, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :act_fsr, allow_destroy: true

  has_one :serial_request, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :serial_request, allow_destroy: true

  has_one :deliver_unit, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :deliver_unit, allow_destroy: true

  has_one :job_estimation, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :job_estimation, allow_destroy: true

  has_one :request_spare_part, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :request_spare_part, allow_destroy: true

  has_one :request_on_loan_spare_part, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :request_on_loan_spare_part, allow_destroy: true

  has_one :action_warranty_extend, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :action_warranty_extend, allow_destroy: true

  after_create :flush_cache

  def cached_task_action
    Rails.cache.fetch([self.id, :task_action]){ self.task_action }
  end

  def flush_cache
    Rails.cache.delete([self.ticket.id, :user_ticket_actions])
  end
end

class UserAssignTicketAction < ActiveRecord::Base
  self.table_name = "spt_act_assign_ticket"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id
  belongs_to :sbu, foreign_key: :sbu_id
end

class AssignRegionalSupportCenter < ActiveRecord::Base
  self.table_name = "spt_act_assign_regional_support_center"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  belongs_to :regional_support_center
end

class RegionalSupportCenter < ActiveRecord::Base
  self.table_name = "spt_regional_support_center"

  has_many :assign_regional_support_centers

  belongs_to :organization

  has_many :sbu_regional_engineers#, foreign_key: :regional_support_center_id
  has_many :engineers, through: :sbu_regional_engineers
end

class HpCase < ActiveRecord::Base
  self.table_name = "spt_act_hp_case_action"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  validates_presence_of :case_id
end

class TicketActionTaken < ActiveRecord::Base
  self.table_name = "spt_act_action_taken"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id
end

class TicketFinishJob < ActiveRecord::Base
  self.table_name = "spt_act_finish_job"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id
end

class TicketTerminateJob < ActiveRecord::Base
  self.table_name = "spt_act_terminate_job"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id
  belongs_to :reason, foreign_key: :reason_id
end

class TicketTerminateJobPayment < ActiveRecord::Base
  self.table_name = "spt_act_terminate_job_payment"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id
  belongs_to :ticket, foreign_key: :ticket_id
  belongs_to :payment_item, foreign_key: :payment_item_id
end

class PaymentItem < ActiveRecord::Base
  self.table_name = "mst_spt_payment_item"

  has_many :ticket_terminate_job_payments, foreign_key: :payment_item_id
  accepts_nested_attributes_for :ticket_terminate_job_payments, allow_destroy: true
end

class ActHold < ActiveRecord::Base
  self.table_name = "spt_act_hold"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id
  belongs_to :reason, foreign_key: :reason_id
end

class ActFsr < ActiveRecord::Base
  self.table_name = "spt_act_fsr"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id
  belongs_to :ticket_fsr, foreign_key: :fsr_id
  accepts_nested_attributes_for :ticket_fsr, allow_destroy: true
end

class SerialRequest < ActiveRecord::Base
  self.table_name = "spt_act_edit_serial_request"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id
end

class DeliverUnit < ActiveRecord::Base
  self.table_name = "spt_act_deliver_unit"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  belongs_to :ticket_delivery_unit, foreign_key: :ticket_deliver_unit_id

end

class JobEstimation < ActiveRecord::Base
  self.table_name = "spt_act_job_estimate"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  belongs_to :ticket_estimation, foreign_key: :ticket_estimation_id

  belongs_to :organization, foreign_key: :supplier_id

end

class RequestSparePart < ActiveRecord::Base
  self.table_name = "spt_act_request_spare_part"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  belongs_to :ticket_spare_part

end

class RequestOnLoanSparePart < ActiveRecord::Base
  self.table_name = "spt_act_request_on_loan_spare_part"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  belongs_to :ticket_on_loan_spare_part, foreign_key: :ticket_on_loan_spare_part_id

end