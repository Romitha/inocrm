require 'test_helper'

class InventoryTest < ActiveSupport::TestCase
  test "save organization" do
  	organization = FacoryGirl.build(:organization)
    assert organization.save
  end
end
