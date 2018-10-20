class Designation < ActiveRecord::Base

  # belongs_to :user

  belongs_to :organization

  has_many :users

  validates_presence_of [:name, :description]
  validates_uniqueness_of :name, scope: :organization_id

end