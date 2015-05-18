class QAndA < ActiveRecord::Base
  self.table_name = "mst_spt_problematic_question"

  belongs_to :problem_category, foreign_key: :problem_category_id
  belongs_to :task_action, foreign_key: :action_id

  has_many :q_and_answers, foreign_key: :problematic_question_id
  has_many :tickets, through: :q_and_answers
  accepts_nested_attributes_for :q_and_answers, allow_destroy: true
end

class QAndAnswer < ActiveRecord::Base
  self.table_name = "spt_ticket_problematic_question_answer"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  belongs_to :q_and_a, foreign_key: :problematic_question_id
  belongs_to :ticket

  validates_presence_of :answer, if: Proc.new{|q_and_answer| q_and_answer.q_and_a.try(:compulsory) == true}
end

class GeQAndA < ActiveRecord::Base
  self.table_name = "mst_spt_general_question"

  belongs_to :task_action, foreign_key: :action_id

  has_many :ge_q_and_answers, foreign_key: :general_question_id
  accepts_nested_attributes_for :ge_q_and_answers, allow_destroy: true
end

class GeQAndAnswer < ActiveRecord::Base
  self.table_name = "spt_ticket_general_question_answer"

  belongs_to :user_ticket_action, foreign_key: :ticket_action_id

  belongs_to :ge_q_and_a, foreign_key: :general_question_id
  belongs_to :ticket

  validates_presence_of :answer, if: Proc.new{|ge_q_and_answer| ge_q_and_answer.ge_q_and_a.try(:compulsory) == true}
end