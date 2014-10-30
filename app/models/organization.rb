class Organization < ActiveRecord::Base
  mount_uploader :logo, LogoUploader

  has_many :addresses, as: :addressable
  accepts_nested_attributes_for :addresses, allow_destroy: true

	has_many :contact_numbers
	accepts_nested_attributes_for :contact_numbers, allow_destroy: true

  has_many :designations

	validates_format_of :web_site, :with => URI::regexp(%w(http https))
end