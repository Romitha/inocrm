class UpdateSptTicketEngineer < ActiveRecord::Migration
  def change
    create_table :spt_ticket_engineer, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :ticket_id, "INT UNSIGNED NOT NULL"
      t.column :user_id, "INT UNSIGNED NOT NULL"
      t.column :created_action_id, "INT UNSIGNED"

      t.index :ticket_id, name: "fk_spt_ticket_engineer_spt_ticket1_idx"
      t.index :user_id, name: "fk_spt_ticket_engineer_users1_idx"
      t.index :created_action_id, name: "fk_spt_ticket_engineer_spt_ticket_action1_idx"

      t.timestamps
    end

    create_table :mst_spt_dispatch_method, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name, null: false

      t.timestamps
    end

    create_table :spt_act_quotation, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"
      t.column :customer_quotation_id, "INT UNSIGNED NOT NULL"

      t.timestamps

      t.index :ticket_action_id, name: "fk_spt_act_quotation_spt_ticket_action1_idx"
      t.index :customer_quotation_id, name: "fk_spt_act_quotation_spt_ticket_customer_quotation1_idx"
    end

    remove_foreign_key :spt_act_ticket_close_approve, name: "fk_spt_ticket_close_approval_users1"
    remove_index :spt_act_ticket_close_approve, name: "fk_spt_ticket_close_approval_users1"
    remove_column :spt_act_ticket_close_approve, :job_belongs_to

    add_column :spt_ticket_action, :action_engineer_id, "INT UNSIGNED"
    add_column :spt_act_assign_ticket, :assign_to_engineer_id, "INT UNSIGNED"
    add_column :spt_ticket_fsr, :engineer_id, "INT UNSIGNED NOT NULL"
    add_column :spt_ticket_estimation, :engineer_id, "INT UNSIGNED"
    add_column :spt_ticket_spare_part, :engineer_id, "INT UNSIGNED"
    add_column :spt_ticket_on_loan_spare_part, :engineer_id, "INT UNSIGNED"
    add_column :spt_ticket_customer_quotation, :engineer_id, "INT UNSIGNED NOT NULL"
    add_column :spt_act_ticket_close_approve, :owner_engineer_id, "INT UNSIGNED"
    add_column :spt_act_customer_feedback, :dispatch_method_id, "INT UNSIGNED"
    add_column :spt_ticket_spare_part_manufacture, :po_required, :boolean, null: false, default: true

    remove_foreign_key :spt_ticket, name: "fk_spt_ticket_users2"

    Ticket.update_all(owner_engineer_id: nil)
    TicketSparePart
    TaskAction
    TicketFsr.all.each { |f| f.act_fsr.try(:delete); f.ticket_spare_parts.try(:delete_all) }
    TicketFsr.delete_all

    [
      { table: :spt_ticket_action, column: :action_engineer_id, options: {name: "fk_spt_ticket_action_spt_ticket_engineer1_idx"} },
      { table: :spt_ticket, column: :owner_engineer_id, options: {name: "fk_spt_ticket_spt_ticket_engineer1_idx"} },
      { table: :spt_ticket_fsr, column: :engineer_id, options: {name: "fk_spt_ticket_fsr_spt_ticket_engineer1_idx"} },
      { table: :spt_ticket_estimation, column: :engineer_id, options: {name: "fk_spt_ticket_estimation_spt_ticket_engineer1_idx"} },
      { table: :spt_ticket_spare_part, column: :engineer_id, options: {name: "fk_spt_ticket_spare_part_spt_ticket_engineer1_idx"} },
      { table: :spt_ticket_on_loan_spare_part, column: :engineer_id, options: {name: "fk_spt_ticket_on_loan_spare_part_spt_ticket_engineer1_idx"} },
      { table: :spt_ticket_customer_quotation, column: :engineer_id, options: {name: "fk_spt_ticket_customer_qutation_estimation_spt_ticket_estim_idx"} },
      { table: :spt_act_assign_ticket, column: :assign_to_engineer_id, options: {name: "fk_spt_act_assign_ticket_spt_ticket_engineer1_idx"} },
      { table: :spt_act_ticket_close_approve, column: :owner_engineer_id, options: {name: "fk_spt_act_ticket_close_approve_spt_ticket_engineer1_idx"} },
      { table: :spt_act_customer_feedback, column: :dispatch_method_id, options: {name: "fk_spt_act_customer_feedback_mst_spt_dispatch_method1_idx"} },
    ]
    .each do |f|
      add_index f[:table], f[:column], f[:options]
    end

    [
      { table: :spt_ticket_engineer, reference_table: :spt_ticket, name: "fk_spt_ticket_engineer_spt_ticket1", column: :ticket_id },
      { table: :spt_ticket_engineer, reference_table: :users, name: "fk_spt_ticket_engineer_users1", column: :user_id },
      { table: :spt_ticket_engineer, reference_table: :spt_ticket_action, name: "fk_spt_ticket_engineer_spt_ticket_action1", column: :created_action_id },
      { table: :spt_ticket_action, reference_table: :spt_ticket_engineer, name: "fk_spt_ticket_action_spt_ticket_engineer1", column: :action_engineer_id },
      { table: :spt_ticket, reference_table: :spt_ticket_engineer, name: "fk_spt_ticket_spt_ticket_engineer1", column: :owner_engineer_id },
      { table: :spt_act_assign_ticket, reference_table: :spt_ticket_engineer, name: "fk_spt_act_assign_ticket_spt_ticket_engineer1", column: :assign_to_engineer_id },
      { table: :spt_ticket_fsr, reference_table: :spt_ticket_engineer, name: "fk_spt_ticket_fsr_spt_ticket_engineer1", column: :engineer_id },
      { table: :spt_ticket_estimation, reference_table: :spt_ticket_engineer, name: "fk_spt_ticket_estimation_spt_ticket_engineer1", column: :engineer_id },
      { table: :spt_ticket_spare_part, reference_table: :spt_ticket_engineer, name: "fk_spt_ticket_spare_part_spt_ticket_engineer1", column: :engineer_id },
      { table: :spt_ticket_on_loan_spare_part, reference_table: :spt_ticket_engineer, name: "fk_spt_ticket_on_loan_spare_part_spt_ticket_engineer1", column: :engineer_id },
      { table: :spt_ticket_customer_quotation, reference_table: :spt_ticket_engineer, name: "fk_spt_ticket_customer_quotation_spt_ticket_engineer1", column: :engineer_id },
      { table: :spt_act_ticket_close_approve, reference_table: :spt_ticket_engineer, name: "fk_spt_act_ticket_close_approve_spt_ticket_engineer1", column: :owner_engineer_id },
      { table: :spt_act_customer_feedback, reference_table: :mst_spt_dispatch_method, name: "fk_spt_act_customer_feedback_mst_spt_dispatch_method1", column: :dispatch_method_id },
      { table: :spt_act_quotation, reference_table: :spt_ticket_action, name: "fk_spt_act_quotation_spt_ticket_action1", column: :ticket_action_id },
      { table: :spt_act_quotation, reference_table: :spt_ticket_customer_quotation, name: "fk_spt_act_quotation_spt_ticket_customer_quotation1", column: :customer_quotation_id },
    ]
    .each do |f|
      add_foreign_key f[:table], f[:reference_table], name: f[:name], column: f[:column]
    end

  end
end
