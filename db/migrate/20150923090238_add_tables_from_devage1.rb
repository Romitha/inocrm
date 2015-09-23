class AddTablesFromDevage1 < ActiveRecord::Migration
  def change

		create_table :mst_dealer_types, id: false do |t|
			t.column :id, "INT UNSIGNED NOT NULL, PRIMARY KEY (id)"
			t.string :name, null: false
			t.string :code, null: false
		end

		create_table :accounts, id: false do |t|
			t.column :id, "INT UNSIGNED NOT NULL, PRIMARY KEY (id)"
			t.datetime :created_at
			t.column :created_by, "int(10) UNSIGNED"
			t.column :industry_types_id, "int(10) UNSIGNED"
			t.column :organization_id, "int(10) UNSIGNED NOT NULL"
			t.boolean :active, null: false, default: true
		end

		create_table :accounts_dealer_type, id: false do |t|
			t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
			t.column :dealer_types_id, "int(10) UNSIGNED NOT NULL"
			t.column :dealers_id, "int(10) UNSIGNED NOT NULL"
		end

		create_table :mst_industry_types, id: false do |t|
			t.column :id, "INT UNSIGNED NOT NULL, PRIMARY KEY (id)"
			t.string :name, null: false
			t.string :code
		end

		[
			{constraint_name: "fk_dealers_dealer_type_options_dealer_types1", foreign_key: "dealer_types_id", reference_table: "mst_dealer_types"},
			{constraint_name: "fk_dealers_dealer_type_dealers1", foreign_key: "dealers_id", reference_table: "accounts"}
		].each do |attr|

			add_foreign_key(:accounts_dealer_type, attr[:reference_table].to_sym, name: attr[:constraint_name], column: attr[:foreign_key])
		end

		[
			{constraint_name: "fk_dealers_users2", foreign_key: "created_by", reference_table: "users"},
			{constraint_name: "fk_dealers_industry_types1", foreign_key: "industry_types_id", reference_table: "mst_industry_types"},
			{constraint_name: "fk_accounts_organizations1", foreign_key: "organization_id", reference_table: "organizations"}

		].each do |attr|

			add_foreign_key(:accounts, attr[:reference_table].to_sym, name: attr[:constraint_name], column: attr[:foreign_key])
		end

  end
end