class UserModule < ActiveRecord::Migration
  def change

    remove_column :users, :organization_id
    remove_column :users, :title_id
    remove_column :spt_contract, :contract_no
    add_column :spt_contract, :contract_no, :string, null: false
    execute "ALTER TABLE spt_contract ADD UNIQUE(contract_no)"

    add_column :accounts, :code, "INT UNSIGNED NULL"
    add_column :accounts, :vat_number, :string, limit:100, null:true
    add_column :accounts, :svat_no, :string, limit:100, null:true
    add_column :accounts, :goodwill_status, :integer, null:false, default:1
    add_column :accounts, :credit_allow, :boolean, null:false, default: 0
    add_column :accounts, :credit_period_day, :integer, null:true
    add_column :accounts, :account_manager_id, "INT UNSIGNED NULL"
    add_column :users, :organization_id, "INT UNSIGNED NULL"
    add_column :users, :created_by, "INT UNSIGNED NULL"
    add_column :users, :updated_by, "INT UNSIGNED NULL"
    add_column :users, :deleted_by, "INT UNSIGNED NULL"
    add_column :users, :title_id, "INT UNSIGNED NULL"
    add_column :users, :account_id, "INT UNSIGNED NULL"

    [
      { table: :organizations, column: :created_by, options: {name: "fk_organizations_users1"} },
      { table: :organizations, column: :updated_by, options: {name: "fk_organizations_users2"} },
      { table: :organizations, column: :deleted_by, options: {name: "fk_organizations_users3"} },
      { table: :organizations, column: :type_id, options: {name: "fk_organizations_mst_organization_types1_idx"} },
      { table: :organizations, column: :parent_organization_id, options: {name: "fk_organizations_organizations1_idx"} },
      { table: :accounts, column: :account_manager_id, options: {name: "fk_accounts_users1_idx"} },
      { table: :users, column: :organization_id, options: {name: "fk_users_oraganizations1_idx"} },
      { table: :users, column: :created_by, options: {name: "fk_users_users1"} },
      { table: :users, column: :updated_by, options: {name: "fk_users_users2"} },
      { table: :users, column: :deleted_by, options: {name: "fk_users_users3"} },
    ].each do |f|
      add_index f[:table], f[:column], f[:options]
    end

    [
      {table: :organizations, reference_table: :users, name: "fk_organizations_created_by_users1", column: :created_by},
      {table: :organizations, reference_table: :users, name: "fk_organizations_updated_by_users1", column: :updated_by},
      {table: :organizations, reference_table: :users, name: "fk_organizations_deleted_by_users1", column: :deleted_by},
      {table: :organizations, reference_table: :mst_organization_types, name: "fk_organizations_mst_organization_types1", column: :type_id},
      {table: :organizations, reference_table: :organizations, name: "fk_organizations_organizations1", column: :parent_organization_id},
      {table: :accounts, reference_table: :users, name: "fk_accounts_users1", column: :account_manager_id},
    ].each do |f|
      add_foreign_key f[:table], f[:reference_table], name: f[:name], column: f[:column]
    end

  end
end
