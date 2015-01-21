class Ticket < ActiveRecord::Base
  belongs_to :organization
  belongs_to :department
  belongs_to :customer, class_name: "User", foreign_key: "customer_id"

  has_many :agent_ticket_infos
  has_many :agents, through: :agent_ticket_infos

  has_many :document_attachments, as: :attachable
  accepts_nested_attributes_for :document_attachments, allow_destroy: true

  STATUS = %w(open pending closed spam )

  TYPES = %w(problem question feature_request lead )

  PRIORITY = %w(Urgent high medium low )
  INITIATED = %w(phone carry-in online)

  validates :customer, presence: true
  validates :initiated_through, presence: true
  validates :ticket_type, presence: true
  validates :status, presence: true
  validates :subject, presence: true
  validates :department, presence: true
  validates :agents, presence: true
  validates :priority, presence: true
  validates :description, presence: true
end
