class ContactNumber < ActiveRecord::Base

  belongs_to :c_numberable, polymorphic: true

  TYPES = %w(Land Mobile Mail Fax Skype)
  validates :value, presence: true
  validates :category, presence: true

  scope :primary_contactnumber, -> {where(primary: true)}
  scope :nonprimary_contactnumber, -> {where(primary: false)}
end