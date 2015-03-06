class Ticket < ActiveRecord::Base

  self.table_name = "spt_ticket"
  # belongs_to :organization
  # belongs_to :department
  belongs_to :customer, class_name: "Customer", foreign_key: "customer_id"

  has_many :agent_ticket_infos
  has_many :agents, through: :agent_ticket_infos

  has_many :document_attachments, as: :attachable
  accepts_nested_attributes_for :document_attachments, allow_destroy: true

  has_many :comments

  STATUS = %w(open pending closed spam )

  TYPES = %w(problem question feature_request lead )

  PRIORITY = %w(Urgent high medium low )
  INITIATED = %w(phone carry-in online)

  validates_presence_of [:due_date_time, :customer, :initiated_through, :ticket_type, :customer, :initiated_through, :ticket_type, :status, :subject, :department, :agents, :priority, :description,]

  has_many :dyna_columns, as: :resourceable

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

class Customer < ActiveRecord::Base
  self.table_name = "spt_customer"
end
