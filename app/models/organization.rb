class Organization < ActiveRecord::Base
  resourcify
  mount_uploader :logo, LogoUploader

  include Tire::Model::Search
  include Tire::Model::Callbacks

  has_many :addresses, as: :addressable
  accepts_nested_attributes_for :addresses, allow_destroy: true

  has_many :contact_numbers, as: :c_numberable
  accepts_nested_attributes_for :contact_numbers, allow_destroy: true

  has_many :designations
  has_many :ticket_deliver_units, foreign_key: :deliver_to_id
  accepts_nested_attributes_for :ticket_deliver_units, allow_destroy: true

  has_one :account
  accepts_nested_attributes_for :account, allow_destroy: true
  has_one :industry_type, through: :account
  has_many :accounts_dealer_types, through: :account

  has_many :users
  has_many :customers
  accepts_nested_attributes_for :customers, allow_destroy: true
  has_many :product_brands

  has_many :document_attachments, as: :attachable
  accepts_nested_attributes_for :document_attachments, allow_destroy: true

  has_many :tickets

  # self join table tricks
  has_many :members, class_name: "Organization", foreign_key: "parent_organization_id"
  belongs_to :parent_organization, class_name: "Organization"
  has_many :dyna_columns, as: :resourceable

  #it is used for @organization.departments or @organization.department_org
  # department_org says, org of department, cause @organization is also department. In other word, department is also a type of organization.
  # has_many :departments, class_name: "Organization", foreign_key: "department_org_id" # foreign_key refers belongs_to below.
  # belongs_to :department_org, class_name: "Organization" # org_department refers foreign_key above

  belongs_to :organization_type, foreign_key: :type_id

  has_many :ticket_estimation_externals, foreign_key: :repair_by_id

  has_many :products, foreign_key: :owner_customer_id
  accepts_nested_attributes_for :products, allow_destroy: true

  has_many :job_estimations, foreign_key: :supplier_id

  has_many :act_job_estimations, foreign_key: :supplier_id

  has_many :inventories, foreign_key: :store_id
  has_many :inventory_products, through: :inventories

  has_many :ticket_spare_part_stores, foreign_key: :store_id

  has_many :ticket_estimation_parts, foreign_key: :supplier_id

  has_many :srns, foreign_key: :store_id
  accepts_nested_attributes_for :srns, allow_destroy: true

  has_many :grns, foreign_key: :store_id
  accepts_nested_attributes_for :grns, allow_destroy: true

  has_many :gins, foreign_key: :store_id
  accepts_nested_attributes_for :gins, allow_destroy: true

  has_many :requested_location_srns, class_name: "Srn", foreign_key: :requested_location_id
  has_many :inventory_racks, foreign_key: :location_id

  has_many :ticket_contracts, foreign_key: :customer_id
  has_many :contract_products, through: :ticket_contracts

  belongs_to :mst_title, foreign_key: :title_id
  belongs_to :created_by_user, class_name: "User", foreign_key: :created_by

  has_many :organization_contact_addresses

  has_many :organization_contact_persons
  accepts_nested_attributes_for :organization_contact_persons, allow_destroy: true

  has_many :organization_bank_details
  accepts_nested_attributes_for :organization_bank_details, allow_destroy: true

  has_one :ancestor, class_name: 'OrganizationTreePath'
  has_many :descendants, class_name: 'OrganizationTreePath', foreign_key: :descendant_id

  TYPES = %w(SUP CUS INDSUP INDCUS)

  scope :organization_suppliers, -> {where(category: TYPES[0])}
  scope :individual_suppliers, -> {where(category: TYPES[2])}
  scope :organization_customers, -> {where(category: TYPES[1]).order('name asc')}
  scope :individual_customers, -> {where(category: TYPES[3])}
  scope :owner, -> { where(refers: "CRM_OWNER").first }

  scope :stores, -> { where(type_id: 4)}

  validates_format_of :web_site, :with => URI::regexp(%w(http https)), if: Proc.new{|o| o.web_site.present? }

  # validates :title_id, presence: true
  validates :name, presence: true, uniqueness: true
  validates :short_name, presence: true

  validates_presence_of :vat_number, if: Proc.new {|organization| TYPES[0,2].include?(organization.category)}

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

  def self.organization_suppliers
    # DealerType.find_by_code("SUP").accounts.map{|a| a.organization}.compact
    joins(accounts_dealer_types: :dealer_type).where("mst_dealer_types.code = 'SUP'").references(:dealer_type)
  end

  def self.organization_customers
    # DealerType.find_by_code("SUP").accounts.map{|a| a.organization}.compact
    joins(accounts_dealer_types: :dealer_type).where("mst_dealer_types.code = 'CUS'").references(:dealer_type)
  end

  def self.individual_suppliers
    # DealerType.find_by_code("SUP").accounts.map{|a| a.organization}.compact
    joins(accounts_dealer_types: :dealer_type).where("mst_dealer_types.code = 'INDSUP'").references(:dealer_type)
  end

  def self.individual_suppliers
    # DealerType.find_by_code("SUP").accounts.map{|a| a.organization}.compact
    joins(accounts_dealer_types: :dealer_type).where("mst_dealer_types.code = 'INDCUS'").references(:dealer_type)
  end

  def self.major_organization(category)
    where(category: category, department_org_id: nil)
  end

  def primary_address
    addresses.primary_address.first
  end

  def get_code
    organization_type.try(:code)
  end

  def self.organization_tree_path(who, level = 0)
    @tree_path = [] # Here @tree_path is class variable.

    if who.members.any?
      who.members.each { |o| organization_tree_path(o, (level+1)) }
      @tree_path << {member: who, level: level}
      
    else
      return @tree_path << {member: who, level: level}
    end

  end
  # class << self
  #   protected


  # end


  def anchestors
    @anchestors ||= self.class.organization_tree_path(self) # first time call to sql, and thereafter @anchestors is saved in cache for particular instance
  end

  def self.customers
    joins(accounts_dealer_types: :dealer_type).where("mst_dealer_types.code = 'CUS' or mst_dealer_types.code = 'INDCUS'").order("name ASC").references(:dealer_type)
  end

  def self.suppliers
    joins(accounts_dealer_types: :dealer_type).where("mst_dealer_types.code = 'SUP' or mst_dealer_types.code = 'INDSUP'").order("name ASC").references(:dealer_type)
  end

  settings :analysis => {
    :analyzer => {
      :case_insensitive_sort => {
        "tokenizer"=>"keyword",
        "filter"=>["lowercase"],
        }
      }
    } do
    mapping do
      indexes :industry_type, type: "nested", include_in_parent: true
      indexes :accounts_dealer_types, type: "nested", include_in_parent: true
      indexes :addresses, type: "nested", include_in_parent: true
      indexes :contact_numbers, type: "nested", include_in_parent: true
      indexes :account, type: "nested", include_in_parent: true
      indexes :products, type: "nested", include_in_parent: true
      indexes :name, type: 'multi_field', fields: {
        # analyzed: {type: 'string', index: :not_analyzed},
        analyzed: {type: 'string', analyzer: 'case_insensitive_sort'},
        name: {type: 'string', analyzer: "english"}
      }
    end
  end

  def self.search(params)
    tire.search(page: params[:page], per_page: 10) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?
        end

      end
      # terms id: [1, 2]
      # sort { by :name, {order: "desc", ignore_unmapped: true} }
      sort { by "name.analyzed", 'asc' }

      # raise to_curl
    end
  end

  def to_indexed_json
    to_json(
      only: [:id, :name, :type_id, :code],
      methods: [:get_code],
      include: {
        industry_type: {
          only: [:id, :name],
        },
        products: {
          only: [:id],
          include: {
            ticket_contracts: {
              only: [:id],
              methods: [:dynamic_active, :product_amount]
            }
          },
        },
        accounts_dealer_types: {
          only: [:id],
          methods: [:dealer_id, :dealer_name, :dealer_code],
        },
        addresses: {
          only: [:id, :primary_address],
          methods: [:full_address],
        },
        contact_numbers: {
          only: [:value, :primary_contact],
          methods: [:contact_info],
        },
        account: {
          only: [:id, :industry_types_id,:account_no, :code, :account_manager],
          methods: [:get_account_manager],
        },
      },
    )

  end

  after_create :assign_to_organization

  def assign_to_organization
    if account
      self.account.update account_no: (CompanyConfig.first.last_account_no + 1 )
      CompanyConfig.first.increment! :last_account_no, 1
    end
  end

  def get_organization_account_manager
    account.try(:get_account_manager)
  end

