Given /^I am authorized user$/ do
  step "I am Unauthorized user"
  step "I go to sign in page"
  within("#new_user") do
    step "I enter user email like admin@inovacrm.com"
    step "I enter user password like 123456789"
  end
  step "I click button Log in"
  step "I should see expected Signed in successfully."
end

When /^Go to admin brand screen in inventories.$/ do
  visit('/admins/inventories/inventory_brand')
  expect(page).to have_current_path('/admins/inventories/inventory_brand')
end

And /^I enter brand (.*): (.*)$/ do |name, brand_name|
  expect(page).to have_current_path('/admins/inventories/inventory_brand')

  within("#new_inventory_category1") do
    fill_in "inventory_category1[#{name}]", :with => brand_name
  end
end

When /^I click button (.*)$/ do |save_button|
  # expect(page).to have_current_path('/admins/inventories/inventory_brand')

  click_button save_button
end

When /^I click link (.*)$/ do |save_button|
  # expect(page).to have_current_path('/admins/inventories/inventory_brand')

  click_link save_button
end

Then /^I should see expected (.*)$/ do |message|
  # expect(page).to have_current_path('/admins/inventories/inventory_brand')
  expect(page).to have_content message
end

Given /^I able to see (.*):$/ do |table|
  table.hashes.each do |hash|
    within("#new_user") do
      fill_in 'user[email]', :with => hash["email"]
      fill_in 'user[password]', :with => hash["password"]
    end
    step "press Log in button"
    step "I able to login to InoCrm system as #{hash['email']}."
  end
end