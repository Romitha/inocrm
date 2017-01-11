class Address < ActiveRecord::Base
  #Users and Organizations have multiple addresses
  belongs_to :addressable, polymorphic: true

  TYPES = %w(Billing Shipping Support Office Home)

  validates :address1, presence: true
  # validates :category, presence: true

  # validates_uniqueness_of :primary, conditions: -> { where(primary: true)}, scope: [:addressable_id, :addressable_type]

  scope :primary_address, -> {where(primary: true)}
  scope :non_primary_address, -> {where(primary: false)}

  belongs_to :country, class_name: "ProductSoldCountry"
  belongs_to :province
  belongs_to :district
  belongs_to :organization_contact_type, foreign_key: :type_id
  belongs_to :contact_person_title, class_name: "MstTitle"

  def full_address
    "#{address1}, #{address2}, #{address3}, #{city}"
  end

  def contact_person
    "#{contact_person_title.try(:title)} #{contact_person_name}"
  end

end

class Province < ActiveRecord::Base
  self.table_name = "mst_province"

  has_many :addresses
  has_many :contact_numbers
end

class OrganizationContactType < ActiveRecord::Base
  self.table_name = "mst_contact_types"

  has_many :addresses
  has_many :contact_numbers
end