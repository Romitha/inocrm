rpermissions = [
  ["Update user profile", 1, 1],
  ["View list of organizations", 2, 2],
  ["Create new organization", 2, 3],
  ["View own user profile", 1, 4],
  ["View own Organization", 2, 5],
  ["Edit organization details", 2, 6],
  ["Create new user for Organization", 1, 7]
]

subject_classes = [
  ['Ticket', 1, ],
  ['Inventory', 1, ],
  ['ContactNumber', 1, ],
  ['Designation', 1, ],
  ['DocumentAttachment', 1, ],
  ['Invoice', 1, ],
  ['Organization', 1, ],
  ['QAndA', 1, ],
  ['RolesAndPermission', 1, ],
  ['User', 1, ],
  ['Todo', 1, ],
  ['Warranty', 1, ],

]

organization = Organization.find_or_create_by name: "VS Information Systems", short_name: "VS Information Sys", code: "123456", web_site: "http://www.vsis.com", vat_number: "34358-90", refers: "VSIS", description: "VSIS is product owner of this application", type_id: 1
user = User.find_by_email("admin@inovacrm.com")
unless(user)
  user = User.create(email: "admin@inovacrm.com", password: "123456789", organization_id: organization.id)
  # user.add_role :admin, organization
  # user.add_role :default_user, organization

  user.roles.push Role.create(name: "admin"), Role.create(name: "default_user")

  admin = user.roles.find_by_name("admin")
  default_user = user.roles.find_by_name("default_user")
  admin.update_attribute(:parent_role, true)
  default_user.update_attribute(:parent_role, true)
  user.update_attribute :current_user_role_id, admin.id
  user.update_attribute :current_user_role_name, admin.name

  # Rpermission.find_or_create_by!(rpermissions.map { |rp| {name: rp[0], controller_resource: rp[1], controller_action: rp[2]} })
  Rpermission
  SubjectBase.create [{name: "Model"}, {name: "Controller"}]
  # SubjectAttribute.create [{name: "id"}, {name: "task_id"}]
  # SubjectAction.create [{name: "update_user"}, {name: "index"}, {name: "create_organization"}, {name: "profile"}, {name: "show"}, {name: "update_organization"}, {name: "create_user"}]

  subject_classes.each { |rp| SubjectClass.create_with( name: rp[0], subject_base_id: rp[1] ).find_or_create_by(name: rp[0]) }
  rpermissions.each { |rp| Rpermission.create_with( subject_action_id: rp[2], subject_class_id: rp[1] ).find_or_create_by(name: rp[0]) }
  admin.rpermission_ids = [1,2,3,4,5,6,7]
  default_user.rpermission_ids = [2, 4, 5]

  Organization.stores.create name: "store1", description: "This is sample store", web_site: "http://www.store1.com", short_name: "this is sample name", parent_organization_id: organization.id

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

contact_type_validate = [
  ['NA', "Not Applicable"],
  ["PN", "Phone Number"],
  ["EM", "Email"],
].each{ |t| ContactTypeValidate.create_with(name: t[1]).find_or_create_by(code: t[0])}

