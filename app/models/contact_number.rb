class ContactNumber < ActiveRecord::Base

  belongs_to :c_numberable, polymorphic: true

  TYPE = %w(Land Mobile Mail Fax Skype)
  validates :value, presence: true
end
