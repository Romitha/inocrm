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
    ["73", "Change Ticket Repair Type", "3", false]
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
  ].each{ |t| SparePartStatusAction.create_with(name: t[1], manufacture_type_index: t[2], store_nc_type_index: t[3], store_ch_type_index: t[4], on_loan_type_index: t[5]).find_or_create_by(code: t[0])}

  {
    1 => {store_nc_type_index: 0, on_loan_type_index: 0},
    5 => {store_nc_type_index: 3, on_loan_type_index: 3},
    6 => {store_nc_type_index: 4, on_loan_type_index: 4},
    7 => {store_nc_type_index: 5, on_loan_type_index: 5},
    8 => {store_nc_type_index: 6, on_loan_type_index: 6},
    9 => {store_nc_type_index: 6, on_loan_type_index: 6},
    11 => {store_nc_type_index: 8, on_loan_type_index: 8},
    14 => {store_nc_type_index: 2, on_loan_type_index: 2},
    15 => {store_nc_type_index: 2, on_loan_type_index: 2},
    16 => {store_nc_type_index: 2, on_loan_type_index: 2}
  }.each do |k, v|
    SparePartStatusAction.find(k).update(v)
  end

  WorkflowMapping
  workflow_mappings = [
    ["SPPT", "add_ticket", "/tickets/edit-ticket", "SPT_SC_1", "Support - Edit Ticket", "h1", "ticket_id,supp_hd_user",nil],
    ["SPPT", "assign_ticket", "/tickets/assign-ticket", "SPT_SC_2", "Support - Assign Ticket", "h1", "ticket_id", nil],
    ["SPPT", "resolution", "/tickets/resolution", "SPT_SC_3", "Support - Resolution", "h1", "ticket_id,supp_engr_user", nil],
    ["SPPT", "pop_approval", "/tickets/pop-approval", "SPT_SC_5", "Support - POP Approval", "h1", "ticket_id", nil],
    ["SPPT", "edit_serial_no", "", "SPT_SC_6", "Support - Edit Serial No", "h1", "ticket_id", nil],
    ["SPPT", "job_estimate", "", "SPT_SC_7", "Support - Job Estimation", "h1", "ticket_id", nil],
    ["SPPT", "mark_delivered_colleted", "", "SPT_SC_8", "Support - Units To Be Delivered or Colleced for External Repaire", "h1", "ticket_id,deliver_unit_id", nil],
    ["SPPT_MFR_PART_REQUEST", "order_part", "", "SPT_SC_9", "Support - Order Part (Manufacture)", "h3", "ticket_id,request_spare_part_id,supp_engr_user", nil],
    ["SPPT_MFR_PART_REQUEST", "receive_Issue_part", "", "SPT_SC_10", "Support - Receive or Issue Part (Manufacture)", "h3", "ticket_id,request_spare_part_id,supp_engr_user", nil],
    ["SPPT_MFR_PART_RETURN", "return_manufacture_part", "", "SPT_SC_11", "Support - Return Part (Manufacture)", "h3", "ticket_id,request_spare_part_id,supp_engr_user", nil],
    ["SPPT", "extend_warranty", "", "SPT_SC_12", "Support - Extend Warranty", "h1", "ticket_id", nil],
    ["SPPT", "approve_close_ticket", "", "SPT_SC_13", "Support - Ticket Close Approval", "h1", "ticket_id,supp_engr_user", nil],
    ["SPPT", "customer_feedback", "", "SPT_SC_14", "Support - Customer Feedback", "h1", "ticket_id,supp_engr_user", nil],
    ["SPPT_PART_ESTIMATE", "part_estimate", "", "SPT_SC_15", "Support - Part Estimation (Store)", "h2", "ticket_id,part_estimation_id,supp_engr_user", nil],
    ["SPPT_STORE_PART_REQUEST", "approve_store_part", "", "SPT_SC_16", "Support - Part Approval (Store)", "h2", "ticket_id,request_spare_part_id,request_onloan_spare_part_id,onloan_request,supp_engr_user", nil],
    ["SPPT_STORE_PART_REQUEST", "issue_store_part", "", "SPT_SC_17", "Support - Issue Part (Store)", "h2", "ticket_id,request_spare_part_id,request_onloan_spare_part_id,onloan_request,supp_engr_user", nil],
    ["SPPT_STORE_PART_RETURN", "return_store_part", "", "SPT_SC_18", "Support - Return Part (Store)", "h2", "ticket_id,request_spare_part_id,request_onloan_spare_part_id,onloan_request", nil],
    ["SPPT", "approve_job_estimate", "", "SPT_SC_19", "Support - Job Estimation Approval", "h1", "ticket_id", nil],
    ["SPPT_PART_ESTIMATE", "approve_part_estimate", "", "SPT_SC_20", "Support - Part Estimation Approval (Store)", "h2", "ticket_id,part_estimation_id,supp_engr_user", nil],
    ["SPPT_MFR_PART_RETURN", "bundle_return_part", "", "SPT_SC_21", "Support - Return Parts To Be Bundled", nil, "ticket_id,request_spare_part_id", nil],
    ["SPPT_MFR_PART_RETURN", "bundle_deliver", "", "SPT_SC_22", "Support - Return Parts Bundles To Be Delivered", nil, "bundle_id", nil],
    ["SPPT_MFR_PART_REQUEST", "collect_part", "", "SPT_SC_23", "Support - Manufacture parts to be collected", nil, "ticket_id,request_spare_part_id", nil],
    ["SPPT", "issue_customer_terminate", "", "SPT_SC_24", "Support - Terminated Job Return To Custormer", "h1", "ticket_id", nil],
    ["SPPT", "customer_advance_payment", "", "SPT_SC_27", "", nil, nil, nil],
    ["SPPT", "quality_control", "", "SPT_SC_28", "Support - Quality Control", "h1", "ticket_id,supp_engr_user", nil],
    ["SPPT", "invoice_advance_payment", "", "SPT_SC_29", "Support - Advance Payment Invoice", "h1", "ticket_id,advance_payment_estimation_id", nil],
    ["SPPT_MFR_PART_RETURN", "close_event", "", "SPT_SC_30", "Support - Close Event", "h1", "ticket_id,request_spare_part_id", nil],
    ["SPPT", "approve_foc", "", "SPT_SC_31", "Support - FOC Approval", "h1", "ticket_id", nil],
    ["SPPT", "final_job_estimate", "", "SPT_SC_33", "Support - Final Job Estimation", "h1", "ticket_id", nil]
  ].each{ |t| WorkflowMapping.create_with(process_name: t[0], url: t[2], screen: t[3], first_header_title: t[4],second_header_title_name: t[5], input_variables: t[6], output_variables: t[7]).find_or_create_by(task_name: t[1])}

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