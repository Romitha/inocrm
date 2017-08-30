class SupportAndUserUpdates < ActiveRecord::Migration
  def change
    add_column :spt_customer, :created_by, "INT UNSIGNED NULL"
    add_column :spt_contact_report_person, :created_by, "INT UNSIGNED NULL"
    add_column :addresses, :created_by, "INT UNSIGNED NULL"
    add_column :addresses, :updated_by, "INT UNSIGNED NULL"
    add_column :addresses, :deleted_at, :datetime
    add_column :addresses, :deleted_by, "INT UNSIGNED NULL"
    add_column :organization_contact_person, :created_at, :datetime
    add_column :organization_contact_person, :created_by, "INT UNSIGNED NULL"
    add_column :organization_contact_person, :updated_at, :datetime
    add_column :organization_contact_person, :updated_by, "INT UNSIGNED NULL"
    add_column :organization_contact_person, :deleted_by, "INT UNSIGNED NULL"
    add_column :organization_contact_person, :deleted_at, :datetime


    [
      { table: :spt_customer, column: :created_by, options: {name: "fk_spt_customer_users1_idx"} },
      { table: :spt_contact_report_person, column: :created_by, options: {name: "fk_spt_contact_report_person_users1_idx"} },
      { table: :addresses, column: :created_by, options: {name: "fk_addresses_users1_idx"} },
      { table: :addresses, column: :updated_by, options: {name: "fk_addresses_users2_idx"} },
      { table: :addresses, column: :deleted_by, options: {name: "fk_addresses_users3_idx"} },
      { table: :organization_contact_person, column: :created_by, options: {name: "fk_organization_contact_person_users1_idx"} },
      { table: :organization_contact_person, column: :updated_by, options: {name: "fk_organization_contact_person_users2_idx"} },
      { table: :organization_contact_person, column: :deleted_by, options: {name: "fk_organization_contact_person_users3_idx"} },
    ]
    .each do |f|
      add_index f[:table], f[:column], f[:options]
    end

    execute "SET FOREIGN_KEY_CHECKS = 0"
    [
      { table: :spt_customer, reference_table: :users, name: "fk_spt_customer_users1", column: :created_by },
      { table: :spt_contact_report_person, reference_table: :users, name: "fk_spt_contact_report_person_users1", column: :created_by },
      { table: :addresses, reference_table: :users, name: "fk_addresses_users1", column: :created_by },
      { table: :addresses, reference_table: :users, name: "fk_addresses_users2", column: :updated_by },
      { table: :addresses, reference_table: :users, name: "fk_addresses_users3", column: :deleted_by },
      { table: :organization_contact_person, reference_table: :users, name: "fk_organization_contact_person_users3", column: :deleted_by },
      { table: :organization_contact_person, reference_table: :users, name: "fk_organization_contact_person_users1", column: :created_by },
      { table: :organization_contact_person, reference_table: :users, name: "fk_organization_contact_person_users2", column: :updated_by },
    ]
    .each do |f|
      add_foreign_key f[:table], f[:reference_table], name: f[:name], column: f[:column]
    end
    execute "SET FOREIGN_KEY_CHECKS = 1"


  end
end
