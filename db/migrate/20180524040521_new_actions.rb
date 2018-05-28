class NewActions < ActiveRecord::Migration
  def change
    # create_table :spt_customer_product_history, id: false do |t|
    #   t.column :id, 'INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY(id)'
    #   t.column :customer_id, 'INT UNSIGNED NOT NULL'
    #   t.column :product_serial_id, 'INT UNSIGNED NOT NULL'
    #   t.column :created_mode, 'INT UNSIGNED NOT NULL'
    #   t.column :created_at, 'DATETIME NOT NULL'
    #   t.column :created_by, 'INT UNSIGNED NULL'
    #   t.column :removed_at, 'DATETIME NULL'
    #   t.column :removed_by, 'INT UNSIGNED NULL'
    #   t.column :note, 'TEXT NULL'

    #   t.index :created_by, name: "fk_spt_customer_product_history_users1_idx"
    #   t.index :removed_by, name: "fk_spt_customer_product_history_users2_idx"
    #   t.index :customer_id, name: "fk_spt_customer_product_history_organizations1_idx"
    #   t.index :customer_id, name: "fk_spt_customer_product_history_spt_product_serial1_idx"
    #   t.index :product_serial_id, name: "fk_spt_customer_product_history_organizations1_idx"
    # end

    add_column :spt_customer_product_history, :created_mode, "INT UNSIGNED NOT NULL DEFAULT 0"
    add_column :spt_customer_product_history, :removed_at, "DATETIME NULL"
    add_column :spt_customer_product_history, :removed_by, "INT UNSIGNED NULL"

    add_column :spt_contract, :account_managed_by, "INT UNSIGNED NULL"
    add_column :spt_contract, :so_number, :string, limit: 100, null: true

    add_column :inv_prn, :support_ticket_no, :string, limit: 100, null: true
    add_column :spt_ticket_action, :note, "TEXT NULL"
    add_column :spt_ticket, :product_inside, :boolean, null: false, default: 0

    add_index :spt_contract, :account_managed_by, name: "fk_spt_contract_users3_idx"

    execute "SET FOREIGN_KEY_CHECKS = 0"
    [
      { table: :spt_customer_product_history, reference_table: :users, name: "fk_spt_customer_product_history_users2", column: :removed_by },
      { table: :spt_contract, reference_table: :users, name: "fk_spt_contract_users3", column: :account_managed_by },
      # { table: :spt_customer_product_history, reference_table: :users, name: "fk_spt_customer_product_history_users1", column: :created_by },
      # { table: :spt_customer_product_history, reference_table: :organizations, name: "fk_spt_customer_product_history_organizations1", column: :customer_id },
      # { table: :spt_customer_product_history, reference_table: :spt_product_serial, name: "fk_spt_customer_product_history_spt_product_serial1", column: :product_serial_id },
    ]
    .each do |f|
      add_foreign_key f[:table], f[:reference_table], name: f[:name], column: f[:column]
    end
    execute "SET FOREIGN_KEY_CHECKS = 1"
  end
end
