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
  has_many :inventory_serial_item_for_grn_serial_items, through: :grn_serial_items, through: :inventory_serial_item

  has_many :grn_serial_parts, foreign_key: :grn_item_id
  has_many :inventory_serial_item_for_grn_serial_parts, through: :grn_serial_parts, through: :inventory_serial_item
  has_many :inventory_serial_parts, through: :grn_serial_parts

  has_many :damages
  accepts_nested_attributes_for :damages, allow_destroy: true

  has_many :gin_sources
end

class GrnBatch < ActiveRecord::Base
  self.table_name = "inv_grn_batch"

  belongs_to :grn_item
  belongs_to :inventory_batch

  has_many :gin_sources
  has_many :damages

end

class GrnSerialItem < ActiveRecord::Base
  self.table_name = "inv_grn_serial_item"

  belongs_to :grn_item, foreign_key: :grn_item_id
  belongs_to :inventory_serial_item, foreign_key: :serial_item_id

  has_many :gin_sources#, foreign_key: :gin_item_id
  has_many :damages

end

class GrnSerialPart < ActiveRecord::Base
  self.table_name = "inv_grn_serial_part"

  belongs_to :grn_item
  belongs_to :inventory_serial_item, foreign_key: :serial_item_id
  belongs_to :inventory_serial_part, foreign_key: :inv_serial_part_id

  has_many :gin_sources, foreign_key: :grn_serial_part_id

end