class Inventory < ActiveRecord::Base
  self.table_name = "inv_inventory"

  belongs_to :organization, -> { where(type_id: 4) }, foreign_key: :store_id
  belongs_to :inventory_product, foreign_key: :product_id

  has_many :inventory_serial_items
end

class InventoryProduct < ActiveRecord::Base
  self.table_name = "mst_inv_product"

  belongs_to :inventory_category3, foreign_key: :category3_id

  has_many :inventories, foreign_key: :product_id

  belongs_to :inventory_unit, foreign_key: :unit_id
  has_many :inventory_serial_items, foreign_key: :product_id

  has_one :inventory_product_info, foreign_key: :product_id

  has_many :ticket_spare_part_stores, foreign_key: :inv_product_id

  has_many :grn_items, foreign_key: :product_id

  has_many :inventory_serial_parts, foreign_key: :product_id

  def generated_item_code
   "#{id}-#{serial_no}"
  end

end

class InventoryProductInfo < ActiveRecord::Base
  self.table_name = "mst_inv_product_info"

  belongs_to :inventory_product, foreign_key: :product_id

  belongs_to :manufacture, foreign_key: :manufacture_id

end

class InventoryCategory3 < ActiveRecord::Base
  self.table_name = "mst_inv_category3"

  belongs_to :inventory_category2, foreign_key: :category2_id
  has_many :inventory_products, foreign_key: :category3_id
end

class InventoryCategory2 < ActiveRecord::Base
  self.table_name = "mst_inv_category2"

  belongs_to :inventory_category1, foreign_key: :category1_id

  has_many :inventory_category3s, foreign_key: :category2_id
end

class InventoryCategory1 < ActiveRecord::Base
  self.table_name = "mst_inv_category1"

  has_many :inventory_category2s, foreign_key: :category1_id

end

class InventoryCategoryCaption < ActiveRecord::Base
  self.table_name = "mst_inv_category_caption"
end

class Manufacture < ActiveRecord::Base
  self.table_name = "mst_inv_manufacture"

  has_one :inventory_product_info, foreign_key: :manufacture_id

end

class InventoryUnit < ActiveRecord::Base
  self.table_name = "mst_inv_unit"

  has_many :inventory_products, foreign_key: :unit_id

end

class InventoryBatch < ActiveRecord::Base
  self.table_name = "inv_inventory_batch"

  has_many :grn_batches
  has_many :grn_items, through: :grn_batches
  has_many :inventory_serial_items, foreign_key: :batch_id

end

class InventorySerialItem < ActiveRecord::Base
  self.table_name = "inv_inventory_serial_item"

  belongs_to :inventory_batch, foreign_key: :batch_id
  belongs_to :inventory
  belongs_to :product_condition
  belongs_to :inventory_serial_item_status, foreign_key: :inv_status_id
  belongs_to :inventory_product, foreign_key: :product_id

  has_many :inventory_serial_parts, foreign_key: :serial_item_id

  has_many :grn_serial_items, foreign_key: :serial_item_id
  has_many :grn_items, through: :grn_serial_items
  has_many :inventory_serial_additional_costs, through: :serial_item_id
  has_many :inventory_serial_warrantys, through: :serial_item_id

end

class InventorySerialPart < ActiveRecord::Base
  self.table_name = "inv_inventory_serial_part"

  belongs_to :inventory_serial_item, foreign_key: :serial_item_id
  belongs_to :inventory_product, foreign_key: :product_id
  belongs_to :inventory_serial_item_status, foreign_key: :inv_status_id
  has_many :gin_sources, foreign_key: :serial_part_id

  has_many :inventory_serial_part_additional_costs, foreign_key: :serial_part_id
  has_many :inventory_serial_part_warrantys, foreign_key: :serial_part_id
  has_many :damages

end

class ProductCondition < ActiveRecord::Base
  self.table_name = "mst_inv_product_condition"

  has_many :inventory_serial_items

end

class InventorySerialItemStatus < ActiveRecord::Base
  self.table_name = "mst_inv_serial_item_status"

  has_many :inventory_serial_items, foreign_key: :inv_status_id
  has_many :inventory_serial_parts, foreign_key: :inv_status_id
end

class InventorySerialPartAdditionalCost < ActiveRecord::Base
  self.table_name = "inv_serial_part_additional_cost"

  belongs_to :inventory_serial_part, foreign_key: :serial_part_id
  belongs_to :currency
end

class InventorySerialAdditionalCost < ActiveRecord::Base
  self.table_name = "inv_serial_additional_cost"

  belongs_to :inventory_serial_item, foreign_key: :serial_item_id
end

class InventorySerialPartWarranty < ActiveRecord::Base
  self.table_name = "inv_serial_part_warranty"

  belongs_to :inventory_serial_part, foreign_key: :serial_part_id
  belongs_to :inventory_warranty
end

class InventorySerialWarranty < ActiveRecord::Base
  self.table_name = "inv_serial_warranty"

  belongs_to :inventory_serial_item, foreign_key: :serial_item_id
  accepts_nested_attributes_for :inventory_serial_item, :allow_destroy => true
  belongs_to :inventory_warranty
  accepts_nested_attributes_for :inventory_warranty, :allow_destroy => true
end

class InventoryWarranty < ActiveRecord::Base
  self.table_name = "inv_warranty"

  has_many :inventory_serial_part_warrantys, foreign_key: :warranty_id
  has_many :inventory_serial_warrantys, foreign_key: :warranty_id

end

class InventoryReason < ActiveRecord::Base
  self.table_name = "mst_inv_reason"
  
  has_many :damages
end
