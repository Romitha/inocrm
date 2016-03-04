
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
rpermissions = [
  ["Update user profile", "User", "edit_update"],
  ["View list of organizations", "Organization", "index"],
  ["Create new organization", "Organization", "new_create"],
  ["View own user profile", "User", "profile"],
  ["View own Organization", "Organization", "show"],
  ["Edit organization details", "Organization", "edit_update"],
  ["Create new user for Organization", "User", "new_create"]
]

organization = Organization.find_or_create_by name: "VS Information Systems", short_name: "VS Information Sys", code: "123456", web_site: "http://www.vsis.com", vat_number: "34358-90", refers: "VSIS", description: "VSIS is product owner of this application", type_id: 1
user = User.find_by_email("admin@inovacrm.com")
unless(user)
  user = User.create(email: "admin@inovacrm.com", password: "123456789", organization_id: organization.id)
  user.add_role :admin, organization
  user.add_role :default_user, organization

  admin = user.roles.find_by_name("admin")
  default_user = user.roles.find_by_name("default_user")
  admin.update_attribute(:parent_role, true)
  default_user.update_attribute(:parent_role, true)
  user.update_attribute :current_user_role_id, admin.id
  user.update_attribute :current_user_role_name, admin.name

  # Rpermission.find_or_create_by!(rpermissions.map { |rp| {name: rp[0], controller_resource: rp[1], controller_action: rp[2]} })
  rpermissions.each { |rp| Rpermission.create_with(controller_resource: rp[1], controller_action: rp[2]).find_or_create_by(name: rp[0]) }
  admin.rpermission_ids = [1,2,3,4,5,6,7]
  default_user.rpermission_ids = [2, 4, 5]
end

Ticket
Warranty

warranty_types = [
  ["CW", "Corporate warranty"],
  ["MW", "Manufacture warranty"],
  ["NW", "Non warranty"],
  ["UW", "UnKnown"]
].each{ |w| WarrantyType.create_with(name: w[1]).find_or_create_by(code: w[0])}

mst_spt_ticket_type = [
  ["IH", "In house"],
  ["OS", "On-site"]
].each{ |t| TicketType.create_with(name: t[1]).find_or_create_by(code: t[0])}

 mst_spt_ticket_status = [
  ["OPN", "Open", "00FF99"],
  ["ASN", "Assigned", "CAA3D3"],
  ["RSL", "Being Resolved", "81DAF5"],
  ["QCT", "Quality Control", "F0FC7E"],
  ["PMT", "Final Payment Calculation", "F9A763"],
  ["CFB", "Customer Feedback and Issue", "8E87CE"],
  ["ROP", "Re-Open", "FAC4FA"],
  ["TBC", "To Be Closed", "9ED77C"],
  ["CLS", "Closed", "FC737A"]
].each{ |t| TicketStatus.create_with(name: t[1], colour: t[2]).find_or_create_by(code: t[0])}

mst_spt_ticket_informed_method = [
  ["PH", "by phone"],
  ["CR", "carry in"],
  ["ML", "by mail"],
  ["FX", "fax"]
].each{ |t| InformMethod.create_with(name: t[1]).find_or_create_by(code: t[0])}

mst_spt_job_type = [
  ["SW", "Software"],
  ["HW", "Hardware"],
  ["NW", "Network"]
].each{ |t| JobType.create_with(name: t[1]).find_or_create_by(code: t[0]) }

mst_spt_contact_type = [
  ["ML", "Email"],
  ["SM", "SMS"],
  ["CL", "Call"],
  ["FX", "Fax"]
].each{ |t| TicketContactType.create_with(name: t[1]).find_or_create_by(code: t[0])}

mst_currency = [
  ["Sri Lankan Rupees", "LKR", "Rs", true],
  ["United States Dollars", "USD", "$US", false]
].each{ |t| TicketCurrency.create_with(currency: t[0], symbol: t[2], base_currency: t[3]).find_or_create_by(code: t[1])}
ContactNumber

