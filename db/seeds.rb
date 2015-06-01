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

end