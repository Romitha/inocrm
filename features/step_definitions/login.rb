Given /^I am Unauthorized user$/ do
  visit('/users/sign_out') # ensure that at least
end

# When /^I am entering my credential details with email as (.*) and password as (.*)$/ do |email, password|
#   visit('/users/sign_in')
#   within("#new_user") do
#     fill_in 'user[email]', :with => email
#     fill_in 'user[password]', :with => password
#   end
# end
# https://makandracards.com/makandra/14017-useful-methods-to-process-tables-in-cucumber-step-definitions for more info regarding tables.
When /^I am entering my credential details:$/ do |table|
  visit('/users/sign_in')
  table.hashes.each do |hash|
    within("#new_user") do
      fill_in 'user[email]', :with => hash["email"]
      fill_in 'user[password]', :with => hash["password"]
    end
    step "press Log in button"
    step "I able to login to InoCrm system as #{hash['email']}."
  end

end

And /^press (.*) button$/ do |login_button|
  click_button login_button
  
end

Then /^I able to login to InoCrm system as (.*).$/ do |user|
  if page.has_content? "Signed in successfully."
    puts "User #{user} is successfully signed in"
    step "I am Unauthorized user"
  else
    expect(page).to have_content "Invalid email address or password."
  end
  # expect(page).to have_content "Signed in successfully."
end