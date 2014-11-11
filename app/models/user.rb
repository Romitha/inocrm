class User < ActiveRecord::Base
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

  validates_uniqueness_of :user_name

  TITLES = %w(Mr Mrs Miss Ms)

  def other_addresses
    addresses.where.not(primary: true)
  end

  def primary_address
    addresses.find_by_primary true
  end

end
