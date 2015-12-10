class Grn < ActiveRecord::Base
  self.table_name = "inv_grn"

  belongs_to :store, class_name: "Organization"
  belongs_to :srn

  has_many :grn_items

end

class GrnItem < ActiveRecord::Base
  self.table_name = "inv_grn_item"

  belongs_to :srn_item
  belongs_to :grn
  belongs_to :inventory_product, foreign_key: :product_id
  belongs_to :currency

  has_many :grn_batches
  has_many :inventory_batches, through: :grn_batches

  has_many :grn_serial_items, foreign_key: :grn_item_id
  has_many :grn_items, through: :grn_serial_items
end

class GrnBatch < ActiveRecord::Base
  self.table_name = "inv_grn_batch"

  belongs_to :grn_item
  belongs_to :inventory_batch

end

class GrnSerialItem < ActiveRecord::Base
  self.table_name = "inv_grn_serial_item"

  belongs_to :grn_item, foreign_key: :grn_item_id
  belongs_to :inventory_serial_item, foreign_key: :serial_item_id

end