class DbChangeMstCountry < ActiveRecord::Migration
  def change
    add_column :mst_country, :local, :boolean, null: false, default: false

    remove_foreign_key :addresses, name: :fk_addresses_mst_contact_type
    remove_index :addresses, name: :fk_addresses_for_type_idx
    remove_column :addresses, :type_id

    add_column :addresses, :city, :string

    rename_column :addresses, :address, :address1
    add_column :addresses, :address2, :text
    add_column :addresses, :address3, :text

    add_column :addresses, :contact_person_title_id, "INT UNSIGNED"
    add_index :addresses, :contact_person_title_id, name: "fk_oraganization_contact_addresses_mst_titles1_idx"
    add_foreign_key :addresses, :mst_title, name: :fk_oraganization_contact_addresses_mst_titles1, column: :contact_person_title_id

    add_column :addresses, :contact_person_name, :string

    change_column_null :spt_customer, :title_id, true

    add_column :organizations, :title_id, "INT UNSIGNED"
    add_index :organizations, :title_id, name: "fk_organizations_mst_titles1_idx"
    add_foreign_key :organizations, :mst_title, name: :fk_organizations_mst_titles1, column: :title_id

    add_column :inv_grn, :supplier_id, "INT UNSIGNED"
    add_index :inv_grn, :supplier_id, name: "fk_inv_grn_organzations1_idx"

    add_foreign_key :inv_grn, :organizations, name: :fk_inv_grn_organzations1, column: :supplier_id

  end
end
