class TicketEstimation < ActiveRecord::Base
  self.table_name = "spt_ticket_estimation"

  belongs_to :ticket

  has_many :ticket_estimation_externals, foreign_key: :ticket_estimation_id
  accepts_nested_attributes_for :ticket_estimation_externals, allow_destroy: true

  has_many :job_estimations, foreign_key: :ticket_estimation_id
  accepts_nested_attributes_for :job_estimations, allow_destroy: true

  has_many :act_job_estimations, foreign_key: :ticket_estimation_id
  accepts_nested_attributes_for :act_job_estimations, allow_destroy: true

  has_many :ticket_estimation_parts, foreign_key: :ticket_estimation_id
  accepts_nested_attributes_for :ticket_estimation_parts, allow_destroy: true

  has_many :ticket_estimation_additionals, foreign_key: :ticket_estimation_id
  accepts_nested_attributes_for :ticket_estimation_additionals, allow_destroy: true

  belongs_to :estimation_status, foreign_key: :status_id
  belongs_to :currency, foreign_key: :currency_id

  belongs_to :ticket_payment_received, foreign_key: :adv_payment_received_id
end

class TicketEstimationExternal < ActiveRecord::Base
  self.table_name = "spt_ticket_estimation_external"

  belongs_to :ticket

  belongs_to :ticket_estimation#, foreign_key: :ticket_estimation_id
  accepts_nested_attributes_for :ticket_estimation, allow_destroy: true

  belongs_to :organization, foreign_key: :repair_by_id
  accepts_nested_attributes_for :organization, allow_destroy: true

end

class EstimationStatus < ActiveRecord::Base
  self.table_name = "mst_spt_estimation_status"

  has_many :ticket_estimations, foreign_key: :status_id

end

class TicketEstimationPart < ActiveRecord::Base
  self.table_name = "spt_ticket_estimation_part"

  belongs_to :ticket_estimation, foreign_key: :ticket_estimation_id
  belongs_to :ticket, foreign_key: :ticket_id

  # has_many :ticket_spare_part_stores, foreign_key: :ticket_estimation_part_id

  belongs_to :supplier, class_name: "Organization", foreign_key: :supplier_id

  belongs_to :ticket_spare_part, foreign_key: :ticket_spare_part_id

end

class TicketEstimationAdditional < ActiveRecord::Base
  self.table_name = "spt_ticket_estimation_additional"

  belongs_to :ticket_estimation, foreign_key: :ticket_estimation_id
  belongs_to :ticket, foreign_key: :ticket_id

  belongs_to :additional_charge, foreign_key: :additional_charge_id

end

class AdditionalCharge < ActiveRecord::Base
  self.table_name = "mst_spt_additional_charge"

  has_many :ticket_estimation_additionals, foreign_key: :additional_charge_id

end

class TicketPaymentReceived < ActiveRecord::Base
  self.table_name = "spt_ticket_payment_received"

  has_many :ticket_estimations, foreign_key: :adv_payment_received_id
  has_many :act_payment_received, foreign_key: :ticket_payment_received_id

  belongs_to :ticket

end