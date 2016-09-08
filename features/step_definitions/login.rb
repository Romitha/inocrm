Given /^I am Unauthorized user$/ do
  visit('/users/sign_out') # ensure that at least
  # expect(page).to have_current_path('/users/sign_out')
end

When /^I go to sign in page$/ do
  visit "/users/sign_in"
  expect(page).to have_current_path('/users/sign_in')
end

And /^I find login form$/ do
  within("#new_user") {}
end

When /^I enter (.*) (.*) like (.*)$/ do |resource, field, value|
  puts "#{resource} #{field}"
  fill_in "#{resource}[#{field}]", :with => value
end
# https://makandracards.com/makandra/14017-useful-methods-to-process-tables-in-cucumber-step-definitions for more info regarding tables.
# When /^I enter (.*) (.*) like (.*):$/ do |table|
#   table.hashes.each do |hash|
#     within("#new_user") do
#       fill_in 'user[email]', :with => hash["email"]
#       fill_in 'user[password]', :with => hash["password"]
#     end
#     step "press Log in button"
#     step "I able to login to InoCrm system as #{hash['email']}."
#   end
# end

# Then /^I able to login to InoCrm system as (.*).$/ do |user|
#   if page.has_content? "Signed in successfully."
#     puts "User #{user} is successfully signed in"
#     step "I am Unauthorized user"
#   else
#     expect(page).to have_content "Invalid email address or password."
#   end
#   # expect(page).to have_content "Signed in successfully."
# end