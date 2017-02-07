class AddMoreInventoryColumns < ActiveRecord::Migration
  def change
    add_column :inv_srr_item, :total_cost, "DECIMAL(13,2) NOT NULL DEFAULT 0"
    add_column :inv_srr_item, :currency_id, "INT UNSIGNED NOT NULL"
    add_index :inv_srr_item, :currency_id, name: "fk_inv_srr_item_mst_currency1_idx"
    add_foreign_key :inv_srr_item, :currency_id
    add_column :inv_gin_item, :total_cost, "DECIMAL(13,2) NOT NULL DEFAULT 0"
    execute "SET FOREIGN_KEY_CHECKS = 0"
    add_foreign_key :inv_srr_item, :mst_currency, name: "fk_inv_srr_item_mst_currency1", column: :currency_id
    execute "SET FOREIGN_KEY_CHECKS = 1"
  end
end