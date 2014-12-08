# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
rpermissions = [{name: "Update user profile", controller_resource: "User", controller_action: "update"},
{name: "View list of organizations", controller_resource: "Organization", controller_action: "index"},
{name: "Create new organization", controller_resource: "Organization", controller_action: "update"},
{name: "View own user profile", controller_resource: "User", controller_action: "profile"},
{name: "View own Organization", controller_resource: "Organization", controller_action: "show"},
{name: "Edit organization details", controller_resource: "Organization", controller_action: "edit"},
{name: "Create new user for Organization", controller_resource: "User", controller_action: "create"}]

user = User.find_by_email("admin@inovacrm.com")
unless(user)
	user = User.create(email: "admin@inovacrm.com", password: "123456789")
	user.add_role :admin
	user.add_role :default_user
	user.roles.find_by_name("admin").update_attribute(:parent_role, true)
	user.roles.find_by_name("default_user").update_attribute(:parent_role, true)
	Rpermission.create(rpermissions)
	user.roles.find_by_name("admin").rpermission_ids = [1,2,3,4,5,6,7]
	user.roles.find_by_name("default_user").rpermission_ids = [2, 4, 5]
end
Organization.find_or_create_by name: "VS Information Systems", short_name: "VS Information Sys", code: "123456", web_site: "http://www.vsis.com", vat_number: "34358-90", refers: "VSIS"