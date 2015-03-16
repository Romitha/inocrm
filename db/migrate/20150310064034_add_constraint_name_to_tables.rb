class AddConstraintNameToTables < ActiveRecord::Migration
  def change
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
      {constraint_name: "fk_spt_ticket_users2", foreign_key: "owner_engineer_id", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_workflow_alert_users_users1", foreign_key: "user_id", reference_table: "users"},
      {constraint_name: "fk_workflow_alert_users_workflow_alerts1", foreign_key: "user_id", reference_table: "workflow_alerts"}
    ].each do |attr|
      execute "ALTER TABLE `workflow_alert_users` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
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
      {constraint_name: "fk_spt_ticket_spare_part_mst_spt_reason1", foreign_key: "terminated_reason_id", reference_table: "mst_spt_reason"},
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
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_status_action_spt_ticket_on_1", foreign_key: "on_loan_spare_part_id", reference_table: "spt_ticket_on_loan_spare_part"},
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
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_mst_inv_product2", foreign_key: "appoved_inv_product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_mst_inv_product3", foreign_key: "approved_main_inv_product_id", reference_table: "mst_inv_product"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_mst_inv_reason1", foreign_key: "return_part_damage_reason_id", reference_table: "mst_inv_reason"},
      {constraint_name: "fk_spt_ticket_on_loan_spare_part_mst_spt_reason1", foreign_key: "terminated_reason_id", reference_table: "mst_spt_reason"},
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
      {constraint_name: "fk_spt_product_serial_warranty_mst_spt_warranty_type1", foreign_key: "warranty_type_id", reference_table: "mst_spt_warranty_type"},
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

    [
      {constraint_name: "fk_spt_invoice_print_history_spt_invoice1", foreign_key: "invoice_id", reference_table: "spt_invoice"},
      {constraint_name: "fk_spt_invoice_print_history_spt_print_history1", foreign_key: "print_history_id", reference_table: "spt_print_history"}
    ].each do |attr|
      execute "ALTER TABLE `spt_invoice_print_history` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

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

    [
      {constraint_name: "fk_spt_fsr_print_history_spt_ticket_fsr1", foreign_key: "fsr_id", reference_table: "spt_ticket_fsr"},
      {constraint_name: "fk_spt_invoice_print_history_spt_print_history101", foreign_key: "print_history_id", reference_table: "spt_print_history"}
    ].each do |attr|
      execute "ALTER TABLE `spt_fsr_print_history` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_customer_contact_type_mst_spt_customer_contact_type1", foreign_key: "contact_type_id", reference_table: "mst_spt_customer_contact_type"},
      {constraint_name: "fk_spt_customer_contact_type_spt_customer1", foreign_key: "customer_id", reference_table: "spt_customer"}
    ].each do |attr|
      execute "ALTER TABLE `spt_customer_contact_type` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_customer_mst_organzation1", foreign_key: "organization_id", reference_table: "organizations"},
      {constraint_name: "fk_spt_customer_mst_title1", foreign_key: "title_id", reference_table: "mst_title"}
    ].each do |attr|
      execute "ALTER TABLE `spt_customer` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_cus_recieved_note_print_history_spt_ticket10", foreign_key: "ticket_id", reference_table: "spt_ticket"},
      {constraint_name: "fk_spt_invoice_print_history_spt_print_history100", foreign_key: "print_history_id", reference_table: "spt_print_history"}
    ].each do |attr|
      execute "ALTER TABLE `spt_cus_returned_note_print_history` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_cus_recieved_note_print_history_spt_ticket1", foreign_key: "ticket_id", reference_table: "spt_ticket"},
      {constraint_name: "fk_spt_invoice_print_history_spt_print_history10", foreign_key: "print_history_id", reference_table: "spt_print_history"}
    ].each do |attr|
      execute "ALTER TABLE `spt_cus_recieved_note_print_history` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_contract_product_mst_organzation1", foreign_key: "installed_location_id", reference_table: "organizations"},
      {constraint_name: "fk_spt_contract_product_spt_contract_info1", foreign_key: "contract_id", reference_table: "spt_contract"},
      {constraint_name: "fk_spt_product_contract_spt_product_serial10", foreign_key: "product_serial_id", reference_table: "spt_product_serial"}
    ].each do |attr|
      execute "ALTER TABLE `spt_contract_product` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_contract_info_mst_organzation1", foreign_key: "customer_id", reference_table: "organizations"},
      {constraint_name: "fk_spt_contract_users1", foreign_key: "created_by", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `spt_contract` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_contact_report_person_contact_type_spt_contact_report_1", foreign_key: "contact_report_person_id", reference_table: "spt_contact_report_person"},
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
      {constraint_name: "fk_spt_act_assign_franchise_agent_spt_ticket_action10010000", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"},
      {constraint_name: "fk_spt_act_request_spare_part_mst_spt_reason1", foreign_key: "terminate_reason_id", reference_table: "mst_spt_reason"},
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
      {constraint_name: "fk_spt_act_re_assign_request_mst_spt_reason1", foreign_key: "reason_id", reference_table: "mst_spt_reason"},
      {constraint_name: "fk_spt_act_re_assign_request_spt_ticket_action1", foreign_key: "ticket_action_id", reference_table: "spt_ticket_action"}
    ].each do |attr|
      execute "ALTER TABLE `spt_act_re_assign_request` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
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
      {constraint_name: "fk_spt_act_re_assign_request_spt_reason100", foreign_key: "reason_id", reference_table: "mst_spt_reason"}
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

    [
      {constraint_name: "fk_mst_spt_sbu_engineer_mst_spt_sbu1", foreign_key: "sbu_id", reference_table: "mst_spt_sbu"},
      {constraint_name: "fk_mst_spt_sbu_engineer_users1", foreign_key: "engineer_id", reference_table: "users"}
    ].each do |attr|
      execute "ALTER TABLE `mst_spt_sbu_engineer` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_spt_product_category_mst_spt_prodcut_brand1", foreign_key: "product_brand_id", reference_table: "mst_spt_product_brand"}
    ].each do |attr|
      execute "ALTER TABLE `mst_spt_product_category` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_spt_prodcut_brand_mst_currency2", foreign_key: "currency_id", reference_table: "mst_currency"},
      {constraint_name: "fk_mst_spt_prodcut_brand_mst_organzation1", foreign_key: "organization_id", reference_table: "organizations"}
    ].each do |attr|
      execute "ALTER TABLE `mst_spt_product_brand` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_problematic_question_mst_spt_action1", foreign_key: "action_id", reference_table: "mst_spt_action"},
      {constraint_name: "fk_spt_problematic_question_spt_problem_category1", foreign_key: "problem_category_id", reference_table: "spt_problem_category"}
    ].each do |attr|
      execute "ALTER TABLE `mst_spt_problematic_question` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_spt_general_question_mst_spt_action1", foreign_key: "action_id", reference_table: "mst_spt_action"}
    ].each do |attr|
      execute "ALTER TABLE `mst_spt_general_question` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_spt_ticket_action_mst_groups1", foreign_key: "groups_id", reference_table: "roles"}
    ].each do |attr|
      execute "ALTER TABLE `mst_spt_action` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

  end
end