class WorkflowMapping < ActiveRecord::Base
  self.table_name = "workflow_mappings"
end

class WorkflowHeaderTitle < ActiveRecord::Base
  self.table_name = "workflow_header_titles"

  # has_many :tickets, foreign_key: :status_resolve_id

end
