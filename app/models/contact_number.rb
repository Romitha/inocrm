class ContactNumber < ActiveRecord::Base

  belongs_to :c_numberable, polymorphic: true

  TYPES = %w(Land Mobile Mail Fax Skype)
  validates :value, presence: true
  # validates :value,:presence => true,
  #                :numericality => true,
  #                :length => { :minimum => 10, :maximum => 15 }
  # validates :category, presence: true

  scope :primary_contactnumber, -> {where(primary: true)}
  scope :nonprimary_contactnumber, -> {where(primary: false)}

  belongs_to :country, class_name: "ProductSoldCountry"
  belongs_to :province
  belongs_to :district
  belongs_to :organization_contact_type, foreign_key: :type_id

end

class ContactTypeValidate < ActiveRecord::Base
  self.table_name = "mst_contact_type_validate"
  has_many :contact_type, foreign_key: :validate_id

end

class ContactType < ActiveRecord::Base
	self.table_name = "mst_spt_customer_contact_type"
	has_many :contact_type_values, foreign_key: :contact_type_id
  has_many :customers, through: :contact_type_values

  has_many :contact_person_contact_types, foreign_key: :contact_type_id
  has_many :contact_person1s, through: :contact_person_contact_types
  has_many :contact_person2s, through: :contact_person_contact_types
  has_many :report_persons, through: :contact_person_contact_types

  belongs_to :contact_type_validate, foreign_key: :validate_id

  accepts_nested_attributes_for :contact_type_values, :allow_destroy => true

end

class ContactTypeValue < ActiveRecord::Base
  self.table_name = "spt_customer_contact_type"

  belongs_to :customer
  belongs_to :contact_type
end

class ContactPersonContactType < ActiveRecord::Base
  self.table_name = "spt_contact_report_person_contact_type"

  belongs_to :contact_person1, foreign_key: :contact_report_person_id
  belongs_to :contact_person2, foreign_key: :contact_report_person_id
  belongs_to :report_person, foreign_key: :contact_report_person_id
  belongs_to :contact_type, foreign_key: :contact_type_id

  validates_presence_of [:contact_type_id, :value]
end

class ContactPersonPrimaryType < ActiveRecord::Base
  self.table_name = "mst_contact_person_primary_type"

  has_many :contact_person_primary_type_connectors, foreign_key: :contact_person_id
  has_many :organization_contact_persons, through: :contact_person_primary_type_connectors
end

class ContactPersonPrimaryTypeConnector < ActiveRecord::Base
  self.table_name = "contact_person_primary_type"

  belongs_to :organization_contact_person, foreign_key: :contact_person_id
  belongs_to :contact_person_primary_type, foreign_key: :primary_type_id

end

class OrganizationContactPerson < ActiveRecord::Base
  self.table_name = "organization_contact_person"

  belongs_to :organization
  belongs_to :contact_person_type
  belongs_to :mst_title, foreign_key: :title_id
  belongs_to :contact_person_type, foreign_key: :type_id

  has_many :contact_person_primary_type_connectors, foreign_key: :contact_person_id
  has_many :contact_person_primary_types, through: :contact_person_primary_type_connectors

  scope :contact_persons1, -> { joins(:contact_person_primary_types).where(mst_contact_person_primary_type: {code: "CP1"}) }
  scope :contact_persons2, -> { joins(:contact_person_primary_types).where(mst_contact_person_primary_type: {code: "CP2"}) }

end

class OrganizationContactType < ActiveRecord::Base
  self.table_name = "mst_contact_types"

  has_many :addresses
  has_many :contact_numbers

end