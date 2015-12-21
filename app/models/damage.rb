class Damage < ActiveRecord::Base
  self.table_name = "inv_damage"

  belongs_to :grn_serial_item, foreign_key: :grn_serial_item_id
  belongs_to :grn_item, foreign_key: :grn_item_id
  belongs_to :grn_batch, foreign_key: :grn_batch_id
  belongs_to :inventory_serial_part, foreign_key: :serial_part_id
  belongs_to :inventory_reason, foreign_key: :damage_reason_id
end
