class Organization < ActiveRecord::Base
  resourcify
  mount_uploader :logo, LogoUploader

  has_many :addresses, as: :addressable
  accepts_nested_attributes_for :addresses, allow_destroy: true

  has_many :contact_numbers, as: :c_numberable
  accepts_nested_attributes_for :contact_numbers, allow_destroy: true

  has_many :designations

  has_many :departments

  #2014_11_11
  has_many :users

  has_many :document_attachments

  TYPES = %w(organization_supplier organization_customer individual_supplier individual_customer)

  scope :organization_suppliers, -> {where(category: TYPES[0])}
  scope :individual_suppliers, -> {where(category: TYPES[2])}
  scope :organization_customers, -> {where(category: TYPES[1])}
  scope :individual_customers, -> {where(category: TYPES[3])}
  scope :owner, -> {where(refers: "VSIS").first}

  validates_format_of :web_site, :with => URI::regexp(%w(http https))

  # self join table tricks
  has_many :members, class_name: "Organization", foreign_key: "parent_organization_id"
  belongs_to :parent_organization, class_name: "Organization"

  validates :description, presence: true
  validates :name, presence: true
  validates :short_name, presence: true

  validates_presence_of :vat_number, if: Proc.new {|organization| TYPES[0,2].include?(organization.category)}

  has_many :dyna_columns, as: :resourceable

  [:previous_vat_number].each do |dyna_method|
    define_method(dyna_method) do
      self.dyna_columns.find_by_data_key(dyna_method).try(:data_value)
    end

    define_method("#{dyna_method}=") do |value|
      data = self.dyna_columns.find_or_initialize_by(data_key: dyna_method)
      data.data_value = (value.class==Fixnum ? value : value.strip)
      data.save
    end
  end
end