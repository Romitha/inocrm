class TicketSparePart < ActiveRecord::Base
  self.table_name = "spt_ticket_spare_part"

  belongs_to :ticket
  accepts_nested_attributes_for :ticket, allow_destroy: true

  has_one :ticket_spare_part_store, foreign_key: :spare_part_id

  belongs_to :ticket_fsr, foreign_key: :fsr_id
  belongs_to :spare_part_status_action, foreign_key: :status_action_id
  belongs_to :spare_part_status_use, foreign_key: :status_id

  has_many :request_spare_parts
  has_many :ticket_spare_part_status_actions, foreign_key: :spare_part_id

  has_one :ticket_spare_part_manufacture, foreign_key: :spare_part_id
  has_one :ticket_spare_part_store, foreign_key: :spare_part_id

  # validates_presence_of :fsr_id, :spare_part_no, :spare_part_description
end

class TicketSparePartStore < ActiveRecord::Base
  self.table_name = "spt_ticket_spare_part_store"

  belongs_to :ticket_spare_part, foreign_key: :spare_part_id
  belongs_to :inventory_product, foreign_key: :inv_product_id
end

class TicketFsr < ActiveRecord::Base
  self.table_name = "spt_ticket_fsr"

  belongs_to :ticket
  accepts_nested_attributes_for :ticket
  # validates_presence_of [:work_started_at, :work_finished_at, :hours_worked, :hours_worked, :down_time, :travel_hours, :engineer_time_travel, :engineer_time_on_site, :resolution, :completion_level]

  has_one :act_fsr, foreign_key: :fsr_id
  accepts_nested_attributes_for :act_fsr, allow_destroy: true

  has_many :ticket_spare_parts, foreign_key: :fsr_id
end

class TicketDeliverUnit < ActiveRecord::Base
  self.table_name = "spt_ticket_deliver_unit"

  belongs_to :ticket

  belongs_to :organization, foreign_key: :deliver_to_id
  has_many :deliver_units, foreign_key: :ticket_deliver_unit_id
end

class SparePartDescription < ActiveRecord::Base
  self.table_name = "mst_spt_spare_part_description"
end

class TicketSparePartManufacture < ActiveRecord::Base
  self.table_name = "spt_ticket_spare_part_manufacture"

  belongs_to :ticket_spare_part, foreign_key: :spare_part_id
end

class TicketSparePartStore < ActiveRecord::Base
  self.table_name = "spt_ticket_spare_part_store"

  belongs_to :ticket_spare_part, foreign_key: :spare_part_id
end

class SparePartStatusAction < ActiveRecord::Base
  self.table_name = "mst_spt_spare_part_status_action"

  has_many :ticket_spare_parts, foreign_key: :status_action_id
  has_many :ticket_spare_part_status_actions, foreign_key: :status_id
  has_many :ticket_on_loan_spare_part_status_actions, foreign_key: :status_id

end

class SparePartStatusUse < ActiveRecord::Base
  self.table_name = "mst_spt_spare_part_status_use"

  belongs_to :ticket_spare_part, foreign_key: :spare_part_id
  belongs_to :spare_part_status_action, foreign_key: :status_id
end

class TicketSparePartStatusAction < ActiveRecord::Base
  self.table_name = "spt_ticket_spare_part_status_action"

  has_many :ticket_spare_part, foreign_key: :status_use_id
  belongs_to :spare_part_status_action, foreign_key: :status_id
end

class TicketOnLoanSparePart < ActiveRecord::Base
  self.table_name = "spt_ticket_on_loan_spare_part"

  belongs_to :ticket_spare_part, foreign_key: :ref_spare_part_id
  belongs_to :ticket, foreign_key: :ticket_id
  belongs_to :user, foreign_key: :requested_by
  belongs_to :organization, foreign_key: :store_id
  belongs_to :inventory_product, foreign_key: :inv_product_id
  belongs_to :main_inventory_product, class_name: "InventoryProduct", foreign_key: :main_inv_product_id

  has_many :ticket_on_loan_spare_part_status_actions, foreign_key: :on_loan_spare_part_id
  accepts_nested_attributes_for :ticket_on_loan_spare_part_status_actions, allow_destroy: true
end

class TicketOnLoanSparePartStatusAction < ActiveRecord::Base
  self.table_name = "spt_ticket_on_loan_spare_part_status_action"

  belongs_to :user, foreign_key: :done_by
  belongs_to :spare_part_status_action, foreign_key: :status_id
  belongs_to :ticket_on_loan_spare_part, foreign_key: :on_loan_spare_part_id

end