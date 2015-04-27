class TaskAction < ActiveRecord::Base
  self.table_name = "mst_spt_action"

  has_many :q_and_as, foreign_key: :action_id
end

class UserTicketAction < ActiveRecord::Base
  self.table_name = "spt_ticket_action"

  has_many :q_and_answers, foreign_key: :ticket_action_id
end