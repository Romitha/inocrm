module Documents
  class ContractDocument < ApplicationRecord
    self.table_name = "mst_spt_contract_brand_document"
    mount_uploader :document_file_name, DocumentAttachmentUploader

    belongs_to :proudct_brand

  end

  class Annexture < ApplicationRecord
    self.table_name = "mst_spt_contract_annexture"
    mount_uploader :document_url, DocumentAttachmentUploader

  end

  class ContractAttachment < ApplicationRecord
    self.table_name = "spt_contract_attachment"
    mount_uploader :attachment_url, DocumentAttachmentUploader

    belongs_to :ticket_contract, foreign_key: :contract_id

  end
end