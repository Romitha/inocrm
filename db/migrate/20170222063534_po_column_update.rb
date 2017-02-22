class PoColumnUpdate < ActiveRecord::Migration
  def change
    add_column :inv_po_item, :description, "TEXT"
    remove_column :inv_po_tax, :tax

    create_table :inv_po_item_tax, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :po_item_id, "INT UNSIGNED NOT NULL"
      t.column :tax_id, "INT UNSIGNED NOT NULL" 
      t.decimal :tax_rate, precision: 5, scale: 2, null:false
      t.decimal :amount, precision: 13, scale: 2, null:false
      t.index :po_item_id, name: "fk_inv_po_tax_inv_po_item1_idx"
      t.index :tax_id, name: "fk_inv_po_item_tax_mst_tax1_idx"
      t.timestamps

     end

    add_foreign_key :inv_po_item_tax, :inv_po_item, name: "fk_inv_po_tax_inv_po_item1", column: :po_item_id
    add_foreign_key :inv_po_item_tax, :mst_tax, name: "fk_inv_po_item_tax_mst_tax1", column: :tax_id

  end
end
