class AddConstraintNameToTables < ActiveRecord::Migration
  # add_foreign_key(from_table, to_table, options)
  # remove_foreign_key(from_table, to_table, options)
  # class Comment < ActiveRecord::Base
  #   belongs_to :post
  # end

  # class Post < ActiveRecord::Base
  #   has_many :comments, dependent: :delete_all
  # end
  # add_foreign_key(:comments, :posts)

  def change
    [
      {constraint_name: "fk_workflow_alert_users_users1", foreign_key: "user_id", reference_table: "users"},
      {constraint_name: "fk_workflow_alert_users_workflow_alerts1", foreign_key: "user_id", reference_table: "workflow_alerts"}
    ].each do |attr|
      # execute "ALTER TABLE `workflow_alert_users` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
      add_foreign_key(:workflow_alert_users, attr[:reference_table].to_sym, name: attr[:constraint_name], column: attr[:foreign_key])
    end

    [
      {constraint_name: "fk_workflow_alert_users_workflow_alerts10", foreign_key: "alert_id", reference_table: "workflow_alerts"}
    ].each do |attr|
      execute "ALTER TABLE `workflow_alert_roles` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_ticket_spare_part_inv_srn11", foreign_key: "inv_srn_id", reference_table: "inv_srn"},
      {constraint_name: "fk_spt_ticket_spare_part_inv_srn_item11", foreign_key: "inv_srn_item_id", reference_table: "inv_srn_item"},
      {constraint_name: "fk_spt_ticket_spare_part_inv_srr11", foreign_key: "inv_srr_id", reference_table: "inv_srr"},
      {constraint_name: "fk_spt_ticket_spare_part_inv_srr_item11", foreign_key: "inv_srr_item_id", reference_table: "inv_srr_item"},
      {constraint_name: "fk_spt_ticket_spare_part_mst_inv_product12", foreign_key: "inv_product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_spt_ticket_spare_part_mst_inv_product21", foreign_key: "approved_inv_product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_spt_ticket_spare_part_mst_inv_product31", foreign_key: "mst_inv_product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_spt_ticket_spare_part_mst_organzation12", foreign_key: "store_id", reference_table: "organizations"},
      {constraint_name: "fk_spt_ticket_spare_part_store_mst_inv_reason1", foreign_key: "return_part_damage_reason_id", reference_table: "mst_inv_reason"},
      {constraint_name: "fk_spt_ticket_spare_part_store_spt_ticket_spare_part1", foreign_key: "spare_part_id", reference_table: "spt_ticket_spare_part"},
      {constraint_name: "fk_spt_ticket_spare_part_users111", foreign_key: "store_requested_by", reference_table: "users"},
      {constraint_name: "fk_spt_ticket_spare_part_users121", foreign_key: "store_request_approved_by", reference_table: "users"},
      {constraint_name: "fk_spt_ticket_spare_part_users131", foreign_key: "store_issued_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_spare_part_store` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_ticket_spare_part_status_mst_spt_spare_part_status1", foreign_key: "status_id", reference_table: "mst_spt_spare_part_status_action"},
      {constraint_name: "fk_spt_ticket_spare_part_status_spt_ticket_spare_part1", foreign_key: "spare_part_id", reference_table: "spt_ticket_spare_part"},
      {constraint_name: "fk_spt_ticket_spare_part_status_users1", foreign_key: "done_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_spare_part_status_action` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_ticket_spare_part_manufacture_mst_currency1", foreign_key: "manufacture_currency_id", reference_table: "mst_currency"},
      {constraint_name: "fk_spt_ticket_spare_part_manufacture_spt_ticket_spare_part1", foreign_key: "spare_part_id", reference_table: "spt_ticket_spare_part"},
      {constraint_name: "fk_spt_ticket_spare_part_manufacture_users1", foreign_key: "add_bundle_by", reference_table: "users"},
      {constraint_name: "fk_spt_ticket_spare_part_spt_return_parts_bundle10", foreign_key: "return_parts_bundle_id", reference_table: "spt_return_parts_bundle"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_spare_part_manufacture` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_ticket_spare_part_mst_spt_reason1", foreign_key: "part_terminated_reason_id", reference_table: "mst_spt_reason"},
      {constraint_name: "fk_spt_ticket_spare_part_mst_spt_reason2", foreign_key: "unused_reason_id", reference_table: "mst_spt_reason"},
      {constraint_name: "fk_spt_ticket_spare_part_mst_spt_spare_part_status_action1", foreign_key: "status_action_id", reference_table: "mst_spt_spare_part_status_action"},
      {constraint_name: "fk_spt_ticket_spare_part_mst_spt_spare_part_status_use1", foreign_key: "status_use_id", reference_table: "mst_spt_spare_part_status_use"},
      {constraint_name: "fk_spt_ticket_spare_part_spt_ticket1", foreign_key: "ticket_id", reference_table: "spt_ticket"},
      {constraint_name: "fk_spt_ticket_spare_part_spt_ticket_action1", foreign_key: "close_approved_action_id", reference_table: "spt_ticket_action"},
      {constraint_name: "fk_spt_ticket_spare_part_spt_ticket_fsr1", foreign_key: "fsr_id", reference_table: "spt_ticket_fsr"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_spare_part` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_ticket_product_serial_spt_product_serial1", foreign_key: "product_serial_id", reference_table: "spt_product_serial"},
      {constraint_name: "fk_spt_ticket_product_serial_spt_product_serial2", foreign_key: "ref_product_serial_id", reference_table: "spt_product_serial"},
      {constraint_name: "fk_spt_ticket_product_serial_spt_ticket1", foreign_key: "ticket_id", reference_table: "spt_ticket"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_product_serial` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_ticket_question_answer_spt_problematic_question10", foreign_key: "problematic_question_id", reference_table: "mst_spt_problematic_question"},
      {constraint_name: "fk_spt_ticket_question_answer_spt_ticket10", foreign_key: "ticket_id", reference_table: "spt_ticket"},
      {constraint_name: "fk_spt_ticket_question_answer_spt_ticket_action10", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_problematic_question_answer` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_join_ticket_spt_ticket10", foreign_key: "ticket_id", reference_table: "spt_ticket"},
      {constraint_name: "fk_spt_ticket_payment_received_mst_currency1", foreign_key: "currency_id", reference_table: "mst_currency"},
      {constraint_name: "fk_spt_ticket_payment_received_mst_spt_payment_received_type1", foreign_key: "type_id", reference_table: "mst_spt_payment_received_type"},
      {constraint_name: "fk_spt_ticket_payment_received_spt_invoice1", foreign_key: "invoice_id", reference_table: "spt_invoice"},
      {constraint_name: "fk_spt_ticket_payment_received_users1", foreign_key: "received_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_payment_received` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_status_action_spt_ticket_o_idx", foreign_key: "on_loan_spare_part_id", reference_table: "spt_ticket_on_loan_spare_part"},
      {constraint_name: "fk_spt_ticket_spare_part_status_mst_spt_spare_part_status10", foreign_key: "status_id", reference_table: "mst_spt_spare_part_status_action"},
      {constraint_name: "fk_spt_ticket_spare_part_status_users10", foreign_key: "done_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_on_loan_spare_part_status_action` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_inv_srn1", foreign_key: "inv_srn_id", reference_table: "inv_srn"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_inv_srn_item1", foreign_key: "inv_srn_item_id", reference_table: "inv_srn_item"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_inv_srr1", foreign_key: "inv_srr_id", reference_table: "inv_srr"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_inv_srr_item1", foreign_key: "inv_srr_item_id", reference_table: "inv_srr_item"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_mst_inv_product1", foreign_key: "main_inv_product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_mst_inv_product2", foreign_key: "approved_inv_product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_mst_inv_product3", foreign_key: "approved_main_inv_product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_mst_inv_reason1", foreign_key: "return_part_damage_reason_id", reference_table: "mst_inv_reason"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_mst_spt_reason1", foreign_key: "part_terminated_reason_id", reference_table: "mst_spt_reason"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_mst_spt_reason2", foreign_key: "unused_reason_id", reference_table: "mst_spt_reason"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_mst_spt_spare_part_status_ac1", foreign_key: "status_action_id", reference_table: "mst_spt_spare_part_status_action"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_mst_spt_spare_part_status_use1", foreign_key: "status_use_id", reference_table: "mst_spt_spare_part_status_use"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_spt_ticket_spare_part1", foreign_key: "ref_spare_part_id", reference_table: "spt_ticket_spare_part"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_users1", foreign_key: "approved_by", reference_table: "users"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_users2", foreign_key: "issued_by", reference_table: "users"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_users3", foreign_key: "received_eng_by", reference_table: "users"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_users4", foreign_key: "part_returned_by", reference_table: "users"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_users5", foreign_key: "requested_by", reference_table: "users"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_users6", foreign_key: "ret_part_received_by", reference_table: "users"},
      {constraint_name: "fk_spt_ticket_spare_part_mst_inv_product10", foreign_key: "inv_product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_spt_ticket_spare_part_mst_organzation10", foreign_key: "store_id", reference_table: "organizations"},
      {constraint_name: "fk_spt_ticket_spare_part_spt_ticket10", foreign_key: "ticket_id", reference_table: "spt_ticket"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_on_loan_spare_part` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_ticket_question_answer_spt_general_question1", foreign_key: "general_question_id", reference_table: "mst_spt_general_question"},
      {constraint_name: "fk_spt_ticket_question_answer_spt_ticket1", foreign_key: "ticket_id", reference_table: "spt_ticket"},
      {constraint_name: "fk_spt_ticket_question_answer_spt_ticket_action1", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_general_question_answer` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_ticket_fsr_spt_ticket1", foreign_key: "ticket_id", reference_table: "spt_ticket"},
      {constraint_name: "fk_spt_ticket_fsr_spt_ticket_action1", foreign_key: "approved_action_id", reference_table: "spt_ticket_action"},
      {constraint_name: "fk_spt_ticket_fsr_users1", foreign_key: "created_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_fsr` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_dummy_table_copy1_spt_ticket_estimation1", foreign_key: "ticket_estimation_id", reference_table: "spt_ticket_estimation"},
      {constraint_name: "fk_spt_dummy_table_copy1_spt_ticket_spare_part1", foreign_key: "ticket_spare_part_id", reference_table: "spt_ticket_spare_part"},
      {constraint_name: "fk_spt_ticket_estimation_part_mst_organzation1", foreign_key: "supplier_id", reference_table: "organizations"},
      {constraint_name: "fk_spt_ticket_estimation_part_spt_ticket1", foreign_key: "ticket_id", reference_table: "spt_ticket"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_estimation_part` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_ticket_estimation_external_spt_ticket1", foreign_key: "ticket_id", reference_table: "spt_ticket"},
      {constraint_name: "fk_spt_ticket_estimation_external_spt_ticket_estimation1", foreign_key: "ticket_estimation_id", reference_table: "spt_ticket_estimation"},
      {constraint_name: "fk_spt_ticket_estimation_mst_organzation10", foreign_key: "repair_by_id", reference_table: "organizations"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_estimation_external` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_dummy_table_copy1_spt_ticket_estimation10", foreign_key: "ticket_estimation_id", reference_table: "spt_ticket_estimation"},
      {constraint_name: "fk_spt_ticket_estimation_additional_mst_spt_additional_charge1", foreign_key: "additional_charge_id", reference_table: "mst_spt_additional_charge"},
      {constraint_name: "fk_spt_ticket_estimation_additional_spt_ticket1", foreign_key: "ticket_id", reference_table: "spt_ticket"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_estimation_additional` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_ticket_estimation_mst_currency1", foreign_key: "currency_id", reference_table: "mst_currency"},
      {constraint_name: "fk_spt_ticket_estimation_mst_spt_estimation_status1", foreign_key: "status_id", reference_table: "mst_spt_estimation_status"},
      {constraint_name: "fk_spt_ticket_estimation_spt_ticket1", foreign_key: "ticket_id", reference_table: "spt_ticket"},
      {constraint_name: "fk_spt_ticket_estimation_spt_ticket_payment_received1", foreign_key: "adv_payment_received_id", reference_table: "spt_ticket_payment_received"},
      {constraint_name: "fk_spt_ticket_estimation_users1", foreign_key: "requested_by", reference_table: "users"},
      {constraint_name: "fk_spt_ticket_estimation_users2", foreign_key: "estimated_by", reference_table: "users"},
      {constraint_name: "fk_spt_ticket_estimation_users3", foreign_key: "approved_by", reference_table: "users"},
      {constraint_name: "fk_spt_ticket_estimation_users4", foreign_key: "cust_approved_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_estimation` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_ticket_deliver_unit_mst_organzation1", foreign_key: "deliver_to_id", reference_table: "organizations"},
      {constraint_name: "fk_spt_ticket_deliver_unit_users1", foreign_key: "delivered_to_sup_by", reference_table: "users"},
      {constraint_name: "fk_spt_ticket_deliver_unit_users2", foreign_key: "collected_by", reference_table: "users"},
      {constraint_name: "fk_spt_ticket_deliver_unit_users3", foreign_key: "received_by", reference_table: "users"},
      {constraint_name: "fk_spt_ticket_deliver_unit_users4", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_spt_ticket_estimation_spt_ticket10", foreign_key: "ticket_id", reference_table: "spt_ticket"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_deliver_unit` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_ticket_action_mst_spt_action1", foreign_key: "action_id", reference_table: "mst_spt_action"},
      {constraint_name: "fk_spt_ticket_action_spt_ticket1", foreign_key: "ticket_id", reference_table: "spt_ticket"},
      {constraint_name: "fk_spt_ticket_action_users1", foreign_key: "action_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_action` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_ticket_accessory_mst_spt_accessory1", foreign_key: "accessory_id", reference_table: "mst_spt_accessory"},
      {constraint_name: "fk_spt_ticket_accessory_spt_ticket1", foreign_key: "ticket_id", reference_table: "spt_ticket"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_accessory` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_ticket_mst_currency1", foreign_key: "base_currency_id", reference_table: "mst_currency"},
      {constraint_name: "fk_spt_ticket_mst_currency2", foreign_key: "manufacture_currency_id", reference_table: "mst_currency"},
      {constraint_name: "fk_spt_ticket_mst_spt_ticket_contact_type1", foreign_key: "contact_type_id", reference_table: "mst_spt_contact_type"},
      {constraint_name: "fk_spt_ticket_mst_spt_ticket_informed_method1", foreign_key: "informed_method_id", reference_table: "mst_spt_ticket_informed_method"},
      {constraint_name: "fk_spt_ticket_mst_spt_ticket_repair_type1", foreign_key: "repair_type_id", reference_table: "mst_spt_ticket_repair_type"},
      {constraint_name: "fk_spt_ticket_mst_spt_ticket_start_action1", foreign_key: "job_started_action_id", reference_table: "mst_spt_ticket_start_action"},
      {constraint_name: "fk_spt_ticket_mst_spt_ticket_status1", foreign_key: "status_id", reference_table: "mst_spt_ticket_status"},
      {constraint_name: "fk_spt_ticket_mst_spt_ticket_status_resolve1", foreign_key: "status_resolve_id", reference_table: "mst_spt_ticket_status_resolve"},
      {constraint_name: "fk_spt_ticket_mst_spt_ticket_type1", foreign_key: "ticket_type_id", reference_table: "mst_spt_ticket_type"},
      {constraint_name: "fk_spt_ticket_mst_spt_ticket_warranty_type1", foreign_key: "warranty_type_id", reference_table: "mst_spt_warranty_type"},
      {constraint_name: "fk_spt_ticket_spt_contact_person_reporter_info1", foreign_key: "contact_person1_id", reference_table: "spt_contact_report_person"},
      {constraint_name: "fk_spt_ticket_spt_contact_person_reporter_info2", foreign_key: "contact_person2_id", reference_table: "spt_contact_report_person"},
      {constraint_name: "fk_spt_ticket_spt_contact_person_reporter_info3", foreign_key: "reporter_id", reference_table: "spt_contact_report_person"},
      {constraint_name: "fk_spt_ticket_spt_contract_info1", foreign_key: "contract_id", reference_table: "spt_contract"},
      {constraint_name: "fk_spt_ticket_spt_customer_info1", foreign_key: "customer_id", reference_table: "spt_customer"},
      {constraint_name: "fk_spt_ticket_spt_job_type1", foreign_key: "job_type_id", reference_table: "mst_spt_job_type"},
      {constraint_name: "fk_spt_ticket_spt_problem_category1", foreign_key: "problem_category_id", reference_table: "spt_problem_category"},
      {constraint_name: "fk_spt_ticket_spt_reason1", foreign_key: "hold_reason_id", reference_table: "mst_spt_reason"},
      {constraint_name: "fk_spt_ticket_users1", foreign_key: "created_by", reference_table:"users"},
      {constraint_name: "fk_spt_ticket_users2", foreign_key: "owner_engineer_id", reference_table: "users"},
      {constraint_name: "fk_spt_ticket_mst_spt_sla1", foreign_key: "sla_id", reference_table: "mst_spt_sla"},
      {constraint_name: "FK_spt_ticket_spt_ticket_action", foreign_key: "last_hold_action_id", reference_table:"spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_so_po_item_spt_so_po1", foreign_key: "spt_so_po_id", reference_table: "spt_so_po"},
      {constraint_name: "fk_spt_so_po_item_spt_ticket_spare_part1", foreign_key: "ticket_spare_part_id", reference_table: "spt_ticket_spare_part"},
      {constraint_name: "fk_spt_so_po_item_spt_ticket_spare_part_manufacture1", foreign_key: "ticket_spare_part_item_id", reference_table: "spt_ticket_spare_part_manufacture"}
    ].each do |attr|
      execute "ALTER TABLE `spt_so_po_item` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_invoice_users10", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_spt_so_po_mst_currency1", foreign_key: "currency_id", reference_table: "mst_currency"},
      {constraint_name: "fk_spt_so_po_mst_spt_prodcut_brand1", foreign_key: "product_brand_id", reference_table: "mst_spt_product_brand"}
    ].each do |attr|
      execute "ALTER TABLE `spt_so_po` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_return_parts_bundle_mst_spt_prodcut_brand1", foreign_key: "product_brand_id", reference_table: "mst_spt_product_brand"},
      {constraint_name: "fk_spt_return_parts_bundle_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_spt_return_parts_bundle_users2", foreign_key: "delivered_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `spt_return_parts_bundle` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_regular_cutomer_info_spt_contact_person_reporter_info1", foreign_key: "contact_person1_id", reference_table: "spt_contact_report_person"},
      {constraint_name: "fk_spt_regular_cutomer_info_spt_contact_person_reporter_info2", foreign_key: "contact_person2_id", reference_table: "spt_contact_report_person"},
      {constraint_name: "fk_spt_regular_cutomer_info_spt_contact_person_reporter_info3", foreign_key: "reporter_id", reference_table: "spt_contact_report_person"},
      {constraint_name: "fk_spt_regular_cutomer_info_spt_customer_info1", foreign_key: "customer_id", reference_table: "spt_customer"}
    ].each do |attr|
      execute "ALTER TABLE `spt_regular_customer` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_franchise_agent_mst_organzation1", foreign_key: "organization_id", reference_table: "organizations"}
    ].each do |attr|
      execute "ALTER TABLE `spt_regional_support_center` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_product_serial_warranty_mst_spt_warranty_type1_idx", foreign_key: "warranty_type_id", reference_table: "mst_spt_warranty_type"},
      {constraint_name: "fk_spt_product_serial_warranty_spt_product_serial1", foreign_key: "product_serial_id", reference_table: "spt_product_serial"}
    ].each do |attr|
      execute "ALTER TABLE `spt_product_serial_warranty` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_product_serial_inv_inventory_serial_item1", foreign_key: "inventory_serial_item_id", reference_table: "inv_inventory_serial_item"},
      {constraint_name: "fk_spt_product_serial_mst_country1", foreign_key: "sold_country_id", reference_table: "mst_country"},
      {constraint_name: "fk_spt_product_serial_mst_spt_pop_status1", foreign_key: "pop_status_id", reference_table: "mst_spt_pop_status"},
      {constraint_name: "fk_spt_product_serial_users1", foreign_key: "sold_by", reference_table: "users"},
      {constraint_name: "fk_spt_unit_serial_mst_spt_prodcut_brand1", foreign_key:"product_brand_id", reference_table: "mst_spt_product_brand"},    #_
      {constraint_name: "fk_spt_unit_serial_mst_spt_product_category1", foreign_key: "product_category_id", reference_table: "mst_spt_product_category"}      #_
    ].each do |attr|
      execute "ALTER TABLE `spt_product_serial` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_invoice_print_history_users1", foreign_key: "printed_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `spt_print_history` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_join_ticket_spt_ticket1", foreign_key: "ticket_id", reference_table: "spt_ticket"},
      {constraint_name: "fk_spt_join_ticket_spt_ticket2", foreign_key: "joint_ticket_id", reference_table: "spt_ticket"}
    ].each do |attr|
      execute "ALTER TABLE `spt_joint_ticket` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    # [
    #   {constraint_name: "fk_spt_invoice_print_history_spt_invoice1", foreign_key: "invoice_id", reference_table: "spt_invoice"},
    #   {constraint_name: "fk_spt_invoice_print_history_spt_print_history1", foreign_key: "print_history_id", reference_table: "spt_print_history"}
    # ].each do |attr|
    #   execute "ALTER TABLE `spt_invoice_print_history` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    # end

    [
      {constraint_name: "fk_spt_invoice_item_spt_invoice1", foreign_key: "invoice_id", reference_table: "spt_invoice"}
    ].each do |attr|
      execute "ALTER TABLE `spt_invoice_item` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_invoice_mst_currency1", foreign_key: "currency_id", reference_table: "mst_currency"},
      {constraint_name: "fk_spt_invoice_users1", foreign_key: "created_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `spt_invoice` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    # [
    #   {constraint_name: "fk_spt_fsr_print_history_spt_ticket_fsr1", foreign_key: "fsr_id", reference_table: "spt_ticket_fsr"},
    #   {constraint_name: "fk_spt_invoice_print_history_spt_print_history101", foreign_key: "print_history_id", reference_table: "spt_print_history"}
    # ].each do |attr|
    #   execute "ALTER TABLE `spt_fsr_print_history` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    # end

    # [
    #   {constraint_name: "fk_spt_cus_recieved_note_print_history_spt_ticket1_idx", foreign_key: "ticket_id", reference_table: "spt_ticket"},
    #   {constraint_name: "fk_spt_invoice_print_history_spt_print_history100", foreign_key: "print_history_id", reference_table: "spt_print_history"}
    # ].each do |attr|
    #   execute "ALTER TABLE `spt_cus_returned_note_print_history` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    # end

    # [
    #   {constraint_name: "fk_spt_cus_recieved_note_print_history_spt_ticket1", foreign_key: "ticket_id", reference_table: "spt_ticket"},
    #   {constraint_name: "fk_spt_invoice_print_history_spt_print_history10", foreign_key: "print_history_id", reference_table: "spt_print_history"}
    # ].each do |attr|
    #   execute "ALTER TABLE `spt_cus_recieved_note_print_history` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    # end

    [
      {constraint_name: "fk_spt_customer_contact_type_mst_spt_customer_contact_type1_idx", foreign_key: "contact_type_id", reference_table: "mst_spt_customer_contact_type"},
      {constraint_name: "fk_spt_customer_contact_type_spt_customer1", foreign_key: "customer_id", reference_table: "spt_customer"}
    ].each do |attr|
      execute "ALTER TABLE `spt_customer_contact_type` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_customer_mst_organzation1", foreign_key: "organization_id", reference_table: "organizations"},
      {constraint_name: "fk_spt_customer_mst_title1", foreign_key: "title_id", reference_table: "mst_title"},
      {constraint_name: "fk_spt_customer_mst_district1", foreign_key: "district_id", reference_table: "mst_district"}
    ].each do |attr|
      execute "ALTER TABLE `spt_customer` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_contract_product_mst_organzation1", foreign_key: "installed_location_id", reference_table: "organizations"},
      {constraint_name: "fk_spt_contract_product_spt_contract_info1", foreign_key: "contract_id", reference_table: "spt_contract"},
      {constraint_name: "fk_spt_contract_product_mst_spt_sla1", foreign_key: "sla_id", reference_table: "mst_spt_sla"},
      {constraint_name: "fk_spt_product_contract_spt_product_serial10", foreign_key: "product_serial_id", reference_table: "spt_product_serial"}
    ].each do |attr|
      execute "ALTER TABLE `spt_contract_product` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_contract_info_mst_organzation1", foreign_key: "customer_id", reference_table: "organizations"},
      {constraint_name: "fk_spt_contract_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_spt_contract_mst_spt_sla1", foreign_key: "sla_id", reference_table: "mst_spt_sla"}
    ].each do |attr|
      execute "ALTER TABLE `spt_contract` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_contact_report_person_contact_type_spt_contact_repor_idx", foreign_key: "contact_report_person_id", reference_table: "spt_contact_report_person"},
      {constraint_name: "fk_spt_customer_contact_type_mst_spt_customer_contact_type10", foreign_key: "contact_type_id", reference_table: "mst_spt_customer_contact_type"}
    ].each do |attr|
      execute "ALTER TABLE `spt_contact_report_person_contact_type` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end
    
    [
      {constraint_name: "fk_spt_contact_report_person_mst_title1", foreign_key: "title_id", reference_table: "mst_title"}
    ].each do |attr|
      execute "ALTER TABLE `spt_contact_report_person` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_assign_franchise_agent_spt_ticket_action100100001", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"},
      {constraint_name: "fk_spt_act_warranty_extend_mst_spt_reason1", foreign_key: "reject_reason_id", reference_table: "mst_spt_reason"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_warranty_extend` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_ticket_close_approval_spt_ticket_action1", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"},
      {constraint_name: "fk_spt_ticket_close_approval_mst_spt_reason1", foreign_key: "reject_reason_id", reference_table: "mst_spt_reason"},
      {constraint_name: "fk_spt_ticket_close_approval_users1", foreign_key: "job_belongs_to", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_ticket_close_approve` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_assign_franchise_agent_spt_ticket_action1000", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"},
      {constraint_name: "fk_spt_act_terminate_job_payment_mst_currency1", foreign_key: "currency_id", reference_table: "mst_currency"},
      {constraint_name: "fk_spt_act_terminate_job_payment_mst_spt_payment_type1", foreign_key: "payment_item_id", reference_table: "mst_spt_payment_item"},
      {constraint_name: "fk_spt_act_terminate_job_payment_mst_spt_reason1", foreign_key: "adjust_reason_id", reference_table: "mst_spt_reason"},
      {constraint_name: "fk_spt_act_terminate_job_payment_spt_ticket1", foreign_key: "ticket_id", reference_table: "spt_ticket"},
      {constraint_name: "fk_spt_act_terminate_job_payment_spt_ticket_action1", foreign_key: "adjust_action_id", reference_table: "spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_terminate_job_payment` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_assign_franchise_agent_spt_ticket_action100", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"},
      {constraint_name: "fk_spt_act_re_assign_request_spt_reason10", foreign_key: "reason_id", reference_table: "mst_spt_reason"},
      {constraint_name: "fk_spt_act_terminate_job_spt_ticket_action1", foreign_key: "foc_approved_action_id", reference_table: "spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_terminate_job` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_customer_feedback_spt_ticket_payment_received10", foreign_key: "payment_received_id", reference_table: "spt_ticket_payment_received"},
      {constraint_name: "fk_spt_act_ticket_close_approval_spt_ticket_action1000", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_terminate_issue_invoice` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_re_assign_request_mst_spt_reason1", foreign_key: "reason_id", reference_table: "mst_spt_reason"},
      {constraint_name: "fk_spt_act_re_assign_request_spt_ticket_action1", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_re_assign_request` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_assign_franchise_agent_spt_ticket_action10010000", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"},
      {constraint_name: "fk_spt_act_request_spare_part_mst_spt_reason1", foreign_key: "part_terminate_reason_id", reference_table: "mst_spt_reason"},
      {constraint_name: "fk_spt_act_request_spare_part_mst_spt_reason2", foreign_key: "reject_return_part_reason_id", reference_table: "mst_spt_reason"},
      {constraint_name: "fk_spt_act_request_spare_part_spt_ticket_spare_part1", foreign_key: "ticket_spare_part_id", reference_table: "spt_ticket_spare_part"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_request_spare_part` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_assign_franchise_agent_spt_ticket_action100100000", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"},
      {constraint_name: "fk_spt_act_request_on_loan_spare_part_spt_ticket_on_loan_spar1", foreign_key: "ticket_on_loan_spare_part_id", reference_table: "spt_ticket_on_loan_spare_part"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_request_on_loan_spare_part` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_ticket_close_approval_spt_ticket_action10", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_qc` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_assign_franchise_agent_spt_ticket_action10010001001", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"},
      {constraint_name: "fk_spt_act_payment_received_spt_ticket_payment_received1", foreign_key: "ticket_payment_received_id", reference_table: "spt_ticket_payment_received"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_payment_received` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_assign_franchise_agent_spt_ticket_action10010001000", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"},
      {constraint_name: "fk_spt_act_deliver_unit_mst_organzation10", foreign_key: "supplier_id", reference_table: "organizations"},
      {constraint_name: "fk_spt_act_job_estimate_request_spt_ticket_estimation1", foreign_key: "ticket_estimation_id", reference_table: "spt_ticket_estimation"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_job_estimate` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_inform_customer_mst_spt_ticket_contact_type1", foreign_key: "contact_type_id", reference_table: "mst_spt_contact_type"},
      {constraint_name: "fk_spt_act_ticket_close_approval_spt_ticket_action10000", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_inform_customer` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_assign_franchise_agent_spt_ticket_action10010001", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_hp_case_action` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_assign_franchise_agent_spt_ticket_action1001", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"},
      {constraint_name: "fk_spt_act_re_assign_request_spt_reason100", foreign_key: "reason_id", reference_table: "mst_spt_reason"},
      {constraint_name: "FK_spt_act_hold_spt_ticket_action", foreign_key: "un_hold_action_id", reference_table: "spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_hold` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_assign_franchise_agent_spt_ticket_action10010", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"},
      {constraint_name: "fk_spt_act_create_fsr_spt_ticket_fsr1", foreign_key: "fsr_id", reference_table: "spt_ticket_fsr"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_fsr` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_assign_franchise_agent_spt_ticket_action100100010", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_finish_job` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_assign_franchise_agent_spt_ticket_action10011", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_edit_serial_request` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_assign_franchise_agent_spt_ticket_action1001000100", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"},
      {constraint_name: "fk_spt_act_deliver_unit_mst_organzation1", foreign_key: "deliver_to_id", reference_table: "organizations"},
      {constraint_name: "fk_spt_act_deliver_unit_spt_ticket_deliver_unit1", foreign_key: "ticket_deliver_unit_id", reference_table: "spt_ticket_deliver_unit"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_deliver_unit` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_customer_feedback_mst_spt_customer_feedback1", foreign_key: "feedback_id", reference_table: "mst_spt_customer_feedback"},
      {constraint_name: "fk_spt_act_customer_feedback_spt_ticket_payment_received1", foreign_key: "payment_received_id", reference_table: "spt_ticket_payment_received"},
      {constraint_name: "fk_spt_act_ticket_close_approval_spt_ticket_action100", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_customer_feedback` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_assign_ticket_mst_spt_sbu1", foreign_key: "sbu_id", reference_table: "mst_spt_sbu"},
      {constraint_name: "fk_spt_assign_ticket_spt_ticket_action1", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"},
      {constraint_name: "fk_spt_assign_ticket_users1", foreign_key: "assign_to", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_assign_ticket` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_assign_franchise_agent_spt_franchise_agent1", foreign_key: "regional_support_center_id", reference_table: "spt_regional_support_center"},
      {constraint_name: "fk_spt_act_assign_franchise_agent_spt_ticket_action1", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_assign_regional_support_center` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_act_assign_franchise_agent_spt_ticket_action1001000", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_action_taken` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    #new
    [
      {constraint_name: "fk_company_config_mst_spt_sla1", foreign_key: "sup_sla_id", reference_table: "mst_spt_sla"}
    ].each do |attr|
      execute "ALTER TABLE `company_config` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_inv_batch_warranty_inv_inventory_batch1", foreign_key: "batch_id", reference_table: "inv_inventory_batch"},
      {constraint_name: "fk_inv_batch_warranty_inv_warranty1", foreign_key: "warranty_id", reference_table: "inv_warranty"}
    ].each do |attr|
      execute "ALTER TABLE `inv_batch_warranty` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_damage_source_mst_product1", foreign_key: "product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_damage_source_srr_item1", foreign_key: "srr_item_id", reference_table: "inv_srr_item"},
      {constraint_name: "fk_gin_source_grn_item100", foreign_key: "grn_item_id", reference_table: "inv_grn_item"},
      {constraint_name: "fk_Inventory_damage_damage_request1", foreign_key: "damage_request_id", reference_table: "inv_damage_request"},
      {constraint_name: "fk_Inventory_damage_damage_request_item1", foreign_key: "damage_request_source_id", reference_table: "inv_damage_request_source"},
      {constraint_name: "fk_inventory_damage_grn_batch1", foreign_key: "grn_batch_id", reference_table: "inv_grn_batch"},
      {constraint_name: "fk_inventory_damage_grn_serial_item1", foreign_key: "grn_serial_item_id", reference_table: "inv_grn_serial_item"},
      {constraint_name: "fk_inventory_damage_mst_disposal_methods1", foreign_key: "disposal_method_id", reference_table: "mst_inv_disposal_method"},
      {constraint_name: "fk_Inventory_damage_mst_organzation1", foreign_key: "store_id", reference_table: "organizations"},
      {constraint_name: "fk_Inventory_damage_mst_product_condition1", foreign_key: "product_condition_id", reference_table: "mst_inv_product_condition"},
      {constraint_name: "fk_Inventory_damage_mst_reasons1", foreign_key: "damage_reason_id", reference_table: "mst_inv_reason"},
      {constraint_name: "fk_inv_damage_inv_inventory_serial_part1", foreign_key: "serial_part_id", reference_table: "inv_inventory_serial_part"},
      {constraint_name: "fk_inv_damage_mst_currency1", foreign_key: "currency_id", reference_table: "mst_currency"},
      {constraint_name: "fk_inv_damage_users1", foreign_key: "created_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `inv_damage` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_damage_request_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_damage_request_users2", foreign_key: "approved1_by", reference_table: "users"},
      {constraint_name: "fk_damage_request_users3", foreign_key: "approved2_by", reference_table: "users"},
      {constraint_name: "fk_damage_source_mst_product10", foreign_key: "product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_Inventory_damage_mst_organzation10", foreign_key: "store_id", reference_table: "organizations"},
      {constraint_name: "fk_Inventory_damage_mst_reasons10", foreign_key: "damage_reason_id", reference_table: "mst_inv_reason"}
    ].each do |attr|
      execute "ALTER TABLE `inv_damage_request` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_damage_request_item_damage_request1", foreign_key: "damage_request_id", reference_table: "inv_damage_request"},
      {constraint_name: "fk_damage_request_item_grn_item1", foreign_key: "grn_item_id", reference_table: "inv_grn_item"},
      {constraint_name: "fk_damage_request_source_grn_batch1", foreign_key: "grn_batch_id", reference_table: "inv_grn_batch"},
      {constraint_name: "fk_damage_request_source_grn_serial_item1", foreign_key: "grn_serial_item_id", reference_table: "inv_grn_serial_item"},
      {constraint_name: "fk_damage_request_source_mst_disposal_methods1", foreign_key: "approved1_disposal_method_id", reference_table: "mst_inv_disposal_method"},
      {constraint_name: "fk_damage_request_source_mst_disposal_methods2", foreign_key: "approved2_disposal_method_id", reference_table: "mst_inv_disposal_method"},
      {constraint_name: "fk_inv_damage_request_source_mst_currency1", foreign_key: "currency_id", reference_table: "mst_currency"}
    ].each do |attr|
      execute "ALTER TABLE `inv_damage_request_source` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_damage_source_mst_product11", foreign_key: "product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_Inventory_damage_mst_organzation11", foreign_key: "store_id", reference_table: "organizations"},
      {constraint_name: "fk_inventory_destroy_destroy_request1", foreign_key: "disposal_request_id", reference_table: "inv_disposal_request"},
      {constraint_name: "fk_Inventory_destroy_mst_destroy_methods1", foreign_key: "disposal_method_id", reference_table: "mst_inv_disposal_method"},
      {constraint_name: "fk_Inventory_destroy_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_inventory_destroy_users2", foreign_key: "inspected_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `inv_disposal` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_damage_request_users10", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_damage_request_users20", foreign_key: "approved_by", reference_table: "users"},
      {constraint_name: "fk_damage_source_mst_product100", foreign_key: "product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_destroy_request_mst_destroy_methods1", foreign_key: "requested_disposal_method_id", reference_table: "mst_inv_disposal_method"},
      {constraint_name: "fk_destroy_request_mst_destroy_methods2", foreign_key: "approved_disposal_method_id", reference_table: "mst_inv_disposal_method"},
      {constraint_name: "fk_disposal_request_mst_reasons1", foreign_key: "disposal_reason_id", reference_table: "mst_inv_reason"},
      {constraint_name: "fk_Inventory_damage_mst_organzation100", foreign_key: "store_id", reference_table: "organizations"}
    ].each do |attr|
      execute "ALTER TABLE `inv_disposal_request` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_destroy_request_item_destroy_request1", foreign_key: "disposal_request_id", reference_table: "inv_disposal_request"},
      {constraint_name: "fk_destroy_request_item_inventory_damage1", foreign_key: "damage_id", reference_table: "inv_damage"},
      {constraint_name: "fk_disposal_request_source_grn_batch1", foreign_key: "grn_batch_id", reference_table: "inv_grn_batch"},
      {constraint_name: "fk_disposal_request_source_grn_item1", foreign_key: "grn_item_id", reference_table: "inv_grn_item"},
      {constraint_name: "fk_disposal_request_source_grn_serial_item1", foreign_key: "grn_serial_item_id", reference_table: "inv_grn_serial_item"}
    ].each do |attr|
      execute "ALTER TABLE `inv_disposal_request_source` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_inventory_destroy_item_inventory_damage1", foreign_key: "damage_id", reference_table: "inv_damage"},
      {constraint_name: "fk_inventory_destroy_item_inventory_destroy1", foreign_key: "disposal_id", reference_table: "inv_disposal"},
      {constraint_name: "fk_inventory_disposal_source_grn_batch1", foreign_key: "grn_batch_id", reference_table: "inv_grn_batch"},
      {constraint_name: "fk_inventory_disposal_source_grn_item1", foreign_key: "grn_item_id", reference_table: "inv_grn_item"},
      {constraint_name: "fk_inventory_disposal_source_grn_serial_item1", foreign_key: "grn_serial_item_id", reference_table: "inv_grn_serial_item"}
    ].each do |attr|
      execute "ALTER TABLE `inv_disposal_source` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_gin_srn1", foreign_key: "srn_id", reference_table: "inv_srn"},
      {constraint_name: "fk_inv_gin_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_srn_mst_organzation10", foreign_key: "store_id", reference_table: "organizations"}
    ].each do |attr|
      execute "ALTER TABLE `inv_gin` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_gin_item_gin1", foreign_key: "gin_id", reference_table: "inv_gin"},
      {constraint_name: "fk_gin_item_mst_product_condition1", foreign_key: "product_condition_id", reference_table: "mst_inv_product_condition"},
      {constraint_name: "fk_gin_item_srn_item1", foreign_key: "srn_item_id", reference_table: "inv_srn_item"},
      {constraint_name: "fk_inv_gin_item_mst_currency1", foreign_key: "currency_id", reference_table: "mst_currency"},
      {constraint_name: "fk_srn_item_mst_product10", foreign_key: "product_id", reference_table: "mst_inv_product"}
    ].each do |attr|
      execute "ALTER TABLE `inv_gin_item` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_gin_source_gin_item10", foreign_key: "gin_item_id", reference_table: "inv_gin_item"},
      {constraint_name: "fk_gin_source_grn_batch1", foreign_key: "grn_batch_id", reference_table: "inv_grn_batch"},
      {constraint_name: "fk_gin_source_grn_item10", foreign_key: "grn_item_id", reference_table: "inv_grn_item"},
      {constraint_name: "fk_gin_source_grn_serial_item1", foreign_key: "grn_serial_item_id", reference_table: "inv_grn_serial_item"},
      {constraint_name: "fk_inv_gin_source_inv_inventory_serial_part1", foreign_key: "serial_part_id", reference_table: "inv_inventory_serial_part"}
    ].each do |attr|
      execute "ALTER TABLE `inv_gin_source` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_grn_mst_organzation1", foreign_key: "store_id", reference_table: "organizations"},
      {constraint_name: "fk_grn_srn1", foreign_key: "srn_id", reference_table: "inv_srn"},
      {constraint_name: "fk_inv_grn_users1", foreign_key: "created_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `inv_grn` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_grn_batch_grn_item1", foreign_key: "grn_item_id", reference_table: "inv_grn_item"},
      {constraint_name: "fk_grn_batch_inventory_batch1", foreign_key: "inventory_batch_id", reference_table: "inv_inventory_batch"}
    ].each do |attr|
      execute "ALTER TABLE `inv_grn_batch` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_grn_item_grn1", foreign_key: "grn_id", reference_table: "inv_grn"},
      {constraint_name: "fk_grn_item_mst_product1", foreign_key: "product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_grn_item_srn_item1", foreign_key: "srn_item_id", reference_table: "inv_srn_item"},
      {constraint_name: "fk_inv_grn_item_mst_currency1", foreign_key: "currency_id", reference_table: "mst_currency"}
    ].each do |attr|
      execute "ALTER TABLE `inv_grn_item` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_grn_batch_grn_item100", foreign_key: "grn_item_id", reference_table: "inv_grn_item"},
      {constraint_name: "fk_inv_grn_item_current_unit_cost_history_users1", foreign_key: "created_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `inv_grn_item_current_unit_cost_history` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_grn_batch_grn_item10", foreign_key: "grn_item_id", reference_table: "inv_grn_item"},
      {constraint_name: "fk_grn_serial_inventory_serial_item1", foreign_key: "serial_item_id", reference_table: "inv_inventory_serial_item"}
    ].each do |attr|
      execute "ALTER TABLE `inv_grn_serial_item` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_Inventory_mst_bin1", foreign_key: "bin_id", reference_table: "mst_inv_bin"},
      {constraint_name: "fk_Inventory_mst_organzation1", foreign_key: "store_id", reference_table: "organizations"},
      {constraint_name: "fk_Inventory_mst_product1", foreign_key: "product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_inv_inventory_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_inv_inventory_users2", foreign_key: "updated_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `inv_inventory` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_inventory_batch_mst_product1", foreign_key: "product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_inv_inventory_batch_inv_inventory1", foreign_key: "inventory_id", reference_table: "inv_inventory"},
      {constraint_name: "fk_inv_inventory_batch_users1", foreign_key: "created_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `inv_inventory_batch` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_inventory_serial_item_inventory_batch_item1", foreign_key: "batch_id", reference_table: "inv_inventory_batch"},
      {constraint_name: "fk_inventory_serial_item_mst_product1", foreign_key: "product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_inventory_serial_item_mst_product_condition1", foreign_key: "product_condition_id", reference_table: "mst_inv_product_condition"},
      {constraint_name: "fk_inv_inventory_serial_item_inv_inventory1", foreign_key: "inventory_id", reference_table: "inv_inventory"},
      {constraint_name: "fk_inv_inventory_serial_item_mst_inv_serial_item_status1", foreign_key: "inv_status_id", reference_table: "mst_inv_serial_item_status"},
      {constraint_name: "fk_inv_inventory_serial_item_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_inv_inventory_serial_item_users2", foreign_key: "updated_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `inv_inventory_serial_item` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_inventory_serial_item_mst_product11", foreign_key: "product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_inventory_serial_item_mst_product_condition11", foreign_key: "product_condition_id", reference_table: "mst_inv_product_condition"},
      {constraint_name: "fk_inv_inventory_serial_item_mst_inv_serial_item_status10", foreign_key: "inv_status_id", reference_table: "mst_inv_serial_item_status"},
      {constraint_name: "fk_inv_inventory_serial_item_users10", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_inv_inventory_serial_item_users20", foreign_key: "updated_by", reference_table: "users"},
      {constraint_name: "fk_inv_inventory_serial_part_inv_inventory_serial_item1", foreign_key: "serial_item_id", reference_table: "inv_inventory_serial_item"}
    ].each do |attr|
      execute "ALTER TABLE `inv_inventory_serial_part` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_inv_prn_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_srn_mst_organzation13", foreign_key: "store_id", reference_table: "organizations"}
    ].each do |attr|
      execute "ALTER TABLE `inv_prn` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_prn_grn_item_grn_item1", foreign_key: "grn_item_id", reference_table: "inv_grn_item"},
      {constraint_name: "fk_prn_grn_item_prn_item1", foreign_key: "prn_item_id", reference_table: "inv_prn_item"}
    ].each do |attr|
      execute "ALTER TABLE `inv_prn_grn_item` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_prn_item_prn1", foreign_key: "prn_id", reference_table: "inv_prn"},
      {constraint_name: "fk_srn_item_mst_product13", foreign_key: "product_id", reference_table: "mst_inv_product"}
    ].each do |attr|
      execute "ALTER TABLE `inv_prn_item` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_inv_sbn_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_srn_mst_organzation12", foreign_key: "store_id", reference_table: "organizations"},
      {constraint_name: "fk_srn_mst_organzation21", foreign_key: "requested_location_id", reference_table: "organizations"}
    ].each do |attr|
      execute "ALTER TABLE `inv_sbn` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_sbn_item_sbn1", foreign_key: "sbn_id", reference_table: "inv_sbn"},
      {constraint_name: "fk_srn_item_mst_product12", foreign_key: "product_id", reference_table: "mst_inv_product"}
    ].each do |attr|
      execute "ALTER TABLE `inv_sbn_item` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_gin_source_grn_item101", foreign_key: "grn_item_id", reference_table: "inv_grn_item"},
      {constraint_name: "fk_inv_sbn_item_source_inv_inventory_serial_part1", foreign_key: "serial_part_id", reference_table: "inv_inventory_serial_part"},
      {constraint_name: "fk_inv_sbn_item_source_mst_currency1", foreign_key: "currency_id", reference_table: "mst_currency"},
      {constraint_name: "fk_inv_sbn_item_source_users1", foreign_key: "reserve_terminated_by", reference_table: "users"},
      {constraint_name: "fk_sbn_item_source_grn_batch1", foreign_key: "grn_batch_id", reference_table: "inv_grn_batch"},
      {constraint_name: "fk_sbn_item_source_grn_serial_item1", foreign_key: "grn_serial_item_id", reference_table: "inv_grn_serial_item"},
      {constraint_name: "fk_sbn_item_source_sbn_item1", foreign_key: "sbn_item_id", reference_table: "inv_sbn_item"}
    ].each do |attr|
      execute "ALTER TABLE `inv_sbn_item_source` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_inv_serial_additional_cost_mst_currency1", foreign_key: "currency_id", reference_table: "mst_currency"},
      {constraint_name: "fk_inv_serial_additional_cost_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_inv_serial_warranty_inv_inventory_serial_item10", foreign_key: "serial_item_id", reference_table: "inv_inventory_serial_item"}
    ].each do |attr|
      execute "ALTER TABLE `inv_serial_additional_cost` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_inv_serial_additional_cost_mst_currency10", foreign_key: "currency_id", reference_table: "mst_currency"},
      {constraint_name: "fk_inv_serial_additional_cost_users10", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_inv_serial_part_additional_cost_inv_inventory_serial_par_idx", foreign_key: "serial_part_id", reference_table: "inv_inventory_serial_part"}
    ].each do |attr|
      execute "ALTER TABLE `inv_serial_part_additional_cost` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_inv_batch_warranty_inv_warranty100", foreign_key: "warranty_id", reference_table: "inv_warranty"},
      {constraint_name: "fk_inv_serial_part_warranty_inv_inventory_serial_part1", foreign_key: "serial_part_id", reference_table: "inv_inventory_serial_part"}
    ].each do |attr|
      execute "ALTER TABLE `inv_serial_part_warranty` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_inv_batch_warranty_inv_warranty10", foreign_key: "warranty_id", reference_table: "inv_warranty"},
      {constraint_name: "fk_inv_serial_warranty_inv_inventory_serial_item1", foreign_key: "serial_item_id", reference_table: "inv_inventory_serial_item"}
    ].each do |attr|
      execute "ALTER TABLE `inv_serial_warranty` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_inv_srn_mst_inv_module1", foreign_key: "requested_module_id", reference_table: "mst_module"},
      {constraint_name: "fk_inv_srn_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_srn_mst_organzation1", foreign_key: "store_id", reference_table: "organizations"},
      {constraint_name: "fk_srn_mst_organzation2", foreign_key: "requested_location_id", reference_table: "organizations"}
    ].each do |attr|
      execute "ALTER TABLE `inv_srn` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_srn_item_mst_product1", foreign_key: "product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_srn_item_mst_reasons1", foreign_key: "issue_terminated_reason_id", reference_table: "mst_inv_reason"},
      {constraint_name: "fk_srn_item_srn1", foreign_key: "srn_id", reference_table: "inv_srn"},
      {constraint_name: "fk_srn_item_users1", foreign_key: "issue_terminated_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `inv_srn_item` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_srn_sbn_item_sbn_item1", foreign_key: "sbn_item_id", reference_table: "inv_sbn_item"},
      {constraint_name: "fk_srn_sbn_item_sbn_item_source1", foreign_key: "sbn_item_source_id", reference_table: "inv_sbn_item_source"},
      {constraint_name: "fk_srn_sbn_item_srn_item1", foreign_key: "srn_item_id", reference_table: "inv_srn_item"}
    ].each do |attr|
      execute "ALTER TABLE `inv_srn_sbn_item` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_inv_srr_mst_inv_module1", foreign_key: "requested_module_id", reference_table: "mst_module"},
      {constraint_name: "fk_inv_srr_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_srn_mst_organzation11", foreign_key: "store_id", reference_table: "organizations"},
      {constraint_name: "fk_srn_mst_organzation20", foreign_key: "requested_location_id", reference_table: "organizations"}
    ].each do |attr|
      execute "ALTER TABLE `inv_srr` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_srn_item_mst_product11", foreign_key: "product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_srr_item_mst_product_condition1", foreign_key: "product_condition_id", reference_table: "mst_inv_product_condition"},
      {constraint_name: "fk_srr_item_mst_reasons1", foreign_key: "return_reason_id", reference_table: "mst_inv_reason"},
      {constraint_name: "fk_srr_item_srn_item1", foreign_key: "returnable_srn_item_id", reference_table: "inv_srn_item"},
      {constraint_name: "fk_srr_item_srr1", foreign_key: "srr_id", reference_table: "inv_srr"}
    ].each do |attr|
      execute "ALTER TABLE `inv_srr_item` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_srr_item_source_srr_item10", foreign_key: "srr_item_id", reference_table: "inv_srr_item"},
      {constraint_name: "fk_srr_item_source_gin_source1", foreign_key: "gin_source_id", reference_table: "inv_gin_source"},
      {constraint_name: "fk_inv_srr_item_source_mst_currency1", foreign_key: "currency_id", reference_table: "mst_currency"}
    ].each do |attr|
      execute "ALTER TABLE `inv_srr_item_source` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_stock_taking_mst_organzation1", foreign_key: "store_id", reference_table: "organizations"},
      {constraint_name: "fk_Stock_Taking_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_Stock_Taking_users2", foreign_key: "stock_taken_by", reference_table: "users"},
      {constraint_name: "fk_Stock_Taking_users3", foreign_key: "store_keeper_by", reference_table: "users"},
      {constraint_name: "fk_Stock_Taking_users4", foreign_key: "inspected1_by", reference_table: "users"},
      {constraint_name: "fk_Stock_Taking_users5", foreign_key: "inspected2_by", reference_table: "users"},
      {constraint_name: "fk_Stock_Taking_users6", foreign_key: "inspected3_by", reference_table: "users"},
      {constraint_name: "fk_Stock_Taking_users7", foreign_key: "inspected4_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `inv_stock_taking` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_Stock_Taking_grn_Item_stock_taking_item1", foreign_key: "stock_taking_item_id", reference_table: "inv_stock_taking_item"},
      {constraint_name: "fk_Stock_Taking_grn_Item_grn_item1", foreign_key: "grn_item_id", reference_table: "inv_grn_item"},
      {constraint_name: "fk_Stock_Taking_grn_Item_grn_batch1", foreign_key: "grn_batch_id", reference_table: "inv_grn_batch"},
      {constraint_name: "fk_Stock_Taking_grn_Item_grn_serial_item1", foreign_key: "grn_serial_item_id", reference_table: "inv_grn_serial_item"}
    ].each do |attr|
      execute "ALTER TABLE `inv_stock_taking_grn_item` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_stock_taking_item_stock_taking1", foreign_key: "stock_taking_id", reference_table: "inv_stock_taking"},
      {constraint_name: "fk_stock_taking_item_mst_product1", foreign_key: "product_id", reference_table: "mst_inv_product"}
    ].each do |attr|
      execute "ALTER TABLE `inv_stock_taking_item` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_inv_warranty_mst_inv_warranty_type1", foreign_key: "warranty_type_id", reference_table: "mst_inv_warranty_type"},
      {constraint_name: "fk_inv_warranty_users1", foreign_key: "created_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `inv_warranty` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "FK_mst_bpm_role_mst_module", foreign_key: "module_id", reference_table: "mst_module"}
    ].each do |attr|
      execute "ALTER TABLE `mst_bpm_role` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_bin_mst_shell1", foreign_key: "shelf_id", reference_table: "mst_inv_shelf"},
      {constraint_name: "fk_mst_inv_bin_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_mst_inv_bin_users2", foreign_key: "updated_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `mst_inv_bin` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_inv_category1_users11", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_mst_inv_category1_users21", foreign_key: "updated_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `mst_inv_category1` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_inv_category2_users10", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_mst_inv_category2_users20", foreign_key: "updated_by", reference_table: "users"},
      {constraint_name: "fk_mst_inv_category2_mst_inv_category11", foreign_key: "category1_id", reference_table: "mst_inv_category1"}
    ].each do |attr|
      execute "ALTER TABLE `mst_inv_category2` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_inv_category3_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_mst_inv_category3_users2", foreign_key: "updated_by", reference_table: "users"},
      {constraint_name: "fk_mst_inv_category3_mst_inv_category21", foreign_key: "category2_id", reference_table: "mst_inv_category2"}
    ].each do |attr|
      execute "ALTER TABLE `mst_inv_category3` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_inv_disposal_method_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_mst_inv_disposal_method_users2", foreign_key: "updated_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `mst_inv_disposal_method` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_inv_manufacture_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_mst_inv_manufacture_users2", foreign_key: "updated_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `mst_inv_manufacture` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_inv_product_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_mst_inv_product_users2", foreign_key: "updated_by", reference_table: "users"},
      {constraint_name: "fk_mst_product_mst_unit1", foreign_key: "unit_id", reference_table: "mst_inv_unit"},
      {constraint_name: "fk_product_cat3_mast", foreign_key: "category3_id", reference_table: "mst_inv_category3"}
    ].each do |attr|
      execute "ALTER TABLE `mst_inv_product` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_inv_product_condition_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_mst_inv_product_condition_users2", foreign_key: "updated_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `mst_inv_product_condition` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_inv_product_info_mst_currency1", foreign_key: "currency_id", reference_table: "mst_currency"},
      {constraint_name: "fk_mst_inv_product_info_mst_inv_product1", foreign_key: "product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_mst_product_mst_country10", foreign_key: "country_id", reference_table: "mst_country"},
      {constraint_name: "fk_mst_product_mst_manufacture10", foreign_key: "manufacture_id", reference_table: "mst_inv_manufacture"},
      {constraint_name: "fk_mst_product_mst_unit20", foreign_key: "secondary_unit_id", reference_table: "mst_inv_unit"}
    ].each do |attr|
      execute "ALTER TABLE `mst_inv_product_info` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_inv_rack_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_mst_inv_rack_users2", foreign_key: "updated_by", reference_table: "users"},
      {constraint_name: "fk_mst_rack_mst_organzation1", foreign_key: "location_id", reference_table: "organizations"}
    ].each do |attr|
      execute "ALTER TABLE `mst_inv_rack` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_inv_reason_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_mst_inv_reason_users2", foreign_key: "updated_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `mst_inv_reason` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_inv_shelf_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_mst_inv_shelf_users2", foreign_key: "updated_by", reference_table: "users"},
      {constraint_name: "fk_mst_shell_mst_rack1", foreign_key: "rack_id", reference_table: "mst_inv_rack"}
    ].each do |attr|
      execute "ALTER TABLE `mst_inv_shelf` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_inv_unit_users1", foreign_key: "created_by", reference_table: "users"},
      {constraint_name: "fk_mst_inv_unit_users2", foreign_key: "updated_by", reference_table: "users"},
      {constraint_name: "fk_mst_unit_mst_unit1", foreign_key: "base_unit_id", reference_table: "mst_inv_unit"}
    ].each do |attr|
      execute "ALTER TABLE `mst_inv_unit` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_spt_ticket_action_mst_groups1", foreign_key: "groups_id", reference_table: "roles"}
    ].each do |attr|
      execute "ALTER TABLE `mst_spt_action` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_general_question_mst_spt_action1", foreign_key: "action_id", reference_table: "mst_spt_action"}
    ].each do |attr|
      execute "ALTER TABLE `mst_spt_general_question` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_problematic_question_mst_spt_action1", foreign_key: "action_id", reference_table: "mst_spt_action"},
      {constraint_name: "fk_spt_problematic_question_spt_problem_category1", foreign_key: "problem_category_id", reference_table: "spt_problem_category"}
    ].each do |attr|
      execute "ALTER TABLE `mst_spt_problematic_question` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_spt_prodcut_brand_mst_currency2", foreign_key: "currency_id", reference_table: "mst_currency"},
      {constraint_name: "fk_mst_spt_prodcut_brand_mst_organzation1", foreign_key: "organization_id", reference_table: "organizations"},
      {constraint_name: "fk_mst_spt_product_brand_mst_spt_sla1", foreign_key: "sla_id", reference_table: "mst_spt_sla"}

    ].each do |attr|
      execute "ALTER TABLE `mst_spt_product_brand` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_spt_product_category_mst_spt_prodcut_brand1", foreign_key: "product_brand_id", reference_table: "mst_spt_product_brand"},
      {constraint_name: "fk_mst_spt_product_category_mst_spt_sla1", foreign_key: "sla_id", reference_table: "mst_spt_sla"}
    ].each do |attr|
      execute "ALTER TABLE `mst_spt_product_category` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_spt_sbu_engineer_mst_spt_sbu1", foreign_key: "sbu_id", reference_table: "mst_spt_sbu"},
      {constraint_name: "fk_mst_spt_sbu_engineer_users1", foreign_key: "engineer_id", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `mst_spt_sbu_engineer` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_spt_sla_users1", foreign_key: "created_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `mst_spt_sla` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "FK__roles", foreign_key: "role_id", reference_table: "roles"}
    ].each do |attr|
      execute "ALTER TABLE `role_bpm_role` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "FK__mst_bpm_role", foreign_key: "bpm_role_id", reference_table: "mst_bpm_role"}
    ].each do |attr|
      execute "ALTER TABLE `role_bpm_role` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "FK_spt_act_print_invoice_spt_ticket_action", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"},
      {constraint_name: "FK_spt_act_print_invoice_spt_invoice", foreign_key: "invoice_id", reference_table: "spt_invoice"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_print_invoice` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "FK__users", foreign_key: "engineer_id", reference_table: "users"},
      {constraint_name: "FK__spt_regional_support_center", foreign_key: "regional_support_center_id", reference_table: "spt_regional_support_center"}
    ].each do |attr|
      execute "ALTER TABLE `spt_regional_support_center_engineer` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "FK_spt_ticket_extra_remark_mst_spt_extra_remark", foreign_key: "extra_remark_id", reference_table: "mst_spt_extra_remark"},
      {constraint_name: "FK_spt_ticket_extra_remark_spt_ticket", foreign_key: "ticket_id", reference_table: "spt_ticket"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_extra_remark` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "FK__spt_ticket", foreign_key: "ticket_id", reference_table: "spt_ticket"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket_workflow_process` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end
  end
end