mst_spt_customer_contact_type = [
  ["Telephone", false, false],
  ["Mobile", true, false],
  ["Fax", false, false],
  ["E-Mail", false, true],
  ["Skype", false, false]
].each{ |t| ContactType.create_with(name: t[0]).find_or_create_by(mobile: t[1], email: t[2])}

mst_title = [
  ["Mr."],
  ["Mrs."],
  ["Ms."],
  ["Miss."]
].each{ |t| MstTitle.find_or_create_by! title: t[0]}

mst_spt_action = [
  ["1", "Add ticket", "1", false],
  ["2", "Assign Ticket", "2", false],
  ["3", "Edit Ticket", "1", false],
  ["4", "Assign Regional Support Center", "2", false],
  ["5", "Start Action", "3", false],
  ["6", "Re-Assign Request", "3", false],
  ["7", "Terminate Job", "3", false],
  ["8", "Hold", "3,9,12", false],
  ["9", "Un Hold", "3,9,12", false],
  ["10", "Edit Serial No Request", "3", false],
  ["11", "Create FSR", "3", false],
  ["12", "Edit FSR (Un Approved )", "3", false],
  ["13", "Action Taken", "3", false],
  ["14", "Request Spare Part from Manufacture", "3", false],
  ["15", "Request Spare Part from Store", "3", false],
  ["16", "Receive Spare Part by eng", "3", false],
  ["17", "Return Part (Spare/Faulty)", "3", false],
  ["18", "Request On Loan  Spare Part", "3", false],
  ["19", "Terminate Spare Part", "3", false],
  ["20", "HP Case Action", "3", false],
  ["21", "Resolve the Job (Finish the Job)", "3", false],
  ["22", "Deliver Unit", "3", false],
  ["23", "Job Estimate Request", "3", false],
  ["24", "Estimation Customer Aproved", "3", false],
  ["25", "Recieve Unit", "3", false],
  ["26", "Customer Inqure", nil, false],
  ["27", "Job Estimation Done", "7", false],
  ["28", "Invoice Advance Payment", "27,29", false],
  ["29", "Delivere Unit To Supplier", "8", false],
  ["30", "Collect Unit From Supplier", "8", false],
  ["31", "Order Spare Part from Supplier", "9", false],
  ["32", "Request To Warranty Extend", "9", false],
  ["33", "Request To Estimate Parts", "9", false],
  ["34", "Terminate Spare Part Order", "9", false],
  ["35", "Edit Serial No", "9,12", false],
  ["36", "Collect Spare part from Manufacture", "23", false],
  ["37", "Receive Spare part from Manufacture", "10", false],
  ["38", "Issue Spare part", "10", false],
  ["39", "Warranty Extend", "12", false],
  ["40", "Reject Warranty Extend", "12", false],
  ["41", "Low Margin Job Estimate Approval", "19", false],
  ["42", "Reject Returned Part", "11", false],
  ["43", "Receive Returned part", "11,18", false],
  ["44", "Close Event", "11,30", false],
  ["45", "Part Bunndled", "21", false],
  ["46", "Part Bunndl Delivered", "22", false],
  ["47", "Approve Spare Part for Store", "16", false],
  ["48", "Issue store Spare Part", "17", false],
  ["49", "Approve On-Loan Part for Store", "16", false],
  ["50", "Issue store On-Loan Part", "17", false],
  ["51", "Receive On-Loan Part by eng", "3", false],
  ["52", "Return On-Loan part", "3", false],
  ["53", "Terminate On-Loan Part", "3", false],
  ["54", "Receive Returned On-Loan part", "18", false],
  ["55", "Request to Close Ticket", "3", false],
  ["56", "Approve Close Ticket", "13", false],
  ["57", "Quality Control Approved", "28", false],
  ["58", "Customer Feedback", "14", false],
  ["59", "Terminate FOC Job Approval", "31", false],
  ["60", "Terminate Job Issue and Invoice", "24", false],
  ["61", "Inform Customer", "14,24", false],
  ["62", "POP Approval", "5", false],
  ["63", "Estimate Job Final", "33", false],
  ["64", "Reject Spare Part for Store", "16", false],
  ["65", "Reject On-Loan Part for Store", "16", false],
  ["66", "Reject Close Ticket", "13", false],
  ["67", "Quality Control Rejected", "28", false],
  ["68", "Print Ticket", "1", false],
  ["69", "Print Complete Ticket", "14", false],
  ["70", "Print FSR", "3,13", false],
  ["71", "Print Invoice", "27,29", false],
  ["72", "Change Ticket Warranty Type or Customer Chargeable", "3", false],
  ["73", "Change Ticket Repair Type", "3", false],
  ["74", "Part Estimation Done", "15", false],
  ["75", "Low Margin Part Estimation Approval", "20", false],
  ["76", "Part Estimation Customer Aproved", "3", false],
  ["77", "Print Receipt for Payment", "14, 27, 29", false],
  ["78", "Request Non Stock Service Support Engineer", "3", false],
  ["79", "Complete Non Stock Service Support Engineer", "3", false],
].each{ |t| TaskAction.create_with(action_description: t[1], task_id: t[2], hide: t[3]).find_or_create_by(action_no: t[0]) }

