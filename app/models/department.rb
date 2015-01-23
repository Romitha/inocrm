class Department < ActiveRecord::Base
  belongs_to :organization

  has_many :users

  has_many :tickets

  validates_uniqueness_of :name, scope: :organization_id
end
