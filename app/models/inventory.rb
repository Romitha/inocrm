class Inventory < ActiveRecord::Base
  self.table_name = "inv_inventory"

  belongs_to :organization, -> { where(type_id: 4) }, foreign_key: :store_id
  belongs_to :inventory_product, foreign_key: :product_id

  has_many :inventory_serial_items

  belongs_to :inventory_bin, foreign_key: :bin_id
end

class InventoryProduct < ActiveRecord::Base
  self.table_name = "mst_inv_product"

  belongs_to :inventory_category3, foreign_key: :category3_id

  has_many :inventories, foreign_key: :product_id

  belongs_to :inventory_unit, foreign_key: :unit_id
  has_many :inventory_serial_items, foreign_key: :product_id

  has_one :inventory_product_info, foreign_key: :product_id
  accepts_nested_attributes_for :inventory_product_info, allow_destroy: true

  has_many :ticket_spare_part_stores, foreign_key: :inv_product_id

  has_many :grn_items, foreign_key: :product_id

  has_many :inventory_serial_parts, foreign_key: :product_id

  has_many :inventory_serial_items
  has_many :ticket_spare_part_non_stocks, foreign_key: :inv_product_id
  has_many :approved_ticket_spare_part_non_stocks, class_name: "TicketSparePartNonStock", foreign_key: :approved_inv_product_id

  validates_presence_of [:description, :category3_id, :serial_no, :category3_id]

  def is_used_anywhere?
    inventory_category3.present? or inventories.any? or inventory_unit.present? or inventory_serial_items.any? or inventory_product_info.present? or ticket_spare_part_stores.any? or grn_items.any? or inventory_serial_parts.any? or inventory_serial_items.any? or ticket_spare_part_non_stocks.any? or approved_ticket_spare_part_non_stocks.any?
  end

  def generated_item_code
   "#{id}-#{serial_no}"
  end

end

class InventoryProductInfo < ActiveRecord::Base
  self.table_name = "mst_inv_product_info"

  belongs_to :inventory_product, foreign_key: :product_id

  belongs_to :manufacture, foreign_key: :manufacture_id

  belongs_to :product_sold_country, foreign_key: :country_id

  belongs_to :currency, foreign_key: :currency_id

  belongs_to :inventory_unit, foreign_key: :secondary_unit_id

  belongs_to :product_sold_country, foreign_key: :country_id

end

class InventoryCategory3 < ActiveRecord::Base
  self.table_name = "mst_inv_category3"

  belongs_to :inventory_category2, foreign_key: :category2_id
  has_many :inventory_products, foreign_key: :category3_id

  def is_used_anywhere?
    inventory_products.any?
  end
end

class InventoryCategory2 < ActiveRecord::Base
  self.table_name = "mst_inv_category2"

  belongs_to :inventory_category1, foreign_key: :category1_id

  has_many :inventory_category3s, foreign_key: :category2_id
  accepts_nested_attributes_for :inventory_category3s, allow_destroy: true
  has_many :inventory_products, through: :inventory_category3s

  def is_used_anywhere?
    inventory_category3s.any?
  end

end

class InventoryCategory1 < ActiveRecord::Base
  self.table_name = "mst_inv_category1"

  has_many :inventory_category2s, foreign_key: :category1_id
  accepts_nested_attributes_for :inventory_category2s, allow_destroy: true
  has_many :inventory_category3s, through: :inventory_category2s

  def is_used_anywhere?
    inventory_category2s.any?
  end

end

class InventoryCategoryCaption < ActiveRecord::Base
  self.table_name = "mst_inv_category_caption"
end

class Manufacture < ActiveRecord::Base
  self.table_name = "mst_inv_manufacture"

  has_one :inventory_product_info, foreign_key: :manufacture_id

  def is_used_anywhere?
    inventory_product_info.present?
  end

end

class InventoryUnit < ActiveRecord::Base
  self.table_name = "mst_inv_unit"

  has_many :inventory_products, foreign_key: :unit_id
  has_many :inventory_product_infos, foreign_key: :secondary_unit_id

  def is_used_anywhere?
    inventory_products.any? or inventory_product_infos.any?
  end

end