end

class OrganizationType < ActiveRecord::Base
  self.table_name = "mst_organization_types"

  has_many :organizations, foreign_key: "type_id"
end

class CompanyConfig < ActiveRecord::Base
  self.table_name = "company_config"
  ContractsController
  # has_many :organizations, foreign_key: "type_id"

  def increase_inv_last_srn_no
    update inv_last_srn_no: (inv_last_srn_no.to_i+1)
    inv_last_srn_no
  end

  def increase_inv_last_gin_no
    update inv_last_gin_no: (inv_last_gin_no.to_i+1)
    inv_last_gin_no
  end

  def increase_inv_last_srr_no
    update inv_last_srr_no: (inv_last_srr_no.to_i+1)
    inv_last_srr_no
  end

  def increase_inv_last_grn_no
    update inv_last_grn_no: (inv_last_grn_no.to_i+1)
    inv_last_grn_no
  end

  def increase_inv_last_po_no
    update inv_last_po_no: (inv_last_po_no.to_i+1)
    inv_last_po_no
  end

  def increase_sup_last_invoice_no
    update sup_last_invoice_no: (sup_last_invoice_no.to_i+1)
    sup_last_invoice_no
  end

  def increase_sup_last_receipt_no
    update sup_last_receipt_no: (sup_last_receipt_no.to_i+1)
    sup_last_receipt_no
  end

  def increase_sup_last_bundle_no
    update sup_last_bundle_no: (sup_last_bundle_no.to_i+1)
    sup_last_bundle_no
  end

  def increase_sup_last_quotation_no
    update sup_last_quotation_no: (sup_last_quotation_no.to_i+1)
    sup_last_quotation_no
  end

  def increase_sup_last_fsr_no
    update sup_last_fsr_no: (sup_last_fsr_no.to_i+1)
    sup_last_fsr_no
  end

  def increase_sup_last_contract_serial_no
    update sup_last_contract_serial_no: (sup_last_contract_serial_no.to_i+1)
    sup_last_contract_serial_no
  end

  def increase_inv_last_prn_no
    update inv_last_prn_no: (inv_last_prn_no.to_i+1)
    inv_last_prn_no
  end

  def next_sup_last_invoice_no
    sup_last_invoice_no.to_i+1
  end

  def next_sup_last_quotation_no
    sup_last_quotation_no.to_i+1
  end

  def next_sup_last_fsr_no
    sup_last_fsr_no.to_i+1
  end

  def next_sup_last_contract_serial_no
    sup_last_contract_serial_no.to_i+1
  end
  
  def next_sup_last_grn_no
    inv_last_grn_no.to_i+1
  end

  def next_sup_last_srn_no
    inv_last_srn_no.to_i+1
  end

  def next_sup_last_gin_no
    inv_last_gin_no.to_i+1
  end

  def next_sup_last_prn_no
    inv_last_prn_no.to_i+1
  end

  def next_inv_last_po_no
    inv_last_po_no.to_i+1
  end

  def next_inv_last_srr_no
    inv_last_srr_no.to_i+1
  end

