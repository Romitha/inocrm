class UserModule < ActiveRecord::Migration
  def change
    # create_table :mst_titles, id: false do |t|
    #   t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
    #   t.string :name, null: false, limit:100
    # end

    # create_table :mst_contact_person_type, id: false do |t|
    #   t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
    #   t.string :name, null: false, limit:200
    # end

    # create_table :oraganization_contact_person, id: false do |t|
    #   t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
    #   t.column :oraganization_id, "INT UNSIGNED NOT NULL"
    #   t.column :title_id, "INT UNSIGNED NOT NULL"
    #   t.string :name, null: false, limit:200
    #   t.string :email, null: true, limit:200
    #   t.string :mobile, null: true, limit:200
    #   t.string :telephone, null: true, limit:200
    #   t.column :type_id, "INT UNSIGNED NOT NULL"
    #   t.text :note, null:true
    #   t.index :oraganization_id, name: "fk_oraganization_contact_oraganizations1_idx"
    #   t.index :title_id, name: "fk_oraganization_contact_addresses_mst_titles1_idx"
    #   t.index :type_id, name: "fk_oraganization_contact_person_mst_contact_person_type1_idx"
    # end
    # add_foreign_key :oraganization_contact_person, :organizations, name: "fk_oraganization_contact_oraganizations11", column: :oraganization_id
    # add_foreign_key :oraganization_contact_person, :mst_title, name: "fk_oraganization_contact_addresses_mst_titles10", column: :title_id
    # add_foreign_key :oraganization_contact_person, :mst_contact_person_type, name: "fk_oraganization_contact_person_mst_contact_person_type1", column: :type_id

    add_index :organizations, :created_by, name: "fk_organizations_users1"
    add_index :organizations, :updated_by, name: "fk_organizations_users2"
    add_index :organizations, :deleted_by, name: "fk_organizations_users3"
    add_index :organizations, :type_id, name: "fk_organizations_mst_organization_types1_idx"
    add_index :organizations, :parent_organization_id, name: "fk_organizations_organizations1_idx"

    add_foreign_key(:organizations, :users, name: "fk_organizations_created_by_users1", column: :created_by)
    add_foreign_key(:organizations, :users, name: "fk_organizations_updated_by_users1", column: :updated_by)
    add_foreign_key(:organizations, :users, name: "fk_organizations_deleted_by_users1", column: :deleted_by)
    add_foreign_key(:organizations, :mst_organization_types, name: "fk_organizations_mst_organization_types1", column: :type_id)
    add_foreign_key(:organizations, :organizations, name: "fk_organizations_organizations1", column: :parent_organization_id)
    
    add_column :accounts, :code, "INT UNSIGNED NULL"
    add_column :accounts, :vat_no, :string, limit:100, null:true
    add_column :accounts, :svat_no, :string, limit:100, null:true
    add_column :accounts, :goodwill_status, :integer, null:false, default:1
    add_column :accounts, :credit_allow, :boolean, null:false
    add_column :accounts, :credit_period_day, :integer, null:true
    add_column :accounts, :account_manager_id, "INT UNSIGNED NULL"
    
    add_index :accounts, :account_manager_id, name: "fk_accounts_users1_idx"
    add_foreign_key(:accounts, :users, name: "fk_accounts_users1", column: :account_manager_id)

    remove_column :users, :organization_id
    add_column :users, :organization_id, "INT UNSIGNED NULL"
    add_column :users, :created_by, "INT UNSIGNED NULL"
    add_column :users, :updated_by, "INT UNSIGNED NULL"
    add_column :users, :deleted_by, "INT UNSIGNED NULL"
    remove_column :users, :title_id
    add_column :users, :title_id, "INT UNSIGNED NULL"
    add_column :users, :account_id, "INT UNSIGNED NULL"

    add_index :users, :organization_id, name: "fk_users_oraganizations1_idx"
    add_index :users, :created_by, name: "fk_users_users1"
    add_index :users, :updated_by, name: "fk_users_users2"
    add_index :users, :deleted_by, name: "fk_users_users3"

    remove_column :spt_contract, :contract_no
    add_column :spt_contract, :contract_no,:string, null:false, unique: true

    # create_table :oraganization_contact_addresses, id: false do |t|
    #   t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
    #   t.column :oraganization_id, "INT UNSIGNED NOT NULL"
    #   t.string :address1, null: false, limit:500
    #   t.string :address2, null: false, limit:500
    #   t.string :address3, null: false, limit:500
    #   t.string :city, null: true, limit:200
    #   t.column :district_id, "INT UNSIGNED NOT NULL"
    #   t.column :province_id, "INT UNSIGNED NOT NULL"
    #   t.column :country_id, "INT UNSIGNED NOT NULL"
    #   t.string :po_box, null: true, limit:100
    #   t.string :postal_code, null: true, limit:100

    #   t.index :oraganization_id, name: "fk_oraganization_contact_oraganizations1_idx"
    #   t.index :province_id, name: "fk_oraganization_contact_addresses_options_province1"
    #   t.index :district_id, name: "fk_oraganization_contact_addresses_options_district1"
    #   t.index :country_id, name: "fk_oraganization_contact_addresses_options_country1_idx"
    # end
    # add_foreign_key :oraganization_contact_addresses, :organizations, name: "fk_oraganization_contact_oraganizations1", column: :oraganization_id
    # add_foreign_key :oraganization_contact_addresses, :mst_country, name: "fk_oraganization_contact_addresses_options_country1", column: :country_id
    
    # create_table :mst_designations, id: false do |t|
    #   t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
    #   t.string :name, null: false, limit:200
    # end

    # create_table :mst_termination_reason, id: false do |t|
    #   t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
    #   t.string :name, null: false, limit:200
    #   t.string :code, null: false, limit:3
    # end
    # create_table :user_employees, id: false do |t|
    #   t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
    #   t.column :user_id, "INT UNSIGNED NOT NULL"
    #   t.column :designation_id, "INT UNSIGNED NOT NULL"
    #   t.string :epf_no, null: true, limit:45
    #   t.datetime :date_joined, null: true
    #   t.column :termination_reason_id, "INT UNSIGNED NOT NULL"
    #   t.datetime :date_terminated, null: true
    #   t.string :picture, null:true

    #   t.index :user_id, name: "fk_user_employees_users1_idx"
    #   t.index :designation_id, name: "fk_user_employees_options_designations1"
    # end
    
    # create_table :mst_groups, id: false do |t|
    #   t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
    #   t.string :name, null: true, limit:45
    #   t.string :permissions, null: true, limit:45
    # end
    
    # create_table :user_groups, id: false do |t|
    #   t.column :user_id, "INT UNSIGNED NOT NULL"
    #   t.column :group_id, "INT UNSIGNED NOT NULL"
    #   t.index :user_id, name: "fk_user_groups_users1_idx"
    #   t.index :group_id, name: "fk_user_groups_groups1_idx"
    # end
    # add_foreign_key :user_groups, :users, name: "fk_user_groups_users1", column: :user_id


  end
end
