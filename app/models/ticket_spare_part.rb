class TicketSparePart < ActiveRecord::Base
  self.table_name = "spt_ticket_spare_part"

  belongs_to :ticket

  has_one :ticket_spare_part_store, foreign_key: :spare_part_id
end

class TicketSparePartStore < ActiveRecord::Base
  self.table_name = "spt_ticket_spare_part_store"

  belongs_to :ticket_spare_part, foreign_key: :spare_part_id
  belongs_to :inventory_product, foreign_key: :inv_product_id
end

class TicketFsr < ActiveRecord::Base
  self.table_name = "spt_ticket_fsr"

  belongs_to :ticket
  validates_presence_of :work_started_at, :work_finished_at, :hours_worked, :hours_worked, :down_time,
  :travel_hours, :engineer_time_travel, :engineer_time_on_site, :resolution, :completion_level
end

class TicketDeliveryUnit < ActiveRecord::Base
  self.table_name = "spt_ticket_delivery_unit"

  belongs_to :ticket
end