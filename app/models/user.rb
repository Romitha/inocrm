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

end
