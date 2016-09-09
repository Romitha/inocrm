When /^Go to admin PRN form screen in inventories.$/ do
  visit prn_admins_inventories_path
  expect(page).to have_current_path('/admins/inventories/prn')
  # expect(page.status_code).to eq 200
end

Given /^I able to see store name (.*) within (.*)$/ do |name, wrapper|
  # within("##{wrapper}") do
  #   expect(find(".list-group-item-heading")).to have_content name
  # end
end

Given(/^I able to see prn form$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

# Given(/^I create store with:$/) do |table|
#   table.hashes.each do |hash|
#     FactoryGirl.create :organization, hash
#   end

# end