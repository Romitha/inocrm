Given /^I am authorized user with role of admin$/ do
  visit('/users/sign_out') # ensure that at least
  visit('/users/sign_in')
  within("#new_user") do
    fill_in 'user[email]', :with => "admin@inovacrm.com"
    fill_in 'user[password]', :with => "123456789"
  end
  step "press Log in button"
  expect(page).to have_content "Signed in successfully."
end

When /^Go to admin brand screen in inventories.$/ do
  visit('/admins/inventories/inventory_brand')
  expect(page).to have_current_path('/admins/inventories/inventory_brand')
end

When /^I enter brand (.*): (.*)$/ do |name, brand_name|
  expect(page).to have_current_path('/admins/inventories/inventory_brand')

  within("#new_inventory_category1") do
    fill_in "inventory_category1[#{name}]", :with => brand_name
  end
end

When /^I click (.*)$/ do |save_button|
  expect(page).to have_current_path('/admins/inventories/inventory_brand')

  click_button save_button
end

Then /^I should see expected (.*)$/ do |message|
  expect(page).to have_current_path('/admins/inventories/inventory_brand')
  expect(page).to have_content message
end

When /^brand (.*) is empty$/ do |name|
  expect(find_field("inventory_category1[#{name}]").value).to eq ""
end

Then /^I should see error message like This field is required in brand (.*) field$/ do |name|
  expect(find("#inventory_category1_#{name}-error")).to have_content "This field is required."
end