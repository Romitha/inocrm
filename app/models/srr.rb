class Srr < ActiveRecord::Base
  self.table_name = "inv_srr"

  belongs_to :store, class_name: "Organization"
  belongs_to :requested_location, class_name: "Organization"
  belongs_to :user

  has_many :srr_items
  accepts_nested_attributes_for :srr_items, allow_destroy: true
  has_many :ticket_spare_part_stores, foreign_key: :inv_srr_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :inv_srr_id
end

class SrrItem < ActiveRecord::Base
  self.table_name = "inv_srr_item"

  belongs_to :srr
  belongs_to :inventory_product, foreign_key: :product_id
  belongs_to :product

  has_many :srr_item_sources
  accepts_nested_attributes_for :srr_item_sources, allow_destroy: true
  has_many :gin_sources, through: :srr_item_sources

  has_many :ticket_spare_part_stores, foreign_key: :inv_srr_item_id
  has_many :ticket_on_loan_spare_parts, foreign_key: :inv_srr_item_id
end

class SrrItemSource < ActiveRecord::Base
  self.table_name = "inv_srr_item_source"

  belongs_to :gin_source#, foreign_key: :grn_item_id
  belongs_to :srr_item#, foreign_key: :gin_item_id
end
