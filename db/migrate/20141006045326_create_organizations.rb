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
      t.integer :created_by
      t.integer :updated_by
      t.datetime :deleted_at
      t.integer :deleted_by
      t.string :refers
      t.string :code
      t.string :category
      t.integer :parent_organization_id
      t.timestamps
    end
  end
end
