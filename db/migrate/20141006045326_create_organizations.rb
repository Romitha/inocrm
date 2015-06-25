class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      t.string :short_name
      t.text :description
      t.integer :state
      t.integer :status
      t.string :logo
      t.string :vat_number
      t.string :web_site
      t.column :created_by, "int(10) UNSIGNED"
      t.column :updated_by, "int(10) UNSIGNED"
      t.datetime :deleted_at
      t.column :deleted_by, "int(10) UNSIGNED"
      t.string :refers
      t.string :code
      t.string :category
      t.column :parent_organization_id, "int(10) UNSIGNED"
      t.column :type_id, "int(10) UNSIGNED NOT NULL"
      t.timestamps
    end
  end
end
