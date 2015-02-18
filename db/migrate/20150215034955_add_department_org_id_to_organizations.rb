class AddDepartmentOrgIdToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :department_org_id, :integer, index: true
  end
end
