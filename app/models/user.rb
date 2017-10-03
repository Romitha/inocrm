class User < ActiveRecord::Base
  # self.table_name = "users"

  belongs_to :mst_title, foreign_key: :title_id
  has_and_belongs_to_many :roles, :join_table => :users_roles # f the default name of the join table, based on lexical ordering, is not what you want, you can use the :join_table option to override the default. http://guides.rubyonrails.org/association_basics.html

  # belongs_to :users_role, foreign_key: :user_id

  mount_uploader :avatar, AvatarUploader

  # rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable#,:confirmable

  # def only_if_unconfirmed
  #   pending_any_confirmation {yield}
  # end

  has_many :addresses, as: :addressable
  accepts_nested_attributes_for :addresses, allow_destroy: true

  has_many :contact_numbers, as: :c_numberable
  accepts_nested_attributes_for :contact_numbers, allow_destroy: true

  belongs_to :designation

  #2014_11_11
  belongs_to :organization

  has_many :so_pos, foreign_key: :created_by
  has_many :sbu_engineers, foreign_key: :engineer_id
  has_many :sbus, through: :sbu_engineers, source: :sbu

  has_many :sbu_regional_engineers, foreign_key: :engineer_id
  has_many :regional_support_centers, through: :sbu_regional_engineers

  has_many :ticket_engineers, class_name: "TicketEngineer", foreign_key: :user_id
  # has_many :users, through: :ticket_engineers
  has_many :grns, foreign_key: :created_by
  has_many :act_ticket_close_approves

  # validates_uniqueness_of :user_name

  after_commit :flush_cache

  # validates_presence_of :password, if: Proc.new {|user| user.is_customer? }
  # FIXME this is sample text

  attr_accessor :coord_x, :coord_y, :coord_w, :coord_h
  after_update :crop_avatar


  def crop_avatar
    avatar.recreate_versions! if coord_x.present?
  end

  def other_addresses
    addresses.where.not(primary_address: true)
  end

  def primary_address
    addresses.find_by_primary_address true
  end

  def primary_contact_number
    contact_numbers.find_by_primary_contact true
  end

  def other_contact_numbers
    contact_numbers.where.not(primary_contact: true)
  end

  has_many :dyna_columns, as: :resourceable, autosave: true

  # has_many :invoices, foreign_key: "customer_id"

  [:current_user_role_id, :current_user_role_name, :is_customer].each do |dyna_method|
    define_method(dyna_method) do
      dyna_columns.find_by_data_key(dyna_method).try(:data_value)
    end

    define_method("#{dyna_method}=") do |value|
      data = dyna_columns.find_or_initialize_by(data_key: dyna_method)
      data.data_value = (value.class==Fixnum ? value : value.strip)
      @is_customer = data.data_value if dyna_method==:is_customer
      data.save if data.persisted?
    end
  end

  def is_customer?
    is_customer=="true"
  end

  def password_required?
    if @is_customer == "true"
      false
    else
      super #false !persisted || !password.nil? || !password_confirmation.nil?
    end
  end

  scope :customers, -> {select{|user| user.is_customer?}}

  def full_name
    first_name ? "#{try(:mst_title).try(:title)} #{first_name} #{last_name}" : email
  end

  # def self.engineers
  #   # u.roles.any?{|r| r.bpm_module_roles.any?{|b| b.code == "supp_engr"} }    
  # end

  def full_name=(full_name)
    splitted_names = full_name.strip.split(" ")
    self.first_name = splitted_names[0]
    self.last_name = splitted_names[1]
  end

  def primary_phone_number
    contact_numbers.find_by_primary(true)
  end

  def primary_phone_number=(contact_number)
    self.contact_numbers.build(category: "Land", value: contact_number, primary: true)
  end

  def primary_address
    addresses.find_by_primary_address(true)
  end

  def primary_address=(address)
    self.addresses.build(category: "Support", address: address, primary: true)
  end

  def self.cached_find_by_id id
    Rails.cache.fetch(["User", :find_by_id, id.to_i]){ find_by_id id }
  end

  def flush_cache
    Rails.cache.delete(["User", :find_by_id, id.to_i])
  end

end

class MstTitle < ActiveRecord::Base
  self.table_name = "mst_title"
  has_one :user, foreign_key: :title_id
  has_one :customer, foreign_key: :title_id

  def is_used_anywhere?
    user.present? or customer.present?
  end
  validates :title, presence: true, uniqueness: true
end

class ContactPersonType < ActiveRecord::Base
  self.table_name = "mst_contact_person_type"
  has_one :organization_contact_person
end

