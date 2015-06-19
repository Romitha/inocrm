class TaskAction < ActiveRecord::Base
  self.table_name = "mst_spt_action"

  has_many :q_and_as, foreign_key: :action_id

  has_many :ge_q_and_as, foreign_key: :action_id

  has_many :user_ticket_actions, foreign_key: :action_id
end

class UserTicketAction < ActiveRecord::Base
  self.table_name = "spt_ticket_action"

  has_many :q_and_answers, foreign_key: :ticket_action_id

  has_many :ge_q_and_answers, foreign_key: :ticket_action_id

  belongs_to :ticket
  belongs_to :task_action, foreign_key: :action_id

  has_many :user_assign_ticket_actions, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :user_assign_ticket_actions, allow_destroy: true

  has_many :assign_regional_support_centers, foreign_key: :ticket_action_id
  accepts_nested_attributes_for :assign_regional_support_centers, allow_destroy: true
end

class UserAssignTicketAction < ActiveRecord::Base
  self.table_name = "spt_act_assign_ticket"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id
  belongs_to :mst_spt_sbu, foreign_key: :sbu_id
end

class AssignRegionalSupportCenter < ActiveRecord::Base
  self.table_name = "spt_act_assign_regional_support_center"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  belongs_to :regional_support_center
end

class RegionalSupportCenter < ActiveRecord::Base
  self.table_name = "spt_regional_support_center"

  has_many :assign_regional_support_centers
end

class MstSptSbu < ActiveRecord::Base
  self.table_name = "mst_spt_sbu"

  has_many :spt_sbu_engineers, foreign_key: :sbu_id
  has_many :engineers, through: :spt_sbu_engineers
end

class SptSbuEngineer < ActiveRecord::Base
  self.table_name = "mst_spt_sbu_engineer"

  belongs_to :mst_spt_sbu, foreign_key: :sbu_id
  belongs_to :engineers, foreign_key: :engineer_id
end