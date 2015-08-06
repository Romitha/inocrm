class TicketEstimation < ActiveRecord::Base
  self.table_name = "spt_ticket_estimation"

  belongs_to :ticket

  has_many :ticket_estimation_externals, foreign_key: :ticket_estimation_id

  has_many :job_estimations, foreign_key: :ticket_estimation_id
  accepts_nested_attributes_for :job_estimations, allow_destroy: true

  has_many :ticket_estimation_parts, foreign_key: :ticket_estimation_id
  accepts_nested_attributes_for :ticket_estimation_parts, allow_destroy: true

  belongs_to :estimation_status, foreign_key: :status_id
  belongs_to :currency, foreign_key: :currency_id

end

class TicketEstimationExternal < ActiveRecord::Base
  self.table_name = "spt_ticket_estimation_external"

  belongs_to :ticket

  belongs_to :ticket_estimation#, foreign_key: :ticket_estimation_id

  belongs_to :organization, foreign_key: :repair_by_id

end

class EstimationStatus < ActiveRecord::Base
  self.table_name = "mst_spt_estimation_status"

  has_many :ticket_estimations, foreign_key: :status_id

end

class TicketEstimationPart < ActiveRecord::Base
  self.table_name = "spt_ticket_estimation_part"

  belongs_to :ticket_estimation, foreign_key: :ticket_estimation_id
  belongs_to :ticket, foreign_key: :ticket_id

end