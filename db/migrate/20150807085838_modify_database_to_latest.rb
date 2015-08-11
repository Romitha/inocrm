class ModifyDatabaseToLatest < ActiveRecord::Migration
  def change
    remove_foreign_key :mst_inv_product, column: :created_by

    add_index :mst_spt_spare_part_description, :description, unique: true

    change_column_null :spt_act_hold, :un_hold_action_id, true

    remove_foreign_key :spt_act_request_spare_part, column: :terminate_reason_id

    rename_column :spt_act_request_spare_part, :terminate_reason_id, :part_terminate_reason_id
    add_foreign_key(:spt_act_request_spare_part, :mst_spt_reason, name: "fk_spt_act_request_spare_part_mst_spt_reason1", column: :part_terminate_reason_id)

    rename_column :spt_ticket, :terminated, :ticket_terminated

    change_column_null :spt_ticket_on_loan_spare_part, :ref_spare_part_id, true

    rename_column :spt_ticket_on_loan_spare_part, :terminated, :part_terminated
    remove_foreign_key :spt_ticket_on_loan_spare_part, column: :terminated_reason_id
    rename_column :spt_ticket_on_loan_spare_part, :terminated_reason_id, :part_terminated_reason_id

    add_foreign_key(:spt_ticket_on_loan_spare_part, :mst_spt_reason, name: "fk_spt_ticket_on_loan_spare_part_mst_spt_reason1", column: :part_terminated_reason_id)

    rename_column :spt_ticket_spare_part, :terminated, :part_terminated
    remove_foreign_key :spt_ticket_spare_part, column: :terminated_reason_id
    rename_column :spt_ticket_spare_part, :terminated_reason_id, :part_terminated_reason_id

    add_foreign_key(:spt_ticket_spare_part, :mst_spt_reason, name: "fk_spt_ticket_spare_part_mst_spt_reason1", column: :part_terminated_reason_id)

    add_column :company_config, :inv_category_seperator, :string, default: "/", null: false
    add_column :company_config, :inv_serial_no_length, "INT UNSIGNED NOT NULL DEFAULT 6"
    change_column_null :company_config, :sup_external_job_profit_margin, true

    add_column :mst_inv_category_caption, :code_length, "INT NOT NULL DEFAULT 2"

  end
end
