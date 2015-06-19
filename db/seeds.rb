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

organization = Organization.find_or_create_by name: "VS Information Systems", short_name: "VS Information Sys", code: "123456", web_site: "http://www.vsis.com", vat_number: "34358-90", refers: "VSIS", description: "VSIS is product owner of this application"
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

  Rpermission.create(rpermissions.map { |rp| {name: rp[0], controller_resource: rp[1], controller_action: rp[2]} })
  admin.rpermission_ids = [1,2,3,4,5,6,7]
  default_user.rpermission_ids = [2, 4, 5]

  Ticket
  Warranty

  ticket_status = [
    ["OPN", "Open"],
    ["ASN", "Assigned"],
    ["RSL", "Being Resolved"],
    ["QCT", "Quality Control"],
    ["PMT", "Final Payment Calculation"],
    ["CFB", "Customer Feedback and Issue"],
    ["ROP", "Re-Open"],
    ["TBC", "To Be Closed"],
    ["CLS", "Closed"]
  ]
  TicketStatus.create!(ticket_status.map{ |t| {code: t[0], name: t[1]} })

  warranty_types = [
    ["CW", "Corporate warranty"],
    ["MW", "Manufacture warranty"],
    ["NW", "Non warranty"]
  ]
  WarrantyType.create!(warranty_types.map{ |w| {code: w[0], name: w[1]} })

  mst_spt_ticket_type = [
    ["IH", "In house"],
    ["OS", "On-site"]
  ]
  TicketType.create!(mst_spt_ticket_type.map{ |t| {code: t[0], name: t[1]} })

   mst_spt_ticket_status = [
    ["OPN", "Open"],
    ["ASN", "Assigned"],
    ["RSL", "Being Resolved"],
    ["QCT", "Quality Control"],
    ["PMT", "Final Payment Calculation"],
    ["CFB", "Customer Feedback and Issue"],
    ["ROP", "Re-Open"],
    ["TBC", "To Be Closed"],
    ["CLS", "Closed"]
  ]
  TicketStatus.create!(mst_spt_ticket_status.map{ |t| {code: t[0], name: t[1]} })

  mst_spt_ticket_informed_method = [
    ["PH", "by phone"],
    ["CR", "carry in"],
    ["ML", "by mail"],
    ["FX", "fax"]
  ]
  InformMethod.create!(mst_spt_ticket_informed_method.map{ |t| {code: t[0], name: t[1]} })

  mst_spt_job_type = [
    ["SW", "Software"],
    ["HW", "Hardware"],
    ["NW", "Network"]
  ]
  JobType.create!(mst_spt_job_type.map{ |t| {code: t[0], name: t[1]} })

  mst_spt_contact_type = [
    ["ML", "Email"],
    ["SM", "SMS"],
    ["CL", "Call"],
    ["FX", "Fax"]
  ]
  TicketContactType.create!(mst_spt_contact_type.map{ |t| {code: t[0], name: t[1]} })

  mst_currency = [
    ["Sri Lankan Rupees", "LKR", "Rs", true],
    ["United States Dollars", "USD", "$US", false]
  ]
  TicketCurrency.create!(mst_currency.map{ |t| {currency: t[0], code: t[1], symbol: t[2], base_currency: t[3]} })
  ContactNumber
  mst_spt_customer_contact_type = [
    ["Telephone", "0", "0"],
    ["Mobile", "1", "0"],
    ["Fax", "0", "0"],
    ["E-Mail", "0", "1"],
    ["Skype", "0", "0"]
  ]
  ContactType.create!(mst_spt_customer_contact_type.map{ |t| {name: t[0], mobile: t[1], email: t[2]} })

  mst_title = [
    ["Mr."],
    ["Mrs."],
    ["Ms."],
    ["Miss."]
  ]
  MstTitle.create!(mst_title.map{ |t| {title: t[0]} })

  mst_spt_action = [
    ["1", "Add ticket", "1", 0],
    ["2", "Assign Ticket", "2", 0],
    ["3", "Edit Ticket", "1", 0],
    ["4", "Assign Regional Support Center", "2", 0],
    ["5", "Start Action", "3", 0],
    ["6", "Re-Assign Request", "3", 0],
    ["7", "Terminate Job", "3", 0],
    ["8", "Hold", "3,9,12", 0],
    ["9", "Un Hold", "3,9,12", 0],
    ["10", "Edit Serial No Request", "3", 0],
    ["11", "Create FSR", "3", 0],
    ["12", "Edit FSR (Un Approved )", "3", 0],
    ["13", "Action Taken", "3", 0],
    ["14", "Request Spare Part from Manufacture", "3", 0],
    ["15", "Request Spare Part from Store", "3", 0],
    ["16", "Receive Spare Part by eng", "3", 0],
    ["17", "Return Part (Spare/Faulty)", "3", 0],
    ["18", "Request On Loan  Spare Part", "3", 0],
    ["19", "Terminate Spare Part", "3", 0],
    ["20", "HP Case Action", "3", 0],
    ["21", "Resolve the Job (Finish the Job)", "3", 0],
    ["22", "Deliver Unit", "3", 0],
    ["23", "Job Estimate Request", "3", 0],
    ["24", "Estimation Customer Aproved", "3", 0],
    ["25", "Recieve Unit", "3", 0],
    ["26", "Customer Inqure", nil, 0],
    ["27", "Job Estimation Done", "7", 0],
    ["28", "Invoice Advance Payment", "27,29", 0],
    ["29", "Delivere Unit To Supplier", "8", 0],
    ["30", "Collect Unit From Supplier", "8", 0],
    ["31", "Order Spare Part from Supplier", "9", 0],
    ["32", "Request To Warranty Extend", "9", 0],
    ["33", "Request To Estimate Parts", "9", 0],
    ["34", "Terminate Spare Part Order", "9", 0],
    ["35", "Edit Serial No", "9,12", 0],
    ["36", "Collect Spare part from Manufacture", "23", 0],
    ["37", "Receive Spare part from Manufacture", "10", 0],
    ["38", "Issue Spare part", "10", 0],
    ["39", "Warranty Extend", "12", 0],
    ["40", "Reject Warranty Extend", "12", 0],
    ["41", "Low Margin Job Estimate Approval", "19", 0],
    ["42", "Reject Returned Part", "11", 0],
    ["43", "Receive Returned part", "11,18", 0],
    ["44", "Close Event", "11,30", 0],
    ["45", "Part Bunndled", "21", 0],
    ["46", "Part Bunndl Delivered", "22", 0],
    ["47", "Approve Spare Part for Store", "16", 0],
    ["48", "Issue store Spare Part", "17", 0],
    ["49", "Approve On-Loan Part for Store", "16", 0],
    ["50", "Issue store On-Loan Part", "17", 0],
    ["51", "Receive On-Loan Part by eng", "3", 0],
    ["52", "Return On-Loan part", "3", 0],
    ["53", "Terminate On-Loan Part", "3", 0],
    ["54", "Receive Returned On-Loan part", "18", 0],
    ["55", "Request to Close Ticket", "3", 0],
    ["56", "Approve Close Ticket", "13", 0],
    ["57", "Quality Control Approved", "28", 0],
    ["58", "Customer Feedback", "14", 0],
    ["59", "Terminate FOC Job Approval", "31", 0],
    ["60", "Terminate Job Issue and Invoice", "24", 0],
    ["61", "Inform Customer", "14,24", 0],
    ["62", "POP Approval", "5", 0],
    ["63", "Estimate Job Final", "33", 0],
    ["64", "Reject Spare Part for Store", "16", 0],
    ["65", "Reject On-Loan Part for Store", "16", 0],
    ["66", "Reject Close Ticket", "13", 0],
    ["67", "Quality Control Rejected", "28", 0],
    ["68", "Print Ticket", "1", 0],
    ["69", "Print Complete Ticket", "14", 0],
    ["70", "Print FSR", "3,13", 0],
    ["71", "Print Invoice", "27,29", 0]
  ]
  TaskAction.create!(mst_spt_action.map{ |t| {action_no: t[0], action_description: t[1], task_id: t[2], hide: t[3]} })

  mst_organizations_types = [
    ["HDO", "Head Office"],
    ["BRN", "Branch"],
    ["DPT", "Department"],
    ["STR", "Store"]
  ]
  OrganizationType.create!(mst_organizations_types.map{ |t| {code: t[0], name: t[1]} })
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
  ]
  ProductPopStatus.create!(mst_spt_pop_status.map{ |t| {code: t[0], name: t[1]} })
  QAndA
  mst_spt_general_question = [
    ["Check outer condition?", "YN", 1, 1, 1],
    ["Any damage in the casing?", "TX", 1, 1, 0]
  ]
  GeQAndA.create!(mst_spt_general_question.map{ |t| {question: t[0], answer_type: t[1], active: t[2], action_id: t[3], compulsory: t[4]} })

end