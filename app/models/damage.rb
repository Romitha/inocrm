class Damage < ActiveRecord::Base
  self.table_name = "inv_damage"

  belongs_to :grn_serial_item, foreign_key: :grn_serial_item_id
  belongs_to :grn_item, foreign_key: :grn_item_id
  belongs_to :grn_batch, foreign_key: :grn_batch_id
  belongs_to :inventory_serial_part, foreign_key: :serial_part_id
  belongs_to :inventory_reason, foreign_key: :damage_reason_id

end

class DamageRequest < ActiveRecord::Base
  self.table_name = "inv_damage_request"

  belongs_to :store, class_name: "Organization"
  belongs_to :inventory_product, foreign_key: :product_id
  belongs_to :damage_reason, -> { where(damage: true) }, class_name: "InventoryReason"

  belongs_to :created_by_user, class_name: "User", foreign_key: :created_by

  has_many :damage_request_sources
  accepts_nested_attributes_for :damage_request_sources, allow_destroy: true

end

class DamageRequestSource < ActiveRecord::Base
  self.table_name = "inv_damage_request_source"

  belongs_to :grn_item, foreign_key: :grn_item_id

end