class TicketSparePart < ActiveRecord::Base
  self.table_name = "spt_ticket_spare_part"

  belongs_to :ticket

  has_one :ticket_spare_part_store, foreign_key: :spare_part_id

  belongs_to :ticket_fsr, foreign_key: :fsr_id

  has_many :request_spare_parts

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