class Organization < ActiveRecord::Base
	mount_uploader :logo, LogoUploader
end
