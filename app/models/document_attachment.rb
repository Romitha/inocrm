class DocumentAttachment < ActiveRecord::Base
  mount_uploader :file_path, DocumentAttachmentUploader

  belongs_to :organization
end
