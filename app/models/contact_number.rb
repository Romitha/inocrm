class ContactNumber < ActiveRecord::Base

  belongs_to :c_numberable, polymorphic: true

  TYPES = %w(Land Mobile Mail Fax Skype)
  validates :value, presence: true
  validates :category, presence: true

end