mst_organizations_types = [
  ["HDO", "Head Office"],
  ["BRN", "Branch"],
  ["DPT", "Department"],
  ["STR", "Store"]
].each{ |t| OrganizationType.create_with(name: t[1]).find_or_create_by(code: t[0])}

Product
mst_spt_pop_status = [
  ["NAP", "Not Applicable"],
  ["RCD", "Received"],
  ["RPN", "Receive Pending"],
  ["APN", "Approval Pending"],
  ["LPN", "Pending From Local Provider"],
  ["APV", "Approved"],
  ["RJC", "Rejected"],
  ["UPD", "Updated"]
].each{ |t| ProductPopStatus.create_with(name: t[1]).find_or_create_by(code: t[0])}

QAndA
mst_spt_general_question = [
  ["Check outer condition?", "YN", true, 1, true],
  ["Any damage in the casing?", "TX", true, 1, false]
].each{ |t| GeQAndA.create_with(answer_type: t[1], active: t[2], action_id: t[3], compulsory: t[4]).find_or_create_by(question: t[0])}

TicketSparePart
spare_part_status_action = [
  ["RQT", "Requested", "0", "0", "1", "0", "1", "1", "1"],
  ["ORD", "Ordered from Manufacturer", "2", "0", "0", "0", "0", "0", "5"],
  ["CLT", "Collected from Manufacturer", "3", "0", "0", "0", "0", "0", "6"],
  ["RCS", "Received from Manufacturer", "4", "0", "0", "0", "0", "0", "7"],
  ["ISS", "Issued", "5", "4", "6", "3", "0", "0", "8"],
  ["RCE", "Received by Engineer", "6", "4", "7", "4", "0", "0", "9"],
  ["RTN", "Part Return by Engineer", "7", "5", "0", "5", "0", "0", "10"],
  ["RPR", "Returned Part Reject", "8", "6", "0", "6", "0", "0", "11"],
  ["RPA", "Returned Part Accepted", "8", "7", "0", "7", "0", "0", "11"],
  ["BND", "Part Bundled", "10", "0", "0", "0", "0", "0", "13"],
  ["CLS", "Close", "11", "8", "8", "8", "0", "0", "14"],
  ["ECM", "Estimation Completed", "0", "0", "2", "0", "0", "0", "2"],
  ["CEA", "Cus. Estimation Approved", "0", "0", "3", "0", "0", "0", "3"],
  ["STR", "Request from Store", "0", "1", "4", "1", "0", "0", "0"],
  ["APS", "Approved Store Request", "0", "2", "5", "2", "0", "0", "0"],
  ["RJS", "Reject Store Request", "0", "2", "5", "2", "0", "0", "12"],
  ["RBN", "Ready to Bundle", "9", "0", "0", "0", "0", "0", "0"],
  ["MPR", "Manufacture Part Requested", "1", "0", "0", "0", "0", "0", "4"],
].each{ |t| SparePartStatusAction.create_with(name: t[1], manufacture_type_index: t[2], store_nc_type_index: t[3], store_ch_type_index: t[4], on_loan_type_index: t[5], non_stock_nc_type_index: t[6], non_stock_ch_type_index: t[7], manufacture_ch_type_index: t[8]).find_or_create_by(code: t[0])}

