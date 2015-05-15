class Warranty < ActiveRecord::Base
  self.table_name = "spt_product_serial_warranty"
  belongs_to :warranty_type

  belongs_to :product, foreign_key: :product_serial_id

  validates_presence_of [:warranty_type_id, :start_at, :end_at]
end

class WarrantyType < ActiveRecord::Base
  self.table_name = "mst_spt_warranty_type"

  has_many :warranties

  has_many :tickets
end