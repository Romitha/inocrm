class Address < ActiveRecord::Base

	belongs_to :organization

	TYPE = %w(Billing Shipping Support Office Home)
	validates :address, presence: true

end
