class Srn < ActiveRecord::Base
  self.table_name = "inv_srn"

  belongs_to :store, -> { where(type_id: 4) }, class_name: "Organization"
  belongs_to :requested_location, class_name: "Organization"

  has_many :srn_items
  accepts_nested_attributes_for :srn_items, allow_destroy: true
  has_many :inventory_products, through: :srn_items
  has_many :gins
  has_many :ticket_spare_part_stores, foreign_key: :inv_srn_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :inv_srn_id
end

class SrnItem < ActiveRecord::Base
  self.table_name = "inv_srn_item"

  belongs_to :srn
  belongs_to :product

  has_many :ticket_spare_part_stores, foreign_key: :inv_srn_item_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :inv_srn_item_id
end