class Customer < ActiveRecord::Base
  self.table_name = "spt_customer"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :contact_type_values, type: "nested", include_in_parent: true
  end

  has_many :tickets, foreign_key: :customer_id

  has_many :contact_type_values, foreign_key: :customer_id
  has_many :contact_types, through: :contact_type_values
  accepts_nested_attributes_for :contact_type_values, :allow_destroy => true

  belongs_to :mst_title, foreign_key: :title_id

  validates_presence_of [:name, :address1]
  # validates :address4, presence: {message: "City can't be blank"}

  belongs_to :district, foreign_key: :district_id

  belongs_to :organization

  def full_name
    "#{try(:mst_title).try(:title)} #{name}"
  end

  def full_address
    "#{address1}, #{address2}, #{address3}, #{address4}"
  end

  def is_used_anywhere?
    tickets.any?# or contact_types.any?
  end

  def self.search(params)  
    tire.search(page: (params[:page] || 1), per_page: 5) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?

        end
      end
      sort { by :created_at, {order: "desc", ignore_unmapped: true} }
    end
      # query { string params[:query] } if params[:query].present?

      # filter :range, published_at: { lte: Time.zone.now} 
      # raise to_curl
  end

  def to_indexed_json
    ContactNumber
    to_json(
      only: [:id, :name, :created_at],
      methods: [:full_name, :full_address],
      include: {
        contact_type_values: {
          only: [:created_at, :id],
          methods: [:contact_info]
        },
      }
    )

  end
end

class ContactPerson1 < ActiveRecord::Base
  self.table_name = "spt_contact_report_person"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :contact_person_contact_types, type: "nested", include_in_parent: true
  end

  has_many :tickets, foreign_key: :contact_person1_id
  has_many :regular_customers

  has_many :contact_person_contact_types, foreign_key: :contact_report_person_id
  has_many :contact_types, through: :contact_person_contact_types
  accepts_nested_attributes_for :contact_person_contact_types, allow_destroy: true, reject_if: :all_blank


  belongs_to :mst_title, foreign_key: :title_id
  validates_presence_of [:title_id, :name]

  def full_name
    "#{try(:mst_title).try(:title)} #{name}"
  end

  def self.search(params)  
    tire.search(page: (params[:page] || 1), per_page: 5) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?

        end
      end
      sort { by :created_at, {order: "desc", ignore_unmapped: true} }
    end
      # query { string params[:query] } if params[:query].present?

      # filter :range, published_at: { lte: Time.zone.now} 
      # raise to_curl
  end

  def to_indexed_json
    ContactNumber
    to_json(
      only: [:id, :name, :created_at],
      methods: [:full_name],
      include: {
        contact_person_contact_types: {
          only: [:created_at, :id],
          methods: [:contact_info]
        },
      }
    )

  end

end

class ContactPerson2 < ActiveRecord::Base
  self.table_name = "spt_contact_report_person"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :contact_person_contact_types, type: "nested", include_in_parent: true
  end

  has_many :tickets, foreign_key: :contact_person2_id
  has_many :regular_customers

  has_many :contact_person_contact_types, foreign_key: :contact_report_person_id
  has_many :contact_types, through: :contact_person_contact_types
  accepts_nested_attributes_for :contact_person_contact_types, allow_destroy: true, reject_if: :all_blank


  belongs_to :mst_title, foreign_key: :title_id
  validates_presence_of [:title_id, :name]

  def full_name
    "#{try(:mst_title).try(:title)} #{name}"
  end

  def self.search(params)  
    tire.search(page: (params[:page] || 1), per_page: 5) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?

        end
      end
      sort { by :created_at, {order: "desc", ignore_unmapped: true} }
    end
      # query { string params[:query] } if params[:query].present?

      # filter :range, published_at: { lte: Time.zone.now} 
      # raise to_curl
  end

  def to_indexed_json
    ContactNumber
    to_json(
      only: [:id, :name, :created_at],
      methods: [:full_name],
      include: {
        contact_person_contact_types: {
          only: [:created_at, :id],
          methods: [:contact_info]
        },
      }
    )

  end

end

class ReportPerson < ActiveRecord::Base
  self.table_name = "spt_contact_report_person"
  has_many :tickets, foreign_key: :reporter_id

  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :contact_person_contact_types, type: "nested", include_in_parent: true
  end

  has_many :contact_person_contact_types, foreign_key: :contact_report_person_id
  has_many :contact_types, through: :contact_person_contact_types
  accepts_nested_attributes_for :contact_person_contact_types, allow_destroy: true, reject_if: :all_blank

  
  belongs_to :mst_title, foreign_key: :title_id
  validates_presence_of [:title_id, :name]

  def full_name
    "#{try(:mst_title).try(:title)} #{name}"
  end

  def self.search(params)  
    tire.search(page: (params[:page] || 1), per_page: 5) do
      query do
        boolean do
          must { string params[:query] } if params[:query].present?

        end
      end
      sort { by :created_at, {order: "desc", ignore_unmapped: true} }
    end
      # query { string params[:query] } if params[:query].present?

      # filter :range, published_at: { lte: Time.zone.now} 
      # raise to_curl
  end

  def to_indexed_json
    ContactNumber
    to_json(
      only: [:id, :name, :created_at],
      methods: [:full_name],
      include: {
        contact_person_contact_types: {
          only: [:created_at, :id],
          methods: [:contact_info]
        },
      }
    )

  end

