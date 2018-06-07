class WorkflowMapping < ActiveRecord::Base
  self.table_name = "workflow_mappings"

  belongs_to :bpm_module_role, foreign_key: :bpm_role_id

end

class WorkflowHeaderTitle < ActiveRecord::Base
  self.table_name = "workflow_header_titles"

end

class EmailTemplate < ActiveRecord::Base
  self.table_name = "mst_spt_template_email"

end
