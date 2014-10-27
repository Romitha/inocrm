class ContactNumber < ActiveRecord::Base

  belongs_to :organization

  TYPE = %w(Land Mobile Mail Fax Skype)
  validates :value, presence: true
end
