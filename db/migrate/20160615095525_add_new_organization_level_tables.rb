class AddNewOrganizationLevelTables < ActiveRecord::Migration
  def change
    create_table :customer_service_levels, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :service_level_id, "int(10) UNSIGNED NOT NULL"

      t.index :service_level_id, name: "fk_user_customers_service_level_idx"
      t.timestamps

      # origin user_customers
    end

    create_table :mst_service_levels, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      t.integer :response_time
      t.integer :resolution_time
      t.boolean :defaulted, null: false, default: false
      t.timestamps

    end

    create_table :mst_contact_types, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name, null: false
      t.string :code, null: false
      t.timestamps

    end

    create_table :mst_province, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      t.timestamps

    end

    create_table :mst_organization_types, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :name
      t.timestamps

    end

    add_column :addresses, :type_id, "int(10) UNSIGNED"
    add_index :addresses, :type_id, name: "fk_addresses_type_idx"
    add_column :addresses, :country_id, "int(10) UNSIGNED"
    add_index :addresses, :country_id, name: "fk_addresses_country_idx"
    add_column :addresses, :province_id, "int(10) UNSIGNED"
    add_index :addresses, :province_id, name: "fk_addresses_province_idx"
    add_column :addresses, :district_id, "int(10) UNSIGNED"
    add_index :addresses, :district_id, name: "fk_addresses_district_idx"

    add_column :contact_numbers, :type_id, "int(10) UNSIGNED"
    add_index :contact_numbers, :type_id, name: "fk_contact_numbers_type_idx"
    add_column :contact_numbers, :country_id, "int(10) UNSIGNED"
    add_index :contact_numbers, :country_id, name: "fk_contact_numbers_country_idx"
    add_column :contact_numbers, :province_id, "int(10) UNSIGNED"
    add_index :contact_numbers, :province_id, name: "fk_contact_numbers_province_idx"
    add_column :contact_numbers, :district_id, "int(10) UNSIGNED"
    add_index :contact_numbers, :district_id, name: "fk_contact_numbers_district_idx"

    execute "SET FOREIGN_KEY_CHECKS = 0"
    [
      { table: :accounts, reference_table: :organizations, name: "fk_accounts_organizations", column: :organization_id },
      { table: :customer_service_levels, reference_table: :mst_service_levels, name: "fk_customer_service_levels_mst_service_levels", column: :service_level_id },
      { table: :addresses, reference_table: :mst_contact_types, name: "fk_addresses_mst_contact_type", column: :type_id },
      { table: :addresses, reference_table: :mst_country, name: "fk_addresses_mst_country", column: :country_id },
      { table: :addresses, reference_table: :mst_province, name: "fk_addresses_mst_province", column: :province_id },
      { table: :addresses, reference_table: :mst_district, name: "fk_addresses_mst_district", column: :district_id },
      { table: :contact_numbers, reference_table: :mst_contact_types, name: "fk_contact_numbers_mst_contact_type", column: :type_id },
      { table: :contact_numbers, reference_table: :mst_country, name: "fk_contact_numbers_mst_country", column: :country_id },
      { table: :contact_numbers, reference_table: :mst_province, name: "fk_contact_numbers_mst_province", column: :province_id },
      { table: :contact_numbers, reference_table: :mst_district, name: "fk_contact_numbers_mst_district", column: :district_id },
    ]
    .each do |f|
      add_foreign_key f[:table], f[:reference_table], name: f[:name], column: f[:column]
    end

    execute "SET FOREIGN_KEY_CHECKS = 1"

  end
end
