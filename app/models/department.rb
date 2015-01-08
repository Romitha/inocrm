class Department < ActiveRecord::Base
  belongs_to :organization

  has_many :users

  has_many :tickets
end
