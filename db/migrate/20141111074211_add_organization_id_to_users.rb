class AddOrganizationIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :organization_id, :integer
    # add_reference :users, :organization it is simply able to set like this, is equivalent to above code
  end
end