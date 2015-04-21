class TaskAction < ActiveRecord::Base
  self.table_name = "mst_spt_action"

  has_many :q_and_as, foreign_key: :action_id
end
