class AddSrrIdToInvGrn < ActiveRecord::Migration
  def change
  	add_column :inv_grn, :srr_id, "INT UNSIGNED NULL"
  	add_column :inv_grn_item, :srr_item_id, "INT UNSIGNED NULL"

  	add_index :inv_grn, :srr_id, name: "fk_inv_grn_inv_srr1_idx"
  	add_index :inv_grn_item, :srr_item_id, name: "fk_inv_grn_item_inv_srr_item1_idx"

  	add_foreign_key :inv_grn, :inv_srr, column: :srr_id, name: "fk_inv_grn_inv_srr1"
  	add_foreign_key :inv_grn_item, :inv_srr_item, column: :srr_item_id, name: "fk_inv_grn_item_inv_srr_item1"
  end
end
