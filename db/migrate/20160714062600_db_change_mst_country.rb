class DbChangeMstCountry < ActiveRecord::Migration
  def change
    add_column :mst_country, :local, :boolean, default:0

    remove_foreign_key :addresses, name: :fk_addresses_mst_contact_type
    remove_index :addresses, name: :fk_addresses_type_idx
    remove_column :addresses, :type_id

    add_column :addresses, :city, :string, null: true

    rename_column :addresses, :address, :address1
    add_column :addresses, :address2, :text
    add_column :addresses, :address3, :text

    add_column :addresses, :contact_person_title_id, "INT UNSIGNED NULL"
    add_index :addresses, :contact_person_title_id, name: "fk_oraganization_contact_addresses_mst_titles1_idx"
    add_foreign_key :addresses, :mst_title, name: :fk_oraganization_contact_addresses_mst_titles1, column: :contact_person_title_id

    add_column :addresses, :contact_person_name, :string, null: true

    add_index :mst_contact_types, :validate_id, name: "fk_mst_contact_types_mst_contact_type_validate1_idx"

    change_column_null :spt_customer, :title_id, true

    add_column :organizations, :title_id, "INT UNSIGNED NULL"
    add_index :organizations, :title_id, name: "fk_organizations_mst_titles1_idx"
    add_foreign_key :organizations, :mst_title, name: :fk_organizations_mst_titles1, column: :title_id

    add_column :inv_grn, :supplier_id, "INT UNSIGNED NULL"
    add_index :inv_grn, :supplier_id, name: "fk_inv_grn_organzations1_idx"

    execute "ALTER TABLE mst_contact_types CHANGE validate_id validate_id INT( 10 ) UNSIGNED NOT NULL"

    add_foreign_key :mst_contact_types, :mst_contact_type_validate, name: :fk_mst_contact_types_mst_contact_type_validate1, column: :validate_id

    add_foreign_key :inv_grn, :organizations, name: :fk_inv_grn_organzations1, column: :supplier_id

  end
end
