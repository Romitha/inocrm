class Address < ActiveRecord::Base
    #Users and Organizations have multiple addresses
    belongs_to :addressable, polymorphic: true

    TYPES = %w(Billing Shipping Support Office Home)

    validates :address, presence: true
    validates :category, presence: true

    validates_uniqueness_of :primary, conditions: -> { where(primary: true)}, scope: [:addressable_id, :addressable_type]

end