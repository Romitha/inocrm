class WorkFlowMappingUpdate < ActiveRecord::Migration
  def change
    add_column :workflow_mappings, :bpm_role_id, "INT UNSIGNED NULL"
    add_index :workflow_mappings, :bpm_role_id, name: "fk_workflow_mappings_mst_bpm_role1_idx"
    add_foreign_key :workflow_mappings, :mst_bpm_role, name: :fk_workflow_mappings_mst_bpm_role1, column: :bpm_role_id
  end
end
