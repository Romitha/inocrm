class LatestChanges < ActiveRecord::Migration
  def change
  	remove_column :company_config, :last_account_code

  	add_column :company_config, :last_account_no, :integer, null:false, default:0
  	add_column :company_config, :sup_mf_parts_need_warranty, :boolean, null:false, default:1
  	add_column :company_config, :sup_mf_parts_need_quantity,:boolean, null:false, default:0

  	add_column :accounts, :business_registration_no, :string, limit: 100
  	add_column :accounts, :account_no,:integer, null:false, default:0

  	add_column :organization_contact_person, :designation,:string, limit: 200
  	
    remove_column :organizations, :vat_number
    remove_column :organizations, :account_no


  	create_table :organization_contact_addresses, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :oraganization_id, "INT UNSIGNED NOT NULL"
      t.string :address1, limit:500, null:false
      t.string :address2, limit:500, null:false
      t.string :address3, limit:500, null:false
      t.column :district_id, "INT UNSIGNED NULL"
      t.column :province_id, "INT UNSIGNED NULL"
      t.column :country_id, "INT UNSIGNED NULL"
      t.string :po_box, limit:100
      t.string :postal_code, limit:100
      t.boolean :primary_address, null:false, default:0

      t.index :oraganization_id, name: "fk_oraganization_contact_oraganizations1_idx"
      t.index :province_id, name: "fk_oraganization_contact_addresses_options_province1"
      t.index :district_id, name: "fk_oraganization_contact_addresses_options_district1"
      t.index :country_id, name: "fk_oraganization_contact_addresses_options_country1"
    end

    create_table :mst_contact_person_primary_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name, limit:200, null:false
      t.string :code, limit:10, null:false
    end


    create_table :contact_person_primary_type, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :contact_person_id, "INT UNSIGNED NOT NULL"
      t.column :primary_type_id, "INT UNSIGNED NOT NULL" 

      t.index :contact_person_id, name: "fk_contact_person_primary_type_organization_contact_person1_idx"
      t.index :primary_type_id, name: "fk_contact_person_primary_type_mst_contact_person_primary_t_idx"
    end

    execute "SET FOREIGN_KEY_CHECKS = 0"
    [
      { table: :contact_person_primary_type, reference_table: :organization_contact_person, name: "fk_contact_person_primary_type_organization_contact_person1", column: :contact_person_id },
      { table: :contact_person_primary_type, reference_table: :mst_contact_person_primary_type, name: "fk_contact_person_primary_type_mst_contact_person_primary_type1", column: :primary_type_id },
    ]
    .each do |f|
      add_foreign_key f[:table], f[:reference_table], name: f[:name], column: f[:column]
    end
    execute "SET FOREIGN_KEY_CHECKS = 1"

  	# drop_table :oraganization_contact_person

  	remove_foreign_key :organizations, column: :contact_person1_id
    remove_index :organizations, name: "fk_organizations_oraganization_contact_person1_idx"
    remove_column :organizations, :contact_person1_id

    remove_foreign_key :organizations, column: :contact_person2_id
    remove_index :organizations, name: "fk_organizations_oraganization_contact_person2_idx"
    remove_column :organizations, :contact_person2_id
  end
end
