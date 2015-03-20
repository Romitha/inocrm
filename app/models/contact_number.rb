class ContactNumber < ActiveRecord::Base

  belongs_to :c_numberable, polymorphic: true

  TYPES = %w(Land Mobile Mail Fax Skype)
  validates :value, presence: true
  validates :category, presence: true

  scope :primary_contactnumber, -> {where(primary: true)}
  scope :nonprimary_contactnumber, -> {where(primary: false)}
end

class ContactType < ActiveRecord::Base
	self.table_name = "mst_spt_customer_contact_type"
	has_many :contact_type_values, foreign_key: :contact_type_id
  has_many :customers, through: :contact_type_values
end