end

class Account < ActiveRecord::Base
  self.table_name = "accounts"

  belongs_to :organization
  belongs_to :industry_type, foreign_key: :industry_types_id
  belongs_to :account_manager, class_name: "User"

  has_many :accounts_dealer_types
  has_many :dealer_types, through: :accounts_dealer_types

  validates_uniqueness_of :code, if: Proc.new { |account| account.code.present?}, message: "This code has already been taken"

  def created_user
    User.cached_find_by_id(created_by)
  end
  def get_account_manager
    account_manager.try(:full_name)
  end
  def get_account_manager_id
    account_manager.try(:id)
  end

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

class IndustryType < ActiveRecord::Base
  self.table_name = "mst_industry_types"

  has_many :accounts, foreign_key: :industry_types_id
  has_many :organizations, through: :accounts

  def is_used_anywhere?
    accounts.any?
    organizations.any?
  end
end

class AccountsDealerType < ActiveRecord::Base
  self.table_name = "accounts_dealer_type"

  belongs_to :dealer_type, foreign_key: :dealer_types_id
  belongs_to :account

  def dealer_id
    dealer_type.id
  end

  def dealer_name
    dealer_type.name
  end

  def dealer_code
    dealer_type.code
  end
end

class DealerType < ActiveRecord::Base
  self.table_name = "mst_dealer_types"

  has_many :accounts_dealer_types, foreign_key: :dealer_types_id
  has_many :accounts, through: :accounts_dealer_types
end

class OrganizationBankDetail < ActiveRecord::Base
  self.table_name = "organization_bank_detail"

  belongs_to :organization

  has_many :ticket_invoice

end

class OrganizationTreePath < ActiveRecord::Base
  self.table_name = 'organization_treepath'

  def flat_children

  end
end