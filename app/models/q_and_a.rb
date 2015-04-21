class QAndA < ActiveRecord::Base
  self.table_name = "mst_spt_problematic_question"

  belongs_to :problem_category, foreign_key: :problem_category_id
  belongs_to :task_action, foreign_key: :action_id
end
