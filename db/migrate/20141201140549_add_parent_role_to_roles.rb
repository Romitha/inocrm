class AddParentRoleToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :parent_role, :boolean
  end
end
