class TaskAction < ActiveRecord::Base
  self.table_name = "mst_spt_action"

  has_many :q_and_as, foreign_key: :action_id

  has_many :ge_q_and_as, foreign_key: :action_id

  has_many :user_ticket_actions, foreign_key: :action_id
end

class UserTicketAction < ActiveRecord::Base
  self.table_name = "spt_ticket_action"
  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :ticket, type: "nested", include_in_parent: true
    indexes :ticket_spare_parts, type: "nested", include_in_parent: true
  end

  def self.search(params)  
    tire.search(page: (params[:page] || 1), per_page: (params[:per_page] || 1000)) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
          # must { range :published_at, lte: Time.zone.now }
          # must { term :author_id, params[:author_id] } if params[:author_id].present?
        end
      end
      sort { by :action_at, "desc" } if params[:query].blank?
    end
  end

  def to_indexed_json
    Ticket
    TicketSparePart
    to_json(
      only: [:id, :ticket_id, :action_id, :action_at, :action_by, :re_open_index, :created_at, :action_engineer_id],
      methods: [:action_by_name,:action_engineer_by_name, :feedback_reopen, :inhouse_type_select],
      include: {
        ticket:{
          only: [:id, :ticket_no,:sla_time, :job_finished,:job_finished_at],
          methods:[:support_ticket_no, :customer_name, :sla_description],
          include: {
            ticket_spare_parts: {
              only: [:id, :spare_part_no, :spare_part_description, :request_from],
              methods:[:spare_part_event_no],
            },
            owner_engineer: {
              methods: [:sbu_name, :full_name],
            },
          },
        },
        request_spare_part:{
          only: [:id],
          include: {
            ticket_spare_part: {
              only: [:id, :spare_part_no, :spare_part_description, :request_from],
              methods:[:spare_part_event_no],
              include: {
                ticket_spare_part_manufacture: {
                  only: [:id, :collect_pending_manufacture],
                },
              }
            },
          },
        },
      },
    )

  end
  def feedback_not_reopen
    Invoice
    customer_feedback.try(:re_opened) ? true : false
    
  end
  def formatted_action_date
    action_at.strftime(INOCRM_CONFIG["short_date_format"])
  end

  def action_by_name
    user_id.try(:full_name)
  end
  def action_engineer_by_name
    action_engineer.try(:full_name)
  end
  belongs_to :action_engineer, class_name: "TicketEngineer", foreign_key: :action_engineer_id

  belongs_to :user_id, class_name: "User", foreign_key: :action_by

  has_many :q_and_answers, foreign_key: :ticket_action_id

  has_many :terminate_invoice, foreign_key: :ticket_action_id

  has_many :ge_q_and_answers, foreign_key: :ticket_action_id

  belongs_to :ticket
  belongs_to :task_action, foreign_key: :action_id

  has_one :user_assign_ticket_action, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :user_assign_ticket_action, allow_destroy: true

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

  has_many :act_terminate_job_payments, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :act_terminate_job_payments, allow_destroy: true

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

  has_one :act_job_estimation, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :job_estimation, allow_destroy: true

  has_one :request_spare_part, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :request_spare_part, allow_destroy: true

  has_one :request_on_loan_spare_part, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :request_on_loan_spare_part, allow_destroy: true

  has_one :action_warranty_extend, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :action_warranty_extend, allow_destroy: true

  has_one :customer_feedback, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :customer_feedback, allow_destroy: true

  has_one :act_payment_received, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :act_payment_received, allow_destroy: true

  has_one :act_quality_control, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :act_quality_control, allow_destroy: true

  has_one :inform_customer, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :inform_customer, allow_destroy: true

  has_one :act_ticket_close_approve, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :act_ticket_close_approve, allow_destroy: true

  has_one :act_quotation, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :act_quotation, allow_destroy: true

  has_one :act_print_invoice, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :act_print_invoice, allow_destroy: true

  after_create :flush_cache

  before_create :set_action_at

  def cached_task_action
    Rails.cache.fetch([self.id, :task_action]){ self.task_action }
  end

  def flush_cache
    # self.update action_at: DateTime.now
    Rails.cache.delete([self.ticket.id, :user_ticket_actions])
  end

  def set_action_at
    self.action_at = DateTime.now
  end

end

class ActTicketCloseApprove < ActiveRecord::Base
  self.table_name = "spt_act_ticket_close_approve"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id
  belongs_to :reason, foreign_key: :reject_reason_id
  belongs_to :user, foreign_key: :owner_engineer_id

