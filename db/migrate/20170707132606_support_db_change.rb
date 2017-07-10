class SupportDbChange < ActiveRecord::Migration
  def change
    add_column :spt_ticket_engineer, :task_description, "TEXT NULL"

    create_table :mst_contact_person_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name, null: false, limit:200
    end

    create_table :organization_contact_person, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :organization_id, "INT UNSIGNED NOT NULL"
      t.column :title_id, "INT UNSIGNED NOT NULL"
      t.string :name, null: false, limit:200
      t.string :email, null: true, limit:200
      t.string :mobile, null: true, limit:200
      t.string :telephone, null: true, limit:200
      t.column :type_id, "INT UNSIGNED NOT NULL"
      t.text :note, null:true
      t.index :organization_id, name: "fk_organization_contact_organizations1_idx"
      t.index :title_id, name: "fk_organization_contact_addresses_mst_titles1_idx"
      t.index :type_id, name: "fk_organization_contact_person_mst_contact_person_type1_idx"
    end
    add_foreign_key :organization_contact_person, :organizations, name: "fk_organization_contact_organizations11", column: :organization_id
    add_foreign_key :organization_contact_person, :mst_title, name: "fk_organization_contact_addresses_mst_titles10", column: :title_id
    add_foreign_key :organization_contact_person, :mst_contact_person_type, name: "fk_organization_contact_person_mst_contact_person_type1", column: :type_id

  end
end