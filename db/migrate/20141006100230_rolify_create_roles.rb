class RolifyCreateRoles < ActiveRecord::Migration
  def change
    create_table(:roles, id:false) do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      #t.references :resource, :polymorphic => true
      t.column :resource_id, "INT(10) UNSIGNED"#, :polymorphic => true
      t.string :resource_type
      t.boolean :parent_role
      t.timestamps
    end

    create_table(:users_roles, :id => false) do |t|
      # t.references :user
      # t.references :role
      t.column :user_id, "INT(10) UNSIGNED"
      t.column :role_id, "INT(10) UNSIGNED"
    end

    add_index(:roles, :name)
    add_index(:roles, [ :name, :resource_type, :resource_id ])
    add_index(:users_roles, [ :user_id, :role_id ])
  end
end