end

class UserAssignTicketAction < ActiveRecord::Base
  self.table_name = "spt_act_assign_ticket"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id
  belongs_to :sbu, foreign_key: :sbu_id
  belongs_to :assign_to_user, class_name: "User", foreign_key: :assign_to
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
  accepts_nested_attributes_for :sbu_regional_engineers, allow_destroy: true
  has_many :engineers, through: :sbu_regional_engineers

  def is_used_anywhere?
    User
    assign_regional_support_centers.any? or sbu_regional_engineers.any? or engineers.any?
  end
end

class HpCase < ActiveRecord::Base
  self.table_name = "spt_act_hp_case_action"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id
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

class ActTerminateJobPayment < ActiveRecord::Base
  self.table_name = "spt_act_terminate_job_payment"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id
  belongs_to :ticket, foreign_key: :ticket_id
  belongs_to :payment_item, foreign_key: :payment_item_id

  belongs_to :currency
  belongs_to :reason, foreign_key: :adjust_reason_id

  has_many :ticket_invoice_terminates, foreign_key: :terminate_job_payment_id
  has_many :act_terminate_job_payments, through: :ticket_invoice_terminates

end

class PaymentItem < ActiveRecord::Base
  self.table_name = "mst_spt_payment_item"

  has_many :act_terminate_job_payments, foreign_key: :payment_item_id
  accepts_nested_attributes_for :act_terminate_job_payments, allow_destroy: true

  validates :default_amount, presence: true, :format => { :with => /\A\d{1,10}(\.\d{0,2})?\z/ }, :numericality => {:greater_than => -1, :less_than => 9999999999.99}
  validates :name, presence: true, uniqueness: true, :format => { :with => /\A[a-zA-Z ]+\Z/ }
  # validates :default_amount, :length => { :minimum => 6, :maximum => 6 }

  def is_used_anywhere?
    act_terminate_job_payments.any?
  end
end

class ActHold < ActiveRecord::Base
  self.table_name = "spt_act_hold"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id
  belongs_to :reason, foreign_key: :reason_id

  validates :reason_id, presence: true

  def act_hold_reason
    reason.try(:reason)
  end
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

  belongs_to :ticket_deliver_unit, foreign_key: :ticket_deliver_unit_id

end

class JobEstimation < ActiveRecord::Base
  self.table_name = "spt_act_job_estimate"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  belongs_to :ticket_estimation, foreign_key: :ticket_estimation_id

  belongs_to :organization, foreign_key: :supplier_id

end

class ActJobEstimation < ActiveRecord::Base
  self.table_name = "spt_act_job_estimate"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  belongs_to :ticket_estimation, foreign_key: :ticket_estimation_id

  belongs_to :organization, foreign_key: :supplier_id

end

class RequestSparePart < ActiveRecord::Base
  self.table_name = "spt_act_request_spare_part"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  belongs_to :ticket_spare_part, foreign_key: :ticket_spare_part_id

  belongs_to :reject_return_part_reason, -> { where(reject_returned_part: true) }, class_name: "Reason", foreign_key: :reject_return_part_reason_id
  belongs_to :part_terminate_reason, class_name: "Reason", foreign_key: :part_terminate_reason_id

end

class RequestOnLoanSparePart < ActiveRecord::Base
  self.table_name = "spt_act_request_on_loan_spare_part"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  belongs_to :ticket_on_loan_spare_part, foreign_key: :ticket_on_loan_spare_part_id

end

class InformCustomer < ActiveRecord::Base
  self.table_name = "spt_act_inform_customer"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  belongs_to :ticket_contact_type, foreign_key: :contact_type_id

end

class ActPaymentReceived < ActiveRecord::Base

  self.table_name = "spt_act_payment_received"
  belongs_to :ticket_payment_received, foreign_key: :ticket_payment_received_id
  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

end

class ActQualityControl < ActiveRecord::Base

  self.table_name = "spt_act_qc"
  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

end

class ActQuotation < ActiveRecord::Base

  self.table_name = "spt_act_quotation"
  belongs_to :user_ticket_action, foreign_key: :ticket_action_id
  belongs_to :customer_quotation

end

class ActPrintInvoice < ActiveRecord::Base

  self.table_name = "spt_act_print_invoice"
  belongs_to :user_ticket_action, foreign_key: :ticket_action_id
  belongs_to :invoice

end