end

class RegularCustomer < ActiveRecord::Base
  self.table_name = "spt_regular_customer"

  belongs_to :customer, foreign_key: :customer_id
  belongs_to :contact_person1, foreign_key: :contact_person1_id
  belongs_to :contact_person2, foreign_key: :contact_person2_id
  belongs_to :report_person, foreign_key: :reporter_id

  belongs_to :mst_title, foreign_key: :title_id

end

class District < ActiveRecord::Base
  self.table_name = "mst_district"
  has_many :customers, foreign_key: :district_id

  has_many :contact_person_contact_types, foreign_key: :contact_report_person_id
  has_many :addresses
  has_many :contact_numbers
end

class SbuRegionalEngineer < ActiveRecord::Base
  self.table_name = "spt_regional_support_center_engineer"

  belongs_to :regional_support_center
  belongs_to :engineer, class_name: "User", foreign_key: :engineer_id

  def is_used_anywhere?
    # engineer.present? or regional_support_center.present?
  end
end

class SbuEngineer < ActiveRecord::Base
  self.table_name = "mst_spt_sbu_engineer"

  belongs_to :sbu, foreign_key: :sbu_id
  belongs_to :engineer, class_name: "User", foreign_key: :engineer_id

  def is_used_anywhere?
    # engineer.present?
  end
end

class Sbu < ActiveRecord::Base
  self.table_name = "mst_spt_sbu"

  has_many :sbu_engineers, foreign_key: :sbu_id
  accepts_nested_attributes_for :sbu_engineers, allow_destroy: true
  has_many :engineers, through: :sbu_engineers, source: :engineer
  has_many :user_assign_ticket_actions
  has_many :user_assign_ticket_actions, foreign_key: :sbu_id

  def is_used_anywhere?
    TaskAction
    sbu_engineers.any? or engineers.any? or user_assign_ticket_actions.any?
  end
end

class Feedback < ActiveRecord::Base
  self.table_name = "mst_spt_customer_feedback"

  has_many :customer_feedbacks#, foreign_key: :engineer_id

  validates_presence_of :feedback

  def is_used_anywhere?
    Invoice
    customer_feedbacks.any?
  end
end

class TicketEngineer < ActiveRecord::Base
  self.table_name = "spt_ticket_engineer"

  belongs_to :ticket
  belongs_to :user
  belongs_to :user_ticket_action, foreign_key: :created_action_id
  belongs_to :ticket_workflow_process, foreign_key: :workflow_process_id
  belongs_to :sbu_engineer, foreign_key: :sbu_id

  has_many :ticket_owners, class_name: "Ticket", foreign_key: :owner_engineer_id
  has_many :user_assign_ticket_actions, foreign_key: :assign_to_engineer_id
  has_many :ticket_workflow_processes, foreign_key: :engineer_id

  belongs_to :parent_engineer, class_name: "TicketEngineer"
  has_many :sub_engineers, class_name: "TicketEngineer", foreign_key: :parent_engineer_id
  has_many :ticket_support_engineers, foreign_key: :engineer_id

  scope :parent_engineers, -> {where(parent_engineer_id: nil)}

  def sbu_name
    user_ticket_action.user_assign_ticket_action.sbu.sbu
  end

  def rec_sub_engineers
    if sub_engineers.empty?
      {parent_eng: self}
    else
      {parent_eng: self, subEngs: sub_engineers.map { |s| s.rec_sub_engineers }}
    end
  end

  def deletable?
    TaskAction
    # !(ticket_workflow_process.present? or user_assign_ticket_actions.any? or sub_engineers.any?)
    status == 0
  end

  def root_engineer?
    channel_no.to_i == 1 and order_no.to_i == 1
  end

  has_many :dyna_columns, as: :resourceable, autosave: true

  [:group_no].each do |dyna_method|
    define_method(dyna_method) do
      dyna_columns.find_by_data_key(dyna_method).try(:data_value)
    end

    define_method("#{dyna_method}=") do |value|
      data = dyna_columns.find_or_initialize_by(data_key: dyna_method)
      data.data_value = (value.class==Fixnum ? value : value.strip)
      data.save# if data.persisted?
    end
  end

  def full_name
    user.full_name
  end

end

class TicketFsrSupportEngineer < ActiveRecord::Base
  self.table_name = "spt_ticket_fsr_support_eng"

  belongs_to :ticket_fsr, foreign_key: :fsr_id
  belongs_to :ticket_support_engineer, foreign_key: :engineer_support_id

end

class TicketSupportEngineer < ActiveRecord::Base
  self.table_name = "spt_ticket_engineer_support"

  belongs_to :ticket_engineer, foreign_key: :engineer_id
  belongs_to :user, foreign_key: :user_id

  def full_name
    user.full_name
  end
end