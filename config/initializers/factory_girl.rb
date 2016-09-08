# http://www.rubydoc.info/gems/factory_girl/file/GETTING_STARTED.md
FactoryGirl.define do
  factory :user do
    email "admin@inovacrm.com"
    password "123456789"
  end

  Inventory
  factory :brand, class: InventoryCategory1 do
    
  end
  
end