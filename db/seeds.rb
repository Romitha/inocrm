# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create email: "admin@inovacrm.com", password: "123456789" unless User.find_by_email("admin@inovacrm.com")
Organization.find_or_create_by name: "VS Information Systems", website: "http://www.vsis.com", vat_number: "34358-90", refers: "VSIS"