class InventoryBatch < ActiveRecord::Base
  self.table_name = "inv_inventory_batch"

  has_many :grn_batches
  has_many :grn_items, through: :grn_batches

  has_many :inventory_serial_items, foreign_key: :batch_id

  has_many :inventory_batch_warranties, foreign_key: :batch_id
  accepts_nested_attributes_for :inventory_batch_warranties, allow_destroy: true
  has_many :inventory_warranties, through: :inventory_batch_warranties

  belongs_to :inventory
  belongs_to :inventory_product, foreign_key: :product_id

  validates_presence_of [:inventory_id, :product_id, :created_by, :lot_no, :batch_no]

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

  has_many :inventory_serial_items_additional_costs, foreign_key: :serial_item_id

  has_many :inventory_serial_warranties, foreign_key: :serial_item_id
  accepts_nested_attributes_for :inventory_serial_warranties, allow_destroy: :true
  has_many :inventory_warranties, through: :inventory_serial_warranties

  has_many :grn_serial_parts, foreign_key: :serial_item_id
  has_many :grn_items, through: :grn_serial_parts

  validates_presence_of [:inventory_id, :product_id, :serial_no, :product_condition_id, :inv_status_id, :created_by]

end

class InventorySerialPart < ActiveRecord::Base
  self.table_name = "inv_inventory_serial_part"

  belongs_to :inventory_serial_item, foreign_key: :serial_item_id
  accepts_nested_attributes_for :inventory_serial_item, allow_destroy: true

  belongs_to :inventory_product, foreign_key: :product_id
  belongs_to :inventory_serial_item_status, foreign_key: :inv_status_id
  belongs_to :product_condition

  has_many :gin_sources, foreign_key: :grn_serial_part_id

  has_many :inventory_serial_part_additional_costs, foreign_key: :serial_part_id
  accepts_nested_attributes_for :inventory_serial_part_additional_costs, allow_destroy: true

  has_many :inventory_serial_part_warranties, foreign_key: :serial_part_id
  has_many :inventory_warranties, through: :inventory_serial_part_warranties
  has_many :damages
  has_many :grn_serial_parts, foreign_key: :inv_serial_part_id

  has_many :grn_serial_parts, foreign_key: :inv_serial_part_id
  has_many :grn_items, through: :grn_serial_parts

end

class ProductCondition < ActiveRecord::Base
  self.table_name = "mst_inv_product_condition"

  has_many :inventory_serial_items
  has_many :inventory_serial_parts

  def is_used_anywhere?
    inventory_serial_items.any? or inventory_serial_parts.any?
  end

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

class InventorySerialItemsAdditionalCost < ActiveRecord::Base
  self.table_name = "inv_serial_additional_cost"

  belongs_to :inventory_serial_item, foreign_key: :serial_item_id
end

class InventorySerialPartWarranty < ActiveRecord::Base
  self.table_name = "inv_serial_part_warranty"

  belongs_to :inventory_serial_part, foreign_key: :serial_part_id
  belongs_to :inventory_warranty, foreign_key: :warranty_id
end

class InventorySerialWarranty < ActiveRecord::Base
  self.table_name = "inv_serial_warranty"

  belongs_to :inventory_serial_item, foreign_key: :serial_item_id
  accepts_nested_attributes_for :inventory_serial_item, :allow_destroy => true

  belongs_to :inventory_warranty, foreign_key: :warranty_id
  accepts_nested_attributes_for :inventory_warranty, :allow_destroy => true
end

class InventoryBatchWarranty < ActiveRecord::Base
  self.table_name = "inv_batch_warranty"

  belongs_to :inventory_batch, foreign_key: :batch_id
  belongs_to :inventory_warranty, foreign_key: :warranty_id
  accepts_nested_attributes_for :inventory_warranty, allow_destroy: true
end

class InventoryWarranty < ActiveRecord::Base
  self.table_name = "inv_warranty"

  has_many :inventory_serial_part_warranties, foreign_key: :warranty_id
  has_many :inventory_serial_parts, through: :inventory_serial_part_warranties


  has_many :inventory_serial_warranties, foreign_key: :warranty_id
  has_many :inventory_warranties_for_serials, through: :inventory_batch_warranties, source: :inventory_warranty

  has_many :inventory_batch_warranties, foreign_key: :warranty_id
  has_many :inventory_warranties_for_batches, through: :inventory_batch_warranties, source: :inventory_warranty

  belongs_to :inventory_warranty_type, foreign_key: :warranty_type_id

  validates_presence_of [:warranty_type_id, :start_at, :end_at, :created_by]

end

