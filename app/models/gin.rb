class Gin < ActiveRecord::Base
  self.table_name = "inv_gin"
  belongs_to :store, class_name: "Organization"
  belongs_to :srn
  belongs_to :user

  has_many :gin_items
  has_many :ticket_spare_part_stores, foreign_key: :inv_gin_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :inv_gin_id
end

class GinItem < ActiveRecord::Base
  self.table_name = "inv_gin_item"

  belongs_to :gin
  belongs_to :inventory_product, foreign_key: :product_id
  belongs_to :srn_item, foreign_key: :srn_item_id
  belongs_to :currency

  has_many :gin_sources#, foreign_key: :gin_item_id
  has_many :ticket_spare_part_stores, foreign_key: :inv_gin_item_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :inv_gin_item_id
end

class GinSource < ActiveRecord::Base
  self.table_name = "inv_gin_source"

  belongs_to :gin_item#, foreign_key: :gin_item_id
  belongs_to :grn_item#, foreign_key: :grn_item_id
  belongs_to :grn_batch#, foreign_key: :gin_item_id
  belongs_to :grn_serial_item#, foreign_key: :gin_item_id
  belongs_to :inventory_serial_part, foreign_key: :serial_part_id
  belongs_to :main_part_grn_serial_item, class_name: "GrnSerialItem", foreign_key: :main_part_grn_serial_item_id

  has_many :srr_item_sources
  has_many :srr_items, through: :srr_item_sources
end