workflow_mappings = [
  ["SPPT", "add_ticket", "/tickets/edit-ticket", "SPT_SC_1", "Support - Edit Ticket", "h1", "ticket_id,supp_hd_user",nil],
  ["SPPT", "assign_ticket", "/tickets/assign-ticket", "SPT_SC_2", "Support - Assign Ticket", "h1", "ticket_id", nil],
  ["SPPT", "resolution", "/tickets/resolution", "SPT_SC_3", "Support - Resolution", "h1", "ticket_id,supp_engr_user", nil],
  ["SPPT", "pop_approval", "/tickets/pop-approval", "SPT_SC_5", "Support - POP Approval", "h1", "ticket_id", nil],
  ["SPPT", "edit_serial_no", "/tickets/edit_serial", "SPT_SC_6", "Support - Edit Serial No", "h1", "ticket_id", nil],
  ["SPPT", "job_estimate", "/tickets/estimate_job", "SPT_SC_7", "Support - Job Estimation", "h1", "ticket_id", nil],
  ["SPPT", "mark_delivered_colleted", "/tickets/deliver_unit", "SPT_SC_8", "Support - Unit To Be Delivered or Colleced for External Repaire", "h1", "ticket_id,deliver_unit_id", nil],
  ["SPPT_MFR_PART_REQUEST", "order_part", "/tickets/order_manufacture_parts", "SPT_SC_9", "Support - Order Part (Manufacture)", "h3", "ticket_id,request_spare_part_id,supp_engr_user", nil],
  ["SPPT_MFR_PART_REQUEST", "receive_Issue_part", "/tickets/received_and_issued", "SPT_SC_10", "Support - Receive or Issue Part (Manufacture)", "h3", "ticket_id,request_spare_part_id,supp_engr_user", nil],
  ["SPPT_MFR_PART_RETURN", "return_manufacture_part", "/tickets/return_manufacture_part", "SPT_SC_11", "Support - Return Part (Manufacture)", "h3", "ticket_id,request_spare_part_id,supp_engr_user", nil],
  ["SPPT", "extend_warranty", "/tickets/extend_warranty", "SPT_SC_12", "Support - Extend Warranty", "h1", "ticket_id", nil],
  ["SPPT", "approve_close_ticket", "/tickets/check_fsr", "SPT_SC_13", "Support - Ticket Close Approval", "h1", "ticket_id,supp_engr_user", nil],
  ["SPPT", "customer_feedback", "/tickets/customer_feedback", "SPT_SC_14", "Support - Customer Feedback", "h1", "ticket_id,supp_engr_user", nil],
  ["SPPT_PART_ESTIMATE", "part_estimate", "/tickets/estimate_the_part_internal", "SPT_SC_15", "Support - Part Estimation (Store)", "h2", "ticket_id,part_estimation_id,supp_engr_user", nil],
  ["SPPT_STORE_PART_REQUEST", "approve_store_part", "/tickets/approve_store_parts", "SPT_SC_16", "Support - Part Approval (Store)", "h2", "ticket_id,request_spare_part_id,request_onloan_spare_part_id,onloan_request,supp_engr_user", nil],
  ["SPPT_STORE_PART_REQUEST", "issue_store_part", "/tickets/issue_store_part", "SPT_SC_17", "Support - Issue Part (Store)", "h2", "ticket_id,request_spare_part_id,request_onloan_spare_part_id,onloan_request,supp_engr_user", nil],
  ["SPPT_STORE_PART_RETURN", "return_store_part", "/tickets/return_store_part", "SPT_SC_18", "Support - Return Part (Store)", "h2", "ticket_id,request_spare_part_id,request_onloan_spare_part_id,onloan_request", nil],
  ["SPPT", "approve_job_estimate", "/tickets/low_margin_estimate", "SPT_SC_19", "Support - Job Estimation Approval", "h1", "ticket_id", nil],
  ["SPPT_PART_ESTIMATE", "approve_part_estimate", "", "SPT_SC_20", "Support - Part Estimation Approval (Store)", "h2", "ticket_id,part_estimation_id,supp_engr_user", nil],
  ["SPPT_MFR_PART_RETURN", "bundle_return_part", "/tickets/bundle_return_part", "SPT_SC_21", "Support - Returned Parts To Be Bundled", nil, "ticket_id,request_spare_part_id", nil],
  ["SPPT_MFR_PART_RETURN", "bundle_deliver", "/tickets/deliver_bundle", "SPT_SC_22", "Support - Return Parts Bundles To Be Delivered", nil, "bundle_id", nil],
  ["SPPT_MFR_PART_REQUEST", "collect_part", "/tickets/collect_parts", "SPT_SC_23", "Support - Manufacture parts to be collected", nil, "ticket_id,request_spare_part_id", nil],
  ["SPPT", "issue_customer_terminate", "", "SPT_SC_24", "Support - Terminated Job Return To Custormer", "h1", "ticket_id", nil],
  ["SPPT", "customer_advance_payment", "", "SPT_SC_27", "", nil, nil, nil],
  ["SPPT", "quality_control", "/tickets/quality_control", "SPT_SC_28", "Support - Quality Control", "h1", "ticket_id,supp_engr_user", nil],
  ["SPPT", "invoice_advance_payment", "/tickets/invoice_advance_payment", "SPT_SC_29", "Support - Advance Payment Invoice", "h1", "ticket_id,advance_payment_estimation_id", nil],
  ["SPPT_MFR_PART_RETURN", "close_event", "/tickets/close_event", "SPT_SC_30", "Support - Close Event", "h1", "ticket_id,request_spare_part_id", nil],
  ["SPPT", "approve_foc", "", "SPT_SC_31", "Support - FOC Approval", "h1", "ticket_id", nil],
  ["SPPT", "final_job_estimate", "/tickets/estimate_job_final", "SPT_SC_33", "Support - Final Job Estimation", "h1", "ticket_id", nil]
].each{ |t| WorkflowMapping.create_with(process_name: t[0], url: t[2], screen: t[3], first_header_title: t[4],second_header_title_name: t[5], input_variables: t[6], output_variables: t[7]).find_or_create_by(task_name: t[1])}

# 75  Low Margin Part Estimation Approval Suport Manager / Asst. mng  20  spt_act_job_estimate
# 76  Part Estimation Customer Aproved  Support Engineer  3 spt_act_job_estimate

WorkflowMapping.find(7).update(second_header_title_name: "h1")

Inventory
mst_inv_category_caption = [
  [1, "Brand", 2],
  [2, "Product", 2],
  [3, "Category", 2]
].each{ |t| InventoryCategoryCaption.create_with(caption: t[1], code_length: t[2]).find_or_create_by(level: t[0])}

{
  1 => {code_length: 2},
  2 => {code_length: 2},
  3 => {code_length: 2}
}.each do |k, v|
  InventoryCategoryCaption.find(k).update(v)
end

print_template = [
  1,
  nil,
  'PRINT_SPPT_INVOICE',
  '<!--\r\n 1. paper_size is A4, A5.... or CUSTOM\r\n 2. paper_width and paper_height - In mili meters\r\n 3. orientaion is portrait or landscape\r\n 4. color is in RGB integer value \r\n 5. h_align is left or right\r\n 6. v_align is top or bottom\r\n 7. Left, Top, Right, Bottom should be in mili meters\r\n  -->\r\n<template name=\"print ticket\" paper_size=\"A4\" paper_width=\"216\" paper_height=\"279\" orientaion=\"portrait\" top_margin=\"0\" left_margin=\"0\" bottom_margin=\"0\"  > \r\n  <fonts>\r\n   <font code=\"F1\" name=\"San Serif\" size=\"12\" color=\"554822\" Bold=\"true\" Italic=\"true\" Underline=\"true\" StrikeOut=\"true\"  />\r\n   <font code=\"F2\" name=\"San Serif\" size=\"12\" color=\"0\" Bold=\"true\" />\r\n   <font code=\"F3\" name=\"Arial\" size=\"10\" color=\"0\" />\r\n   <font code=\"F4\" name=\"San Serif\" size=\"10\" color=\"0\" Bold=\"true\" />\r\n  </fonts>\r\n <header>\r\n    <label name=\"DUPLICATE\" left=\"40\" top=\"20\" right=\"40\" bottom=\"20\" h_align=\"left\" v_align=\"top\" font_code=\"F4\" />\r\n    <label name=\"DATETIME\" left=\"36\" top=\"31\" right=\"36\" bottom=\"31\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"TICKET_REF\" left=\"177\" top=\"31\" right=\"177\" bottom=\"31\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"COMPANY_NAME\" left=\"40\" top=\"37\" right=\"40\" bottom=\"37\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"CONTACT_PERSON\" left=\"40\" top=\"43\" right=\"40\" bottom=\"43\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"ADDRESS\" left=\"40\" top=\"50\" right=\"40\" bottom=\"50\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"TELPHONE\" left=\"29\" top=\"55\" right=\"29\" bottom=\"55\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"MOBILE\" left=\"94\" top=\"55\" right=\"94\" bottom=\"55\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"FAX\" left=\"178\" top=\"55\" right=\"178\" bottom=\"55\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"EMAIL\" left=\"47\" top=\"61\" right=\"47\" bottom=\"61\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"PRODUCT_BRAND\" left=\"32\" top=\"67\" right=\"32\" bottom=\"67\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"PRODUCT_CATEGORY\" left=\"104\" top=\"67\" right=\"104\" bottom=\"67\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"MODEL_NO\" left=\"33\" top=\"79\" right=\"33\" bottom=\"79\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"SERIAL_NO\" left=\"100\" top=\"79\" right=\"100\" bottom=\"79\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"PRODUCT_NO\" left=\"173\" top=\"79\" right=\"173\" bottom=\"79\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"PROBLEM_DESC1\" left=\"53\" top=\"92\" right=\"53\" bottom=\"92\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"PROBLEM_DESC2\" left=\"53\" top=\"98\" right=\"53\" bottom=\"98\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"WARRANTY\" left=\"71\" top=\"105\" right=\"71\" bottom=\"105\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"CHARGEABLE\" left=\"123\" top=\"105\" right=\"123\" bottom=\"105\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"NEED_POP\" left=\"175\" top=\"105\" right=\"175\" bottom=\"105\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"EXTRA_REMARK1\" left=\"50\" top=\"118\" right=\"50\" bottom=\"118\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"EXTRA_REMARK2\" left=\"107\" top=\"118\" right=\"107\" bottom=\"118\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"EXTRA_REMARK3\" left=\"165\" top=\"118\" right=\"165\" bottom=\"118\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"EXTRA_REMARK4\" left=\"50\" top=\"125\" right=\"50\" bottom=\"125\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"EXTRA_REMARK5\" left=\"107\" top=\"125\" right=\"107\" bottom=\"125\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"EXTRA_REMARK6\" left=\"165\" top=\"125\" right=\"165\" bottom=\"125\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"REMARK\" left=\"50\" top=\"131\" right=\"50\" bottom=\"131\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"ACCESSORY1\" left=\"18\" top=\"168\" right=\"18\" bottom=\"168\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"ACCESSORY2\" left=\"57\" top=\"168\" right=\"57\" bottom=\"168\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"ACCESSORY3\" left=\"97\" top=\"168\" right=\"97\" bottom=\"168\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"ACCESSORY4\" left=\"138\" top=\"168\" right=\"138\" bottom=\"168\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"ACCESSORY5\" left=\"175\" top=\"168\" right=\"175\" bottom=\"168\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <!--label name=\"ACCESSORY6\" left=\"5\" top=\"75\" right=\"28\" bottom=\"70\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" /-->\r\n   <label name=\"ACCESSORY_OTHER\" left=\"18\" top=\"175\" right=\"18\" bottom=\"175\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />   \r\n  </header>\r\n</template>',
  'PRINT_SPPT_TICKET',
  nil,
  'PRINT_SPPT_TICKET_COMPLETE',
  '<!--\r\n 1. paper_size is A4, A5.... or CUSTOM\r\n 2. paper_width and paper_height - In mili meters\r\n 3. orientaion is portrait or landscape\r\n 4. color is in RGB integer value \r\n 5. h_align is left or right\r\n 6. v_align is top or bottom\r\n 7. Left, Top, Right, Bottom should be in mili meters\r\n  -->\r\n<template name=\"print fsr\" paper_size=\"A4\" paper_width=\"216\" paper_height=\"279\" orientaion=\"portrait\" top_margin=\"0\" left_margin=\"0\" bottom_margin=\"0\"  > \r\n  <fonts>\r\n   <font code=\"F1\" name=\"San Serif\" size=\"12\" color=\"554822\" Bold=\"true\" Italic=\"true\" Underline=\"true\" StrikeOut=\"true\"  />\r\n   <font code=\"F2\" name=\"San Serif\" size=\"12\" color=\"0\" Bold=\"true\" />\r\n   <font code=\"F3\" name=\"Arial\" size=\"10\" color=\"0\" />\r\n   <font code=\"F4\" name=\"San Serif\" size=\"10\" color=\"0\" Bold=\"true\" />\r\n  </fonts>\r\n <header>\r\n    <label name=\"DUPLICATE\" left=\"195\" top=\"32\" right=\"195\" bottom=\"32\" h_align=\"left\" v_align=\"top\" font_code=\"F4\" />\r\n    <label name=\"FSR_NO\" left=\"166\" top=\"37\" right=\"166\" bottom=\"37\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"COMPANY_NAME\" left=\"15\" top=\"45\" right=\"15\" bottom=\"45\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"ADDRESS\" left=\"115\" top=\"45\" right=\"115\" bottom=\"45\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"TICKET_REF\" left=\"15\" top=\"54\" right=\"15\" bottom=\"54\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"ENGINEER\" left=\"115\" top=\"54\" right=\"115\" bottom=\"54\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"SERIAL_NO\" left=\"15\" top=\"63\" right=\"15\" bottom=\"63\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"PRODUCT_DETAILS\" left=\"115\" top=\"63\" right=\"115\" bottom=\"63\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <!--label name=\"PRODUCT_BRAND\" left=\"115\" top=\"63\" right=\"115\" bottom=\"63\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"PRODUCT_CATEGORY\" left=\"178\" top=\"55\" right=\"178\" bottom=\"55\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"MODEL_NO\" left=\"47\" top=\"61\" right=\"47\" bottom=\"61\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n   <label name=\"PRODUCT_NO\" left=\"32\" top=\"67\" right=\"32\" bottom=\"67\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" /-->\r\n   <label name=\"PROBLEM_DESC1\" left=\"115\" top=\"79\" right=\"115\" bottom=\"79\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"PROBLEM_DESC2\" left=\"115\" top=\"85\" right=\"115\" bottom=\"85\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"TICKET_CREATED_DATE\" left=\"42\" top=\"84\" right=\"42\" bottom=\"84\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n    <label name=\"TICKET_CREATED_TIME\" left=\"85\" top=\"84\" right=\"85\" bottom=\"84\" h_align=\"left\" v_align=\"top\" font_code=\"F3\" />\r\n  </header>\r\n</template>',
  'PRINT_SPPT_FSR'
]

PrintTemplate.create_with(invoice: print_template[1], invoice_request_type: print_template[2], ticket: print_template[3], ticket_request_type: print_template[4], ticket_complete: print_template[5], ticket_complete_request_type: print_template[6], fsr: print_template[7], fsr_request_type: print_template[8]).find_or_create_by(id: print_template[0])

PrintTemplate.first.update(ticket: print_template[3], ticket_complete: print_template[5], fsr: print_template[7])

TicketEstimation
[
  ["RQS", "Requested"],
  ["EST", "Estimated"],
  ["CLS", "Closed"],
  ["APP", "Advance Payment Pending"]
].each do |t|
  EstimationStatus.create_with(name: t[1]).find_or_create_by(code: t[0])
end

WorkflowMapping.find(11).update(process_name: "SPPT_MFR_PART_REQUEST")