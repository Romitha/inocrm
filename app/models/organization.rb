class Organization < ActiveRecord::Base
	mount_uploader :logo, LogoUploader

	has_many :addresses

	accepts_nested_attributes_for :addresses, allow_destroy: true

end
