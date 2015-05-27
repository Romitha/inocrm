class User < ActiveRecord::Base
  # self.table_name = "users"

  belongs_to :mst_title, foreign_key: :title_id

  mount_uploader :avatar, AvatarUploader

  rolify
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

  # belongs_to :department

  has_many :customer_tickets, foreign_key: "customer_id", class_name: "Ticket"

  # has_many :comments, foreign_key: "agent_id"

  validates_uniqueness_of :user_name

  # validates_presence_of :password, if: Proc.new {|user| user.is_customer? }

  attr_accessor :coord_x, :coord_y, :coord_w, :coord_h
  after_update :crop_avatar


  def crop_avatar
    avatar.recreate_versions! if coord_x.present?
  end

  def other_addresses
    addresses.where.not(primary: true)
  end

  def primary_address
    addresses.find_by_primary true
  end

  def primary_contact_number
    contact_numbers.find_by_primary true
  end

  def other_contact_numbers
    contact_numbers.where.not(primary: true)    
  end

  has_many :dyna_columns, as: :resourceable

  has_many :invoices, foreign_key: "customer_id"

  [:current_user_role_id, :current_user_role_name, :is_customer].each do |dyna_method|
    define_method(dyna_method) do
      dyna_columns.find_by_data_key(dyna_method).try(:data_value)
    end

    define_method("#{dyna_method}=") do |value|
      data = dyna_columns.find_or_initialize_by(data_key: dyna_method)
      data.data_value = (value.class==Fixnum ? value : value.strip)
      @is_customer = data.data_value if dyna_method==:is_customer
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
    "#{first_name} #{last_name}"
  end

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
    addresses.find_by_primary(true)
  end

  def primary_address=(address)
    self.addresses.build(category: "Support", address: address, primary: true)
  end

end

class MstTitle < ActiveRecord::Base
  self.table_name = "mst_title"
  has_one :user, foreign_key: :title_id
  has_one :customer, foreign_key: :title_id
end

class Customer < ActiveRecord::Base
  self.table_name = "spt_customer"

  has_many :tickets, foreign_key: :customer_id

  has_many :contact_type_values, foreign_key: :customer_id
  has_many :contact_types, through: :contact_type_values
  accepts_nested_attributes_for :contact_type_values, :allow_destroy => true

  belongs_to :mst_title, foreign_key: :title_id

  validates_presence_of [:title_id, :name, :address1, :address4]

  belongs_to :district, foreign_key: :district_id

  belongs_to :organization
end

class ContactPerson1 < ActiveRecord::Base
  self.table_name = "spt_contact_report_person"

  has_many :tickets, foreign_key: :contact_person1_id
  has_many :regular_customers

  has_many :contact_person_contact_types, foreign_key: :contact_report_person_id
  has_many :contact_types, through: :contact_person_contact_types
  accepts_nested_attributes_for :contact_person_contact_types, allow_destroy: true, reject_if: :all_blank


  belongs_to :mst_title, foreign_key: :title_id
  validates_presence_of [:title_id, :name]
end

class ContactPerson2 < ActiveRecord::Base
  self.table_name = "spt_contact_report_person"

  has_many :tickets, foreign_key: :contact_person2_id
  has_many :regular_customers

  has_many :contact_person_contact_types, foreign_key: :contact_report_person_id
  has_many :contact_types, through: :contact_person_contact_types
  accepts_nested_attributes_for :contact_person_contact_types, allow_destroy: true, reject_if: :all_blank


  belongs_to :mst_title, foreign_key: :title_id
  validates_presence_of [:title_id, :name]
end

class ReportPerson < ActiveRecord::Base
  self.table_name = "spt_contact_report_person"
  has_many :tickets, foreign_key: :reporter_id

  has_many :contact_person_contact_types, foreign_key: :contact_report_person_id
  has_many :contact_types, through: :contact_person_contact_types
  accepts_nested_attributes_for :contact_person_contact_types, allow_destroy: true, reject_if: :all_blank

  
  belongs_to :mst_title, foreign_key: :title_id
  validates_presence_of [:title_id, :name]
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
end