class ModifyDatabaseToLatest < ActiveRecord::Migration
  def change

    {
      mst_inv_product: :created_by,
      spt_act_request_spare_part: :terminate_reason_id,
      spt_ticket_on_loan_spare_part: :terminated_reason_id,
      spt_ticket_spare_part: :terminated_reason_id
    }.each {|k, v| remove_foreign_key k, column: v}

    add_column :company_config, :inv_category_seperator, :string, default: "/", null: false
    add_column :company_config, :inv_serial_no_length, "INT UNSIGNED NOT NULL DEFAULT 6"
    add_column :mst_inv_category_caption, :code_length, "INT NOT NULL DEFAULT 2"

    {
      spt_act_request_spare_part: [:terminate_reason_id, :part_terminate_reason_id],
      spt_ticket: [:terminated, :ticket_terminated],
      spt_ticket_on_loan_spare_part: [:terminated, :part_terminated],
      spt_ticket_on_loan_spare_part: [:terminated_reason_id, :part_terminated_reason_id],
      spt_ticket_spare_part: [:terminated, :part_terminated],
      spt_ticket_spare_part: [:terminated_reason_id, :part_terminated_reason_id]
    }.each {|k, v| rename_column k, v[0], v[1]}

    change_column_null :spt_act_hold, :un_hold_action_id, true
    change_column_null :spt_ticket_on_loan_spare_part, :ref_spare_part_id, true
    change_column_null :company_config, :sup_external_job_profit_margin, true

    add_index :mst_spt_spare_part_description, :description, unique: true

    add_foreign_key(:spt_act_request_spare_part, :mst_spt_reason, name: "fk_spt_act_request_spare_part_mst_spt_reason1", column: :part_terminate_reason_id)
    add_foreign_key(:spt_ticket_on_loan_spare_part, :mst_spt_reason, name: "fk_spt_ticket_on_loan_spare_part_mst_spt_reason1", column: :part_terminated_reason_id)
    add_foreign_key(:spt_ticket_spare_part, :mst_spt_reason, name: "fk_spt_ticket_spare_part_mst_spt_reason1", column: :part_terminated_reason_id)

  end
end