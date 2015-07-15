class Warranty < ActiveRecord::Base
  self.table_name = "spt_product_serial_warranty"
  belongs_to :warranty_type

  belongs_to :product, foreign_key: :product_serial_id

  validates_presence_of [:warranty_type_id, :start_at, :end_at]
end

class WarrantyType < ActiveRecord::Base
  self.table_name = "mst_spt_warranty_type"

  has_many :warranties

  has_many :tickets

  has_many :action_warranty_repair_types, foreign_key: :ticket_warranty_type_id
end

class ActionWarrantyRepairType < ActiveRecord::Base
  self.table_name = "spt_act_warranty_repair_type"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  belongs_to :ticket_repair_type, foreign_key: :ticket_repair_type_id

  belongs_to :warranty_type, foreign_key: :ticket_warranty_type_id

end