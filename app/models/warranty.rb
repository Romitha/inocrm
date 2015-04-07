class Warranty < ActiveRecord::Base
	self.table_name = "spt_product_serial_warranty"
	belongs_to :warranty_type
end

class WarrantyType < ActiveRecord::Base
	self.table_name = "mst_spt_warranty_type"

	has_many :warranties
end