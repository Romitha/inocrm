class Changeversion1 < ActiveRecord::Migration
  def change
  	create_table :mst_spt_sla, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :description
      t.decimal :sla_time, precision: 8, scale: 2
      t.datetime :created_at
      t.column :created_by, "INT UNSIGNED"
      t.timestamps
    end

    #add remove columns
    remove_column :company_config, :sup_sla_time, :integer
    add_column :company_config, :sup_sla_id, "INT UNSIGNED"

    remove_column :mst_spt_product_brand, :sla_time, :integer
    add_column :mst_spt_product_brand, :sla_id, "INT UNSIGNED"

    remove_column :mst_spt_product_category, :sla_time, :integer
    add_column :mst_spt_product_category, :sla_id, "INT UNSIGNED"

    remove_column :spt_contract, :sla, :integer
    add_column :spt_contract, :sla_id, "INT UNSIGNED"

    remove_column :spt_contract_product, :sla, :integer
    add_column :spt_contract_product, :sla_id, "INT UNSIGNED"

    remove_column :spt_ticket, :sla_time, :integer
    add_column :spt_ticket, :sla_id, "INT UNSIGNED"




    #remove FK
    [
      {table_name: "spt_contract", constraint_name: "fk_spt_contract_users1"},
      ].each do |attr|
      execute("ALTER TABLE `#{attr[:table_name]}` DROP FOREIGN KEY `#{attr[:constraint_name]}`")
    end


    [
      {table_name: "spt_contract_product", constraint_name: "fk_spt_contract_product_mst_organzation1"},
      ].each do |attr|
      execute("ALTER TABLE `#{attr[:table_name]}` DROP FOREIGN KEY `#{attr[:constraint_name]}`")
    end

    [
      {table_name: "spt_ticket", constraint_name: "fk_spt_ticket_mst_currency2"},
      ].each do |attr|
      execute("ALTER TABLE `#{attr[:table_name]}` DROP FOREIGN KEY `#{attr[:constraint_name]}`")
    end



    #add FK

    [
      {constraint_name: "fk_company_config_mst_spt_sla1", foreign_key: "sup_sla_id", reference_table: "mst_spt_sla"}
    ].each do |attr|
      execute "ALTER TABLE `company_config` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {constraint_name: "fk_mst_spt_product_brand_mst_spt_sla1", foreign_key: "sla_id", reference_table: "mst_spt_sla"}
    ].each do |attr|
      execute "ALTER TABLE `mst_spt_product_brand` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {table_name:"spt_contract",constraint_name: "fk_spt_contract_users1", foreign_key: "created_by", reference_table: "users"},
      {table_name:"spt_contract",constraint_name: "fk_spt_contract_mst_spt_sla1", foreign_key: "sla_id", reference_table: "mst_spt_sla"}
    ].each do |attr|
      execute "ALTER TABLE `spt_contract` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {table_name:"spt_contract_product",constraint_name: "fk_spt_contract_product_mst_organzation1", foreign_key: "installed_location_id", reference_table: "organizations"},
      {table_name:"spt_contract_product",constraint_name: "fk_spt_contract_product_mst_spt_sla1", foreign_key: "sla_id", reference_table: "mst_spt_sla"}
    ].each do |attr|
      execute "ALTER TABLE `spt_contract_product` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end

    [
      {table_name:"spt_ticket",constraint_name: "fk_spt_ticket_mst_currency2", foreign_key: "manufacture_currency_id", reference_table: "mst_currency"},
      {table_name:"spt_ticket",constraint_name: "fk_spt_ticket_mst_spt_sla1", foreign_key: "sla_id", reference_table: "mst_spt_sla"}
    ].each do |attr|
      execute "ALTER TABLE `spt_ticket` ADD CONSTRAINT `#{attr[:constraint_name]}` FOREIGN KEY (`#{attr[:foreign_key]}`) REFERENCES `#{attr[:reference_table]}` (`id`)"
    end
  end
end
