class Organization < ActiveRecord::Base
  resourcify
  mount_uploader :logo, LogoUploader

  has_many :addresses, as: :addressable
  accepts_nested_attributes_for :addresses, allow_destroy: true

  has_many :contact_numbers, as: :c_numberable
  accepts_nested_attributes_for :contact_numbers, allow_destroy: true

  has_many :designations
  has_many :ticket_deliver_units, foreign_key: :deliver_to_id
  accepts_nested_attributes_for :ticket_deliver_units, allow_destroy: true


  # has_many :departments

  #2014_11_11
  has_many :users
  has_many :customers

  has_many :document_attachments, as: :attachable
  accepts_nested_attributes_for :document_attachments, allow_destroy: true

  has_many :tickets

  TYPES = %w(organization_supplier organization_customer individual_supplier individual_customer)

  scope :organization_suppliers, -> {where(category: TYPES[0])}
  scope :individual_suppliers, -> {where(category: TYPES[2])}
  scope :organization_customers, -> {where(category: TYPES[1])}
  scope :individual_customers, -> {where(category: TYPES[3])}
  scope :owner, -> {where(refers: "VSIS").first}

  scope :stores, -> { where(type_id: 4)}

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

  def employees
    users.order("created_at DESC").select{|user| !user.is_customer? }
  end

  #it is used for @organization.departments or @organization.department_org
  # department_org says, org of department, cause @organization is also department. In other word, department is also a type of organization.
  # has_many :departments, class_name: "Organization", foreign_key: "department_org_id" # foreign_key refers belongs_to below.
  # belongs_to :department_org, class_name: "Organization" # org_department refers foreign_key above

  belongs_to :organization_type, foreign_key: :type_id

  has_many :ticket_estimation_externals, foreign_key: :repair_by_id

  has_many :job_estimations, foreign_key: :supplier_id

  has_many :act_job_estimations, foreign_key: :supplier_id

  has_many :inventories, foreign_key: :store_id

  has_many :ticket_spare_part_stores, foreign_key: :store_id

  has_many :ticket_estimation_parts, foreign_key: :supplier_id

  has_many :srns, foreign_key: :store_id
  accepts_nested_attributes_for :srns, allow_destroy: true

  has_many :grns, foreign_key: :store_id
  accepts_nested_attributes_for :grns, allow_destroy: true

  has_many :gins, foreign_key: :store_id
  accepts_nested_attributes_for :gins, allow_destroy: true

  has_many :requested_location_srns, class_name: "Srn", foreign_key: :requested_location_id


  def self.major_organization(category)
    where(category: category, department_org_id: nil)
  end
end

class OrganizationType < ActiveRecord::Base
  self.table_name = "mst_organizations_types"

  has_many :organizations, foreign_key: "type_id"
end

class CompanyConfig < ActiveRecord::Base
  self.table_name = "company_config"

  # has_many :organizations, foreign_key: "type_id"

  def increase_inv_last_srn_no
    update inv_last_srn_no: (inv_last_srn_no.to_i+1)
    inv_last_srn_no
  end

  def increase_inv_last_gin_no
    update inv_last_gin_no: (inv_last_gin_no.to_i+1)
    inv_last_gin_no
  end  
end