mst_spt_customer_contact_type = [
  ["Telephone", false, false, 2],
  ["Mobile", true, false, 3],
  ["Fax", false, false, 2],
  ["E-Mail", false, true, 1],
  ["Skype", false, false, 2]
].each{ |t| ContactType.create_with(name: t[0]).find_or_create_by(mobile: t[1], email: t[2], validate_id: t[3])}

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
  ["28", "Received Advance Payment", "27,29", false],
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
  ["78", "Request Non Stock Service", "3", false],
  ["79", "Complete Non Stock Service", "3", false],
  ["80", "Create Invoice", "33", false],
  ["81", "Create Quotation", "3", false],
  ["82", "Print Quotation", "3", false],
  ["83", "Edit Invoice", "33", false],
  ["84", "Edit Quotation", "3", false],
  ["85", "Estimate Job Final Update", "3", false],
  ["86", "Create PO for Part", "", false],
  ["87", "Close the ticket", "", false],
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
  ["RQT", "Requested", 0,1,0,1,0,1,1],
  ["ORD", "Ordered from Manufacturer", 3,6,0,0,0,0,0, 'To Be Ordered From Manufacturer'],
  ["CLT", "Collected from Manufacturer", 4,7,0,0,0,0,0, 'To Be Collected From Manufacturer'],
  ["RCS", "Received from Manufacturer", 5,8,0,0,0,0,0, 'To Be Received From Manufacturer'],
  ["ISS", "Issued", 6,9,3,6,3,0,0, 'To Be Issued'],
  ["RCE", "Received by Engineer", 7,10,4,7,4,0,0, 'To Be Recieved By Engineer'],
  ["RTN", "Part Returned by Engineer", 8, 11, 5, 0, 5, 0, 0, 'Part To Be Returned By Engineer'],
  ["RPR", "Returned Part Reject", 9,12,6,0,6,0,0, 'Accept or Reject The Returned Part'],
  ["RPA", "Returned Part Accepted", 9,12,6,0,6,0,0, 'Accept or Reject The Returned Part'],
  ["BND", "Part Bundled", 11,14,0,0,0,0,0, 'Bundle The Part'],
  ["CLS", "Close", 12,15,7,8,7,2,4],
  ["ECM", "Estimation Completed", 0,2,0,2,0,0,2, 'Complete The Estimation'],
  ["CEA", "Cus. Estimation Approved", 0,3,0,3,0,0,3, 'Approve The Estimation By Customer'],
  ["STR", "Request from Store", 0,0,1,4,1,0,0, 'Request From Store'],
  ["APS", "Approved Store Request", 0,0,2,5,2,0,0, 'Approve or Reject The Store Request'],
  ["RJS", "Reject Store Request", 0,0,2,5,2,0,0, 'Approve or Reject The Store Request'],
  ["RBN", "Ready to Bundle", 10,13,0,0,0,0,0, 'Ready To Bundle'],
  ["MPR", "Manufacture Part Requested", 1,4,0,0,0,0,0, 'To Be Requested From Manufacturer'],
  ["APM", "Manufacturer Parts Request Approved", 2,5,0,0,0,0,0, 'Manufacturer Parts Request Approved'],
  ["RJM", "Manufacturer Parts Request Rejected", 2,5,0,0,0,0,0, 'Manufacturer Parts Request Rejected'],
].each{ |t| SparePartStatusAction.create_with(name: t[1], manufacture_type_index: t[2], manufacture_ch_type_index: t[3], store_nc_type_index: t[4], store_ch_type_index: t[5], on_loan_type_index: t[6], non_stock_nc_type_index: t[7], non_stock_ch_type_index: t[8], name_next: t[9]).find_or_create_by(code: t[0])}
# UPDATE `mst_spt_spare_part_status_action` SET
# manufacture_type_index = (
#  CASE code WHEN "RQT" THEN 0 
#           WHEN "ORD" THEN  2 
#           WHEN "CLT" THEN  3 
#           WHEN "RCS" THEN  4 
#           WHEN "ISS" THEN  5 
#           WHEN "RCE" THEN  6 
#           WHEN "RTN" THEN  7 
#           WHEN "RPR" THEN  8 
#           WHEN "RPA" THEN  8 
#           WHEN "BND" THEN  10
#           WHEN "CLS" THEN  11
#           WHEN "ECM" THEN  0 
#           WHEN "CEA" THEN  0 
#           WHEN "STR" THEN  0 
#           WHEN "APS" THEN  0 
#           WHEN "RJS" THEN  0 
#           WHEN "RBN" THEN  9 
#           WHEN "MPR" THEN  1 
#  END),
#  manufacture_ch_type_index = (
#  CASE code WHEN "RQT" THEN  1 
#             WHEN "ORD" THEN 5 
#             WHEN "CLT" THEN 6 
#             WHEN "RCS" THEN 7 
#             WHEN "ISS" THEN 8 
#             WHEN "RCE" THEN 9 
#             WHEN "RTN" THEN 10
#             WHEN "RPR" THEN 11
#             WHEN "RPA" THEN 11
#             WHEN "BND" THEN 13
#             WHEN "CLS" THEN 14
#             WHEN "ECM" THEN 2 
#             WHEN "CEA" THEN 3 
#             WHEN "STR" THEN 0 
#             WHEN "APS" THEN 0 
#             WHEN "RJS" THEN 0 
#             WHEN "RBN" THEN 12
#             WHEN "MPR" THEN 4 
#  END),
#  store_nc_type_index = (
#  CASE code WHEN "RQT" THEN 0
#           WHEN "ORD" THEN  0
#           WHEN "CLT" THEN  0
#           WHEN "RCS" THEN  0
#           WHEN "ISS" THEN  3
#           WHEN "RCE" THEN  4
#           WHEN "RTN" THEN  5
#           WHEN "RPR" THEN  6
#           WHEN "RPA" THEN  6
#           WHEN "BND" THEN  0
#           WHEN "CLS" THEN  7
#           WHEN "ECM" THEN  0
#           WHEN "CEA" THEN  0
#           WHEN "STR" THEN  1
#           WHEN "APS" THEN  2
#           WHEN "RJS" THEN  2
#           WHEN "RBN" THEN  0
#           WHEN "MPR" THEN  0
#  END),
#  store_ch_type_index = (
#  CASE code WHEN "RQT" THEN 1
#           WHEN "ORD" THEN  0
#           WHEN "CLT" THEN  0
#           WHEN "RCS" THEN  0
#           WHEN "ISS" THEN  6
#           WHEN "RCE" THEN  7
#           WHEN "RTN" THEN  0
#           WHEN "RPR" THEN  0
#           WHEN "RPA" THEN  0
#           WHEN "BND" THEN  0
#           WHEN "CLS" THEN  8
#           WHEN "ECM" THEN  2
#           WHEN "CEA" THEN  3
#           WHEN "STR" THEN  4
#           WHEN "APS" THEN  5
#           WHEN "RJS" THEN  5
#           WHEN "RBN" THEN  0
#           WHEN "MPR" THEN  0
#  END),
#  on_loan_type_index = (
#  CASE code WHEN "RQT" THEN 1
#             WHEN "ORD" THEN 0
#             WHEN "CLT" THEN 0
#             WHEN "RCS" THEN 0
#             WHEN "ISS" THEN 4
#             WHEN "RCE" THEN 5
#             WHEN "RTN" THEN 6
#             WHEN "RPR" THEN 7
#             WHEN "RPA" THEN 7
#             WHEN "BND" THEN 0
#             WHEN "CLS" THEN 8
#             WHEN "ECM" THEN 0
#             WHEN "CEA" THEN 0
#             WHEN "STR" THEN 2
#             WHEN "APS" THEN 3
#             WHEN "RJS" THEN 3
#             WHEN "RBN" THEN 0
#             WHEN "MPR" THEN 0
#  END),
#  non_stock_nc_type_index = (
#  CASE code WHEN "RQT" THEN 0
#           WHEN "ORD" THEN  0
#           WHEN "CLT" THEN  0
#           WHEN "RCS" THEN  0
#           WHEN "ISS" THEN  3
#           WHEN "RCE" THEN  4
#           WHEN "RTN" THEN  5
#           WHEN "RPR" THEN  6
#           WHEN "RPA" THEN  6
#           WHEN "BND" THEN  0
#           WHEN "CLS" THEN  7
#           WHEN "ECM" THEN  0
#           WHEN "CEA" THEN  0
#           WHEN "STR" THEN  1
#           WHEN "APS" THEN  2
#           WHEN "RJS" THEN  2
#           WHEN "RBN" THEN  0
#           WHEN "MPR" THEN  0
#  END),
#  non_stock_ch_type_index = (
#  CASE code WHEN "RQT" THEN 1
#           WHEN "ORD" THEN  0
#           WHEN "CLT" THEN  0
#           WHEN "RCS" THEN  0
#           WHEN "ISS" THEN  0
#           WHEN "RCE" THEN  0
#           WHEN "RTN" THEN  0
#           WHEN "RPR" THEN  0
#           WHEN "RPA" THEN  0
#           WHEN "BND" THEN  0
#           WHEN "CLS" THEN  4
#           WHEN "ECM" THEN  2
#           WHEN "CEA" THEN  3
#           WHEN "STR" THEN  0
#           WHEN "APS" THEN  0
#           WHEN "RJS" THEN  0
#           WHEN "RBN" THEN  0
#           WHEN "MPR" THEN  0
#  END);

workflow_mappings = [
  ["SPPT", "add_ticket", "/tickets/edit-ticket", "SPT_SC_1", "Support - Edit Ticket", "h1", "ticket_id,supp_hd_user",nil],
  ["SPPT", "assign_ticket", "/tickets/assign-ticket", "SPT_SC_2", "Support - Assign Ticket", "h1", "ticket_id", nil],
  ["SPPT", "resolution", "/tickets/resolution", "SPT_SC_3", "Support - Resolution", "h1", "ticket_id,supp_engr_user,engineer_id", nil],
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
  ["SPPT_PART_ESTIMATE", "part_estimate", "/tickets/estimate_the_part_internal", "SPT_SC_15", "Support - Part Estimation", "h2", "ticket_id,part_estimation_id,supp_engr_user", nil],
  ["SPPT_STORE_PART_REQUEST", "approve_store_part", "/tickets/approve_store_parts", "SPT_SC_16", "Support - Part Approval (Store)", "h2", "ticket_id,request_spare_part_id,request_onloan_spare_part_id,onloan_request,supp_engr_user", nil],
  ["SPPT_STORE_PART_REQUEST", "issue_store_part", "/tickets/issue_store_part", "SPT_SC_17", "Support - Issue Part (Store)", "h2", "ticket_id,request_spare_part_id,request_onloan_spare_part_id,onloan_request,supp_engr_user", nil],
  ["SPPT_STORE_PART_RETURN", "return_store_part", "/tickets/return_store_part", "SPT_SC_18", "Support - Return Part (Store)", "h2", "ticket_id,request_spare_part_id,request_onloan_spare_part_id,onloan_request", nil],
  ["SPPT", "approve_job_estimate", "/tickets/job_below_margin_estimate_approval", "SPT_SC_19", "Support - Job Estimation Approval", "h1", "ticket_id", nil],
  ["SPPT_PART_ESTIMATE", "approve_part_estimate", "/tickets/low_margin_estimate_parts_approval", "SPT_SC_20", "Support - Part Estimation Approval (Store)", "h2", "ticket_id,part_estimation_id,supp_engr_user", nil],
  ["SPPT_MFR_PART_RETURN", "bundle_return_part", "/tickets/bundle_return_part", "SPT_SC_21", "Support - Returned Parts To Be Bundled", nil, "ticket_id,request_spare_part_id", nil],
  ["SPPT_MFR_PART_RETURN", "bundle_deliver", "/tickets/deliver_bundle", "SPT_SC_22", "Support - Return Parts Bundles To Be Delivered", nil, "bundle_id", nil],
  ["SPPT_MFR_PART_REQUEST", "collect_part", "/tickets/collect_parts", "SPT_SC_23", "Support - Manufacture parts to be collected", nil, "ticket_id,request_spare_part_id", nil],
  ["SPPT", "issue_customer_terminate", "/tickets/customer_feedback", "SPT_SC_24", "Support - Terminated Job Return To Custormer", "h1", "ticket_id", nil],
  ["SPPT", "customer_advance_payment", "/tickets/customer_advance_payment", "SPT_SC_27", "", nil, nil, nil],
  ["SPPT", "quality_control", "/tickets/quality_control", "SPT_SC_28", "Support - Quality Control", "h1", "ticket_id,supp_engr_user", nil],
  ["SPPT", "invoice_advance_payment", "/tickets/invoice_advance_payment", "SPT_SC_29", "Support - Advance Payment Invoice", "h1", "ticket_id,advance_payment_estimation_id", nil],
  ["SPPT_MFR_PART_RETURN", "close_event", "/tickets/close_event", "SPT_SC_30", "Support - Close Event", "h1", "ticket_id,request_spare_part_id", nil],
  ["SPPT", "approve_foc", "/tickets/terminate_job_foc_approval", "SPT_SC_31", "Support - FOC Approval", "h1", "ticket_id", nil],
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

[
  ["SUP", "Supplier"],
  ["INDSUP", "Individual Supplier"],
  ["CUS", "Customer"],
  ["INDCUS", "Individual Customer"]
].each do |t|
  DealerType.create_with(name: t[1]).find_or_create_by(code: t[0])
end

[
  ["Computer Softwear"],
  ["Computer Hardwear"],
].each do |t|
  IndustryType.create_with(name: t[0]).find_or_create_by(name: t[0])
end

CompanyConfig.create sup_last_fsr_no: 0, inv_last_srn_no: 0, inv_last_srr_no: 0, inv_last_sbn_no: 0, inv_last_prn_no: 0, inv_last_grn_no: 0, inv_last_gin_no: 0, sup_last_quotation_no: 0, sup_last_bundle_no: 0 unless CompanyConfig.any? #, sup_sla_id: 0 is foreign key constraint

[
  ["PSG", "Onsite PSG"],
  ["ESG", "Onsite ESG"],
  ["NTW", "Onsite NTW"],
  ["OTR", "Onsite OTR"]
].each do |t|
  OnsiteType.create_with(name: t[1]).find_or_create_by(code: t[0])
end