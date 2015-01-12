class User < ActiveRecord::Base

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

  belongs_to :department

  has_many :customer_tickets, foreign_key: "customer_id", class_name: "Ticket"

  has_many :agent_ticket_infos, foreign_key: "agent_id"
  has_many :tickets, through: :agent_ticket_infos

  validates_uniqueness_of :user_name

  # validates_presence_of :password, if: Proc.new {|user| user.is_customer? }

  attr_accessor :coord_x, :coord_y, :coord_w, :coord_h
  after_update :crop_avatar


  def crop_avatar
    avatar.recreate_versions! if coord_x.present?
  end

  TITLES = %w(Mr Mrs Miss Ms)

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
end
