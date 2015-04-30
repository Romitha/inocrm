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

  has_many :contact_person_contact_types, foreign_key: :contact_type_id
  has_many :contact_person1s, through: :contact_person_contact_types
  has_many :contact_person2s, through: :contact_person_contact_types
  has_many :report_persons, through: :contact_person_contact_types

  accepts_nested_attributes_for :contact_type_values, :allow_destroy => true

end

class ContactTypeValue < ActiveRecord::Base
  self.table_name = "spt_customer_contact_type"

  belongs_to :customer
  belongs_to :contact_type

  validates_presence_of [:contact_type_id, :value]
end

class ContactPersonContactType < ActiveRecord::Base
  self.table_name = "spt_contact_report_person_contact_type"

  belongs_to :contact_person1, foreign_key: :contact_report_person_id
  belongs_to :contact_person2, foreign_key: :contact_report_person_id
  belongs_to :report_person, foreign_key: :contact_report_person_id
  belongs_to :contact_type, foreign_key: :contact_type_id

  validates_presence_of [:contact_type_id, :value]
end