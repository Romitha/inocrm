class Srn < ActiveRecord::Base
  self.table_name = "inv_srn"

  belongs_to :store, -> { where(type_id: 4) }, class_name: "Organization"
  belongs_to :requested_location, class_name: "Organization"
  belongs_to :so_customer, class_name: "Organization"
  belongs_to :requested_module, class_name: "BpmModule", foreign_key: :requested_module_id
  belongs_to :created_by_user, class_name: "User", foreign_key: :created_by

  has_many :srn_items
  accepts_nested_attributes_for :srn_items, allow_destroy: true
  has_many :inventory_products, through: :srn_items
  has_many :gins
  accepts_nested_attributes_for :gins, allow_destroy: true
  has_many :ticket_spare_part_stores, foreign_key: :inv_srn_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :inv_srn_id
end

class SrnItem < ActiveRecord::Base
  self.table_name = "inv_srn_item"

  belongs_to :srn
  belongs_to :inventory_product, foreign_key: :product_id
  belongs_to :main_inventory_product, class_name: "InventoryProduct", foreign_key: :main_product_id

  has_many :ticket_spare_part_stores, foreign_key: :inv_srn_item_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :inv_srn_item_id
  has_many :gin_items
  has_many :gins, through: :gin_items
end