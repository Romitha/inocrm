class Organization < ActiveRecord::Base
  mount_uploader :logo, LogoUploader

  has_many :addresses, as: :addressable
  accepts_nested_attributes_for :addresses, allow_destroy: true

  has_many :contact_numbers, as: :c_numberable
  accepts_nested_attributes_for :contact_numbers, allow_destroy: true

  has_many :designations

  #2014_11_11
  has_many :users

	TYPES = %w(Supplier Customer)

	scope :suppliers, -> {where(category: "Supplier")}
	scope :customers, -> {where(category: "Customer")}

  validates_format_of :web_site, :with => URI::regexp(%w(http https))

  # self join table tricks
  has_many :members, class_name: "Organization", foreign_key: "parent_organization_id"
  belongs_to :parent_organization, class_name: "Organization"

end