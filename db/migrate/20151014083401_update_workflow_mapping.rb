class UpdateWorkflowMapping < ActiveRecord::Migration
  def change
    WorkflowMapping.find(11).update(process_name: "SPPT_MFR_PART_REQUEST")
  end
end
