class InsertInitialValues < ActiveRecord::Migration
  def change
    # [
    #   ["CW", "Corporate warranty"],
    #   ["MW", "Manufacture warranty"],
    #   ["NW", "Non warranty"],
    #   ["UW", "UnKnown"]
    # ].each do |value|
    #   execute("insert into mst_spt_warranty_type (code, name) values ('#{value[0]}', '#{value[1]}')")
    # end

    # [
    #   ["IH", "In house"],
    #   ["OS", "On-site"]
    # ].each do |value|
    #   execute("insert into mst_spt_ticket_type (code, name) values ('#{value[0]}', '#{value[1]}')")
    # end

    [
      ["PRQ", "Part Requested"],
      ["POD", "Part Ordered"],
      ["PRC", "Part Received"],
      ["ERQ", "Estimation Requested"],
      ["EST", "Estimated"],
      ["UDL", "Unit Delivered"],
      ["NAP", "Not Applicable"],
      ["FST", "First Level Resolved"],
      ["RSV", "Resolved"],
      ["TER", "Terminated"]
    ].each do |value|
      execute("insert into mst_spt_ticket_status_resolve (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    # [
    #   ["OPN", "Open"],
    #   ["ASN", "Assigned"],
    #   ["RSL", "Being Resolved"],
    #   ["QCT", "Quality Control"],
    #   ["PMT", "Final Payment Calculation"],
    #   ["CFB", "Customer Feedback and Issue"],
    #   ["ROP", "Re-Open"],
    #   ["TBC", "To Be Closed"],
    #   ["CLS", "Closed"]
    # ].each do |value|
    #   execute("insert into mst_spt_ticket_status (code, name) values ('#{value[0]}', '#{value[1]}')")
    # end

    [
      ["IN", "Internal Repair"],
      ["EX", "External Repair"]
    ].each do |value|
      execute("insert into mst_spt_ticket_repair_type (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    # [
    #   ["PH", "by phone"],
    #   ["CR", "carry in"],
    #   ["ML", "by mail"],
    #   ["FX", "fax"]
    # ].each do |value|
    #   execute("insert into mst_spt_ticket_informed_method (code, name) values ('#{value[0]}', '#{value[1]}')")
    # end

    [
      ["NAP", "Not Applicable"],
      ["USD", "Used"],
      ["UUS", "Un - Used"],
      ["DOA", "Dead on Arrival"],
      ["WSP", "Wrong Shipment"],
      ["WPB", "Wrong  Part in the Box"]
    ].each do |value|
      execute("insert into mst_spt_spare_part_status_use (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["AD", "Advance payment"],
      ["FN", "Final payment"],
      ["OH", "Other"]
    ].each do |value|
      execute("insert into mst_spt_payment_received_type (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["Extra Labour", 0],
    ].each do |value|
      execute("insert into mst_spt_payment_item (name, default_amount) values ('#{value[0]}', '#{value[1]}')")
    end

    # [
    #   ["SW", "Softwear"],
    #   ["HW", "Hardwear"],
    #   ["NW", "Network"]
    # ].each do |value|
    #   execute("insert into mst_spt_job_type (code, name) values ('#{value[0]}', '#{value[1]}')")
    # end

    # [
    #   ["RQS", "Requested"],
    #   ["EST", "Estimated"],
    #   ["CLS", "Closed"],
    #   ["APP", "Advance Payment Pending"]
    # ].each do |value|
    #   execute("insert into mst_spt_estimation_status (code, name) values ('#{value[0]}', '#{value[1]}')")
    # end

    # [
    #   ["Telephone", "0", "0"],
    #   ["Mobile", "1", "0"],
    #   ["Fax", "0", "0"],
    #   ["E-Mail", "0", "1"],
    #   ["Skype", "0", "0"],
    # ].each do |value|
    #   execute("insert into mst_spt_customer_contact_type (name, mobile, email) values ('#{value[0]}', '#{value[1]}', '#{value[2]}')")
    # end

    # [
    #   ["ML", "Email"],
    #   ["SM", "SMS"],
    #   ["CL", "Call"],
    #   ["FX", "Fax"],
    # ].each do |value|
    #   execute("insert into mst_spt_contact_type (code, name) values ('#{value[0]}', '#{value[1]}')")
    # end

    # [
    #   ["1", "Add ticket", "1", 0],
    #   ["2", "Assign Ticket", "2", 0],
    #   ["3", "Edit Ticket", "1", 0],
    #   ["4", "Assign Regional Support Center", "2", 0],
    #   ["5", "Start Action", "3", 0],
    #   ["6", "Re-Assign Request", "3", 0],
    #   ["7", "Terminate Job", "3", 0],
    #   ["8", "Hold", "3,9,12", 0],
    #   ["9", "Un Hold", "3,9,12", 0],
    #   ["10", "Edit Serial No Request", "3", 0],
    #   ["11", "Create FSR", "3", 0],
    #   ["12", "Edit FSR (Un Approved )", "3", 0],
    #   ["13", "Action Taken", "3", 0],
    #   ["14", "Request Spare Part from Manufacture", "3", 0],
    #   ["15", "Request Spare Part from Store", "3", 0],
    #   ["16", "Receive Spare Part by eng", "3", 0],
    #   ["17", "Return Part (Spare/Faulty)", "3", 0],
    #   ["18", "Request On Loan  Spare Part", "3", 0],
    #   ["19", "Terminate Spare Part", "3", 0],
    #   ["20", "HP Case Action", "3", 0],
    #   ["21", "Resolve the Job (Finish the Job)", "3", 0],
    #   ["22", "Deliver Unit", "3", 0],
    #   ["23", "Job Estimate Request", "3", 0],
    #   ["24", "Estimation Customer Aproved", "3", 0],
    #   ["25", "Recieve Unit", "3", 0],
    #   ["26", "Customer Inqure", "3", 0],
    #   ["27", "Job Estimation Done", "7", 0],
    #   ["28", "Invoice Advance Payment", "27,29", 0],
    #   ["29", "Delivere Unit To Supplier", "8", 0],
    #   ["30", "Collect Unit From Supplier", "8", 0],
    #   ["31", "Order Spare Part from Supplier", "9", 0],
    #   ["32", "Request To Warranty Extend", "9", 0],
    #   ["33", "Request To Estimate Parts", "9", 0],
    #   ["34", "Terminate Spare Part Order", "9", 0],
    #   ["35", "Edit Serial No", "9,12", 0],
    #   ["36", "Collect Spare part from Manufacture", "23", 0],
    #   ["37", "Receive Spare part from Manufacture", "10", 0],
    #   ["38", "Issue Spare part", "10", 0],
    #   ["39", "Warranty Extend", "12", 0],
    #   ["40", "Reject Warranty Extend", "12", 0],
    #   ["41", "Low Margin Job Estimate Approval", "19", 0],
    #   ["42", "Reject Returned Part", "11", 0],
    #   ["43", "Receive Returned part", "11,18", 0],
    #   ["44", "Close Event", "11,30", 0],
    #   ["45", "Part Bunndled", "21", 0],
    #   ["46", "Part Bunndl Delivered", "22", 0],
    #   ["47", "Approve Spare Part for Store", "16", 0],
    #   ["48", "Issue store Spare Part", "17", 0],
    #   ["49", "Approve On-Loan Part for Store", "16", 0],
    #   ["50", "Issue store On-Loan Part", "17", 0],
    #   ["51", "Receive On-Loan Part by eng", "3", 0],
    #   ["52", "Return On-Loan part", "3", 0],
    #   ["53", "Terminate On-Loan Part", "3", 0],
    #   ["54", "Receive Returned On-Loan part", "18", 0],
    #   ["55", "Request to Close Ticket", "3", 0],
    #   ["56", "Approve Close Ticket", "13", 0],
    #   ["57", "Quality Control Approved", "28", 0],
    #   ["58", "Customer Feedback", "14", 0],
    #   ["59", "Terminate FOC Job Approval", "31", 0],
    #   ["60", "Terminate Job Issue and Invoice", "24", 0],
    #   ["61", "Inform Customer", "14,24", 0],
    #   ["62", "POP Approval", "5", 0],
    #   ["63", "Estimate Job Final", "33", 0],
    #   ["64", "Reject Spare Part for Store", "16", 0],
    #   ["65", "Reject On-Loan Part for Store", "16", 0],
    #   ["66", "Reject Close Ticket", "13", 0],
    #   ["67", "Quality Control Rejected", "28", 0]
    # ].each do |value|
    #   execute("insert into mst_spt_action (action_no, action_description, task_id, hide) values ('#{value[0]}', '#{value[1]}', '#{value[2]}', '#{value[3]}')")
    # end

    # [
    #   ["HDO", "Head Office"],
    #   ["BRN", "Branch"],
    #   ["DPT", "Department"],
    #   ["STR", "Store"]
    # ].each do |value|
    #   execute("insert into mst_organizations_types (code, name) values ('#{value[0]}', '#{value[1]}')")
    # end

    # [
    #   ["Sri Lankan Rupees", "LKR", "Rs", "1"],
    #   ["United States Dollars", "USD", "$US", "0"]
    # ].each do |value|
    #   execute("insert into mst_currency (currency, code, symbol, base_currency) values ('#{value[0]}', '#{value[1]}', '#{value[2]}', '#{value[3]}')")
    # end

    # [
    #   ["NAP", "Not Applicable"],
    #   ["RCD", "Received"],
    #   ["RPN", "Receive Pending"],
    #   ["APN", "Approval Pending"],
    #   ["LPN", "Pending From Local Provider"],
    #   ["APV", "Approved"],
    #   ["RJC", "Rejected"],
    #   ["UPD", "Updated"]
    # ].each do |value|
    #   execute("insert into mst_spt_pop_status (code, name) values ('#{value[0]}', '#{value[1]}')")
    # end

    # [
    #   ["Check outer condition?", "YN", 1, 1, 1],
    #   ["Any damage in the casing?", "TX", 1, 1, 0]
    # ].each do |value|
    #   execute("insert into mst_spt_general_question (question, answer_type, active, action_id, compulsory) values ('#{value[0]}', '#{value[1]}', '#{value[2]}', '#{value[3]}', '#{value[4]}')")
    # end

    # [
    #   ["Mr."],
    #   ["Mrs."],
    #   ["Ms."],
    #   ["Miss."]
    # ].each do |value|
    #   execute("insert into mst_title (title) values ('#{value[0]}')")
    # end

    # [
    #   ["SPPT", "add_ticket", "/tickets/edit-ticket", "SPT_SC_1", "Support - Edit Ticket", "h1", "ticket_id,supp_hd_user",nil],
    #   ["SPPT", "assign_ticket", "/tickets/assign-ticket", "SPT_SC_2", "Support - Assign Ticket", "h1", "ticket_id", nil],
    #   ["SPPT", "resolution", "/tickets/resolution", "SPT_SC_3", "Support - Resolution", "h1", "ticket_id,supp_engr_user", nil],
    #   ["SPPT", "pop_approval", "/tickets/pop-approval", "SPT_SC_5", "Support - POP Approval", "h1", "ticket_id", nil],
    #   ["SPPT", "edit_serial_no", "", "SPT_SC_6", "Support - Edit Serial No", "h1", "ticket_id", nil],
    #   ["SPPT", "job_estimate", "", "SPT_SC_7", "Support - Job Estimation", "h1", "ticket_id", nil],
    #   ["SPPT", "mark_delivered_colleted", "", "SPT_SC_8", "Support - Units To Be Delivered or Colleced for External Repaire", "h1", "ticket_id,deliver_unit_id", nil],
    #   ["SPPT_MFR_PART_REQUEST", "order_part", "", "SPT_SC_9", "Support - Order Part (Manufacture)", "h3", "ticket_id,request_spare_part_id,supp_engr_user", nil],
    #   ["SPPT_MFR_PART_REQUEST", "receive_Issue_part", "", "SPT_SC_10", "Support - Receive or Issue Part (Manufacture)", "h3", "ticket_id,request_spare_part_id,supp_engr_user", nil],
    #   ["SPPT_MFR_PART_RETURN", "return_manufacture_part", "", "SPT_SC_11", "Support - Return Part (Manufacture)", "h3", "ticket_id,request_spare_part_id,supp_engr_user", nil],
    #   ["SPPT", "extend_warranty", "", "SPT_SC_12", "Support - Extend Warranty", "h1", "ticket_id", nil],
    #   ["SPPT", "approve_close_ticket", "", "SPT_SC_13", "Support - Ticket Close Approval", "h1", "ticket_id,supp_engr_user", nil],
    #   ["SPPT", "customer_feedback", "", "SPT_SC_14", "Support - Customer Feedback", "h1", "ticket_id,supp_engr_user", nil],
    #   ["SPPT_PART_ESTIMATE", "part_estimate", "", "SPT_SC_15", "Support - Part Estimation (Store)", "h2", "ticket_id,part_estimation_id,supp_engr_user", nil],
    #   ["SPPT_STORE_PART_REQUEST", "approve_store_part", "", "SPT_SC_16", "Support - Part Approval (Store)", "h2", "ticket_id,request_spare_part_id,request_onloan_spare_part_id,onloan_request,supp_engr_user", nil],
    #   ["SPPT_STORE_PART_REQUEST", "issue_store_part", "", "SPT_SC_17", "Support - Issue Part (Store)", "h2", "ticket_id,request_spare_part_id,request_onloan_spare_part_id,onloan_request,supp_engr_user", nil],
    #   ["SPPT_STORE_PART_RETURN", "return_store_part", "", "SPT_SC_18", "Support - Return Part (Store)", "h2", "ticket_id,request_spare_part_id,request_onloan_spare_part_id,onloan_request", nil],
    #   ["SPPT", "approve_job_estimate", "", "SPT_SC_19", "Support - Job Estimation Approval", "h1", "ticket_id", nil],
    #   ["SPPT_PART_ESTIMATE", "approve_part_estimate", "", "SPT_SC_20", "Support - Part Estimation Approval (Store)", "h2", "ticket_id,part_estimation_id,supp_engr_user", nil],
    #   ["SPPT_MFR_PART_RETURN", "bundle_return_part", "", "SPT_SC_21", "Support - Return Parts To Be Bundled", nil, "ticket_id,request_spare_part_id", nil],
    #   ["SPPT_MFR_PART_RETURN", "bundle_deliver", "", "SPT_SC_22", "Support - Return Parts Bundles To Be Delivered", nil, "bundle_id", nil],
    #   ["SPPT_MFR_PART_REQUEST", "collect_part", "", "SPT_SC_23", "Support - Manufacture parts to be collected", nil, "ticket_id,request_spare_part_id", nil],
    #   ["SPPT", "issue_customer_terminate", "", "SPT_SC_24", "Support - Terminated Job Return To Custormer", "h1", "ticket_id", nil],
    #   ["SPPT", "customer_advance_payment", "", "SPT_SC_27", "", nil, nil, nil],
    #   ["SPPT", "quality_control", "", "SPT_SC_28", "Support - Quality Control", "h1", "ticket_id,supp_engr_user", nil],
    #   ["SPPT", "invoice_advance_payment", "", "SPT_SC_29", "Support - Advance Payment Invoice", "h1", "ticket_id,advance_payment_estimation_id", nil],
    #   ["SPPT_MFR_PART_RETURN", "close_event", "", "SPT_SC_30", "Support - Close Event", "h1", "ticket_id,request_spare_part_id", nil],
    #   ["SPPT", "approve_foc", "", "SPT_SC_31", "Support - FOC Approval", "h1", "ticket_id", nil],
    #   ["SPPT", "final_job_estimate", "", "SPT_SC_33", "Support - Final Job Estimation", "h1", "ticket_id", nil]
    # ].each do |value|
    #   execute("insert into workflow_mappings (process_name, task_name, url, screen, first_header_title, second_header_title_name, input_variables, output_variables) values ('#{value[0]}', '#{value[1]}', '#{value[2]}', '#{value[3]}', '#{value[4]}', '#{value[5]}', '#{value[6]}', '#{value[7]}')")
    # end

    [
      ["SPT", "Support"],
      ["SLS", "Sales"],
      ["INV", "Inventory"],
      ["PCH", "Purchase"]
    ].each do |value|
      execute("insert into mst_module (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      [1, "supp_hd", "Help Desk"],
      [1, "supp_mgr", "Support Manager"],
      [1, "supp_engr", "Support Engineer"],
      [1, "supp_coord", "Coordinator"],
      [1, "supp_cus_rep", "Customer Support Representative"],
      [1, "supp_acct", "Accountant"],
      [1, "supp_charg_engr", "Chargeable Engineer"],
      [1, "supp_sk", "Store keeper"],
      [1, "supp_del_coord", "Delivery coordinator"],
      [1, "supp_qc", "Quality Controler"]
    ].each do |value|
      execute("insert into mst_bpm_role (module_id, code, name) values ('#{value[0]}', '#{value[1]}', '#{value[2]}')")
    end

    [
      [1, "Brand"],
      [2, "Product"],
      [3, "Category"]
    ].each do |value|
      execute("insert into mst_inv_category_caption (level, caption) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["Original"],
      ["Good"],
      ["Not Good"]
    ].each do |value|
      execute("insert into `mst_inv_product_condition` (`condition`) values ('#{value[0]}')")
    end
   
    [
      ["AV", "Available"],
      ["NA", "Not Available"]
    ].each do |value|
      execute("insert into mst_inv_serial_item_status (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["MW", "Manufacture Warranty"],
      ["CW", "Corparate Warranty"]
    ].each do |value|
      execute("insert into mst_inv_warranty_type (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["Marks on Cover / Display"],
      ["Toner / Ink - Leak / Refill"],
      ["Burn Marks"],
      ["Physical Damage / Covers / Display"],
      ["Tempered"]
    ].each do |value|
      execute("insert into mst_spt_extra_remark (extra_remark) values ('#{value[0]}')")
    end

    [
      ["RQT", "Requested", "1", "1", "1", "1"],
      ["ORD", "Ordered from Manufacturer", "2", "0", "3", "0"],
      ["CLT", "Collected from Manufacturer", "3", "0", "3", "0"],
      ["RCS", "Received from Manufacturer", "4", "0", "3", "0"],
      ["ISS", "Issued", "5", "4", "6", "4"],
      ["RCE", "Received by Engineer", "6", "5", "7", "5"],
      ["RTN", "Part Return by Engineer", "7", "6", "0", "6"],
      ["RPR", "Returned Part Reject", "8", "7", "0", "7"],
      ["RPA", "Returned Part Accepted", "8", "7", "0", "7"],
      ["BND", "Part Bundled", "10", "0", "0", "0"],
      ["CLS", "Close", "11", "8", "8", "8"],
      ["ECM", "Estimation Completed", "0", "0", "2", "0"],
      ["CEA", "Cus. Estimation Approved", "0", "0", "3", "0"],
      ["STR", "Request from Store", "0", "2", "4", "2"],
      ["APS", "Approved Store Request", "0", "3", "5", "3"],
      ["RJS", "Reject Store Request", "0", "3", "5", "3"],
      ["RBN", "Ready to Bundle", "9", "0", "0", "0"]
    ].each do |value|
      execute("insert into mst_spt_spare_part_status_action (code, name, manufacture_type_index, store_nc_type_index, store_ch_type_index, on_loan_type_index) values ('#{value[0]}', '#{value[1]}', '#{value[2]}', '#{value[3]}', '#{value[4]}', '#{value[5]}')")
    end

    [
      ["ML", "Email"],
      ["SM", "SMS"],
      ["CL", "Call"],
      ["FX", "Fax"]
    ].each do |value|
      execute("insert into mst_spt_contact_type (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      [nil, "PRINT_SPPT_INVOICE", "PRINT_SPPT_TICKET", "PRINT_SPPT_TICKET_COMPLETE", "PRINT_SPPT_FSR"]
    ].each do |value|
      execute("insert into mst_spt_templates (invoice, invoice_request_type, ticket_request_type, ticket_complete_request_type, fsr_request_type) values ('#{value[0]}', '#{value[1]}', '#{value[2]}', '#{value[3]}', '#{value[4]}')")
    end

  end
end
