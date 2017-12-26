class ContractDatabaseLatest < ActiveRecord::Migration
  def change
    remove_foreign_key :mst_spt_product_category1, name: :fk_mst_spt_product_category_mst_spt_prodcut_brand10
    remove_index :mst_spt_product_category1, name: :fk_mst_spt_product_category_mst_spt_prodcut_brand1
    remove_column :mst_spt_product_category1, :product_brand_id


    remove_foreign_key :mst_inv_category3, name: :fk_mst_inv_category3_mst_spt_product_brand1
    remove_index :mst_inv_category3, name: :fk_mst_inv_category3_mst_spt_product_brand1_idx
    remove_column :mst_inv_category3, :spt_product_brand_id

    remove_foreign_key :mst_inv_category3, name: :fk_mst_inv_category3_mst_spt_product_category11
    remove_index :mst_inv_category3, name: :fk_mst_inv_category3_mst_spt_product_category11_idx
    remove_column :mst_inv_category3, :spt_product_category1_id

    remove_foreign_key :mst_inv_category3, name: :fk_mst_inv_category3_mst_spt_product_category21
    remove_index :mst_inv_category3, name: :fk_mst_inv_category3_mst_spt_product_category21_idx
    remove_column :mst_inv_category3, :spt_product_category2_id

    remove_foreign_key :mst_inv_category3, name: :fk_mst_inv_category3_mst_spt_product_category31
    remove_index :mst_inv_category3, name: :fk_mst_inv_category3_mst_spt_product_category31_idx
    remove_column :mst_inv_category3, :spt_product_category3_id


    add_column :mst_spt_product_category1, :product_brand_id, "INT UNSIGNED NOT NULL"

    add_column :mst_inv_category3, :spt_product_brand_id, "INT UNSIGNED NOT NULL"
    add_column :mst_inv_category3, :spt_product_category1_id, "INT UNSIGNED NOT NULL"
    add_column :mst_inv_category3, :spt_product_category2_id, "INT UNSIGNED NOT NULL"
    add_column :mst_inv_category3, :spt_product_category_id, "INT UNSIGNED NOT NULL"

    add_column :spt_contract_payment_installment, :installment_start_date, "DATETIME NOT NULL"
    add_column :spt_contract_payment_installment, :installment_end_date, "DATETIME NOT NULL"


    [
      { table: :mst_spt_product_category1, column: :product_brand_id, options: {name: "fk_mst_spt_product_category_mst_spt_prodcut_brand1"} },

      { table: :mst_inv_category3, column: :spt_product_brand_id, options: {name: "fk_mst_inv_category3_mst_spt_product_brand1_idx"} },
      { table: :mst_inv_category3, column: :spt_product_category1_id, options: {name: "fk_mst_inv_category3_mst_spt_product_category11_idx"} },
      { table: :mst_inv_category3, column: :spt_product_category2_id, options: {name: "fk_mst_inv_category3_mst_spt_product_category21_idx"} },
      { table: :mst_inv_category3, column: :spt_product_category_id, options: {name: "fk_mst_inv_category3_mst_spt_product_category1_idx"} },
    ]
    .each do |f|
      add_index f[:table], f[:column], f[:options]
    end
    execute "SET FOREIGN_KEY_CHECKS = 0"
    [
      { table: :mst_spt_product_category1, reference_table: :mst_spt_product_brand, name: "fk_mst_spt_product_category_mst_spt_prodcut_brand10", column: :product_brand_id },
      { table: :mst_inv_category3, reference_table: :mst_spt_product_brand, name: "fk_mst_inv_category3_mst_spt_product_brand1", column: :spt_product_brand_id },
      { table: :mst_inv_category3, reference_table: :mst_spt_product_category1, name: "fk_mst_inv_category3_mst_spt_product_category11", column: :spt_product_category1_id },
      { table: :mst_inv_category3, reference_table: :mst_spt_product_category2, name: "fk_mst_inv_category3_mst_spt_product_category21", column: :spt_product_category2_id },
      { table: :mst_inv_category3, reference_table: :mst_spt_product_category, name: "fk_mst_inv_category3_mst_spt_product_category1", column: :spt_product_category_id },
    ]
    .each do |f|
      add_foreign_key f[:table], f[:reference_table], name: f[:name], column: f[:column]
    end
    execute "SET FOREIGN_KEY_CHECKS = 1"  end

end