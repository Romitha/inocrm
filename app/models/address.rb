class Address < ActiveRecord::Base
    #Users and Organizations have multiple addresses
    belongs_to :addressable, polymorphic: true

    TYPE = %w(Billing Shipping Support Office Home)

		validates :address, presence: true

end