class InventoryWarrantyType < ActiveRecord::Base
  self.table_name = "mst_inv_warranty_type"

  has_many :inventory_warranties, foreign_key: :warranty_type_id

end

class InventoryReason < ActiveRecord::Base
  self.table_name = "mst_inv_reason"

  has_many :damages, foreign_key: :damage_reason_id

  def is_used_anywhere?
    Damage
    damages.any?
  end

end

class InventoryRack < ActiveRecord::Base
  self.table_name = "mst_inv_rack"

  has_many :inventory_shelfs, foreign_key: :rack_id
  accepts_nested_attributes_for :inventory_shelfs, allow_destroy: true
  belongs_to :organization, foreign_key: :location_id
  belongs_to :user, foreign_key: :created_by
  belongs_to :user, foreign_key: :updated_by

  def is_used_anywhere?
    inventory_shelfs.any?
  end

end

class InventoryShelf < ActiveRecord::Base
  self.table_name = "mst_inv_shelf"

  has_many :inventory_bins, foreign_key: :shelf_id
  accepts_nested_attributes_for :inventory_bins, allow_destroy: true
  belongs_to :inventory_rack, foreign_key: :rack_id
  belongs_to :user, foreign_key: :created_by
  belongs_to :user, foreign_key: :updated_by

  def is_used_anywhere?
    inventory_bins.any?
  end
end

class InventoryBin < ActiveRecord::Base
  self.table_name = "mst_inv_bin"

  belongs_to :inventory_shelf, foreign_key: :shelf_id
  belongs_to :user, foreign_key: :created_by
  belongs_to :user, foreign_key: :updated_by
  has_many :inventories, foreign_key: :bin_id

  def is_used_anywhere?
    inventories.any?
  end

end

class InventoryDisposalMethod < ActiveRecord::Base
  self.table_name = "mst_inv_disposal_method"

  belongs_to :user, foreign_key: :created_by
  belongs_to :user, foreign_key: :updated_by
  has_many :inventory_damages, foreign_key: :disposal_method_id
  has_many :inventory_requests, foreign_key: :disposal_method_id

  def is_used_anywhere?
    # inventory_damages.any? or inventory_requests.any? or user.present?
    inventory_damages.any?
  end

end

class InventoryDamage < ActiveRecord::Base
  self.table_name = "inv_damage"
  belongs_to :inventory_disposal_method
end

class InventoryRequest < ActiveRecord::Base
  self.table_name = "inv_disposal_request"
  belongs_to :inventory_disposal_method
end

class InventoryPo < ActiveRecord::Base
  self.table_name = "inv_po"

  belongs_to :supplier, class_name: "Organization", foreign_key: :supplier_id
  belongs_to :store, class_name: "Organization", foreign_key: :store_id
  belongs_to :created_by_user, class_name: "User", foreign_key: :created_by
  belongs_to :approved_by_user, class_name: "User", foreign_key: :approved_by

  has_many :inventory_po_items, foreign_key: :po_id
end

class InventoryPoItem < ActiveRecord::Base
  self.table_name = "inv_po_item"

  belongs_to :inventory_po, foreign_key: :po_id
  belongs_to :inventory_prn_item, foreign_key: :prn_item_id

  has_many :grn_items, foreign_key: :po_item_id
  accepts_nested_attributes_for :grn_items, allow_destroy: true
  has_many :grns, through: :grn_items

  has_many :dyna_columns, as: :resourceable, autosave: true

  [:temp_id].each do |dyna_method|
    define_method(dyna_method) do
      dyna_columns.find_by_data_key(dyna_method).try(:data_value)
    end

    define_method("#{dyna_method}=") do |value|
      data = dyna_columns.find_or_initialize_by(data_key: dyna_method)
      data.data_value = (value.class==Fixnum ? value : value.strip)
      data.save# if data.persisted?
    end
  end
end

class InventoryPrn < ActiveRecord::Base
  self.table_name = "inv_prn"

  belongs_to :store, class_name: "Organization", foreign_key: :store_id
  belongs_to :created_by_user, class_name: "User", foreign_key: :created_by

  has_many :inventory_prn_items, foreign_key: :prn_id
end

class InventoryPrnItem < ActiveRecord::Base
  self.table_name = "inv_prn_item"

  belongs_to :inventory_prn, foreign_key: :prn_id
  belongs_to :inventory_product, foreign_key: :product_id

  has_many :po_items, foreign_key: :prn_item_id
end