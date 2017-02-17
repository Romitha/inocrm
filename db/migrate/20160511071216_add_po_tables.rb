class AddPoTables < ActiveRecord::Migration
  def change

    create_table :inv_po, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :supplier_id, "INT UNSIGNED NOT NULL"
      t.column :store_id, "INT UNSIGNED NOT NULL"
      t.column :currency_id, "INT UNSIGNED NOT NULL"
      t.column :created_by, "INT UNSIGNED NOT NULL"
      t.column :approved_by, "INT UNSIGNED NULL"

      t.datetime :delivery_date
      t.datetime :approved_at

      t.string :po_no, null: false
      t.string :your_ref

      t.text :payment_term
      t.text :deliver_to
      t.text :remarks

      t.boolean :closed, null: false, default: false

      t.decimal :discount_amount, null: false, default: 0, scale: 2, precision: 13

      t.index :store_id, name: "fk_inv_po_organzation1"
      t.index :created_by, name: "fk_inv_po_users1"
      t.index :supplier_id, name: "fk_inv_po_organzations1_idx"
      t.index :currency_id, name: "fk_inv_po_mst_currency1_idx"
      t.index :approved_by, name: "fk_inv_po_users2_idx"

      t.timestamps
      
    end

    create_table :inv_po_item, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :po_id, "INT UNSIGNED NOT NULL"
      t.column :prn_item_id, "INT UNSIGNED NOT NULL"
      t.column :unit_id, "INT UNSIGNED NOT NULL"

      t.decimal :quantity, null: false, default: 0, scale: 2, precision: 13
      t.decimal :unit_cost_grn, null: false, scale: 2, precision: 13
      t.decimal :unit_cost, null: false, scale: 2, precision: 13

      t.text :remarks

      t.boolean :closed, null: false, default: false

      t.index :prn_item_id, name: "fk_inv_po_item_inv_prn_item1_idx"
      t.index :unit_id, name: "fk_inv_po_item_mst_inv_unit1_idx"
      t.index :po_id, name: "fk_inv_po_item_inv_po1_idx"

      t.timestamps
      
    end

    create_table :inv_po_tax, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"

      t.column :po_id, "INT UNSIGNED NOT NULL"

      t.string :tax, null: false

      t.decimal :amount, null: false

      t.index :po_id, name: "fk_inv_po_tax_inv_po1_idx"

      t.timestamps
    end

    remove_column :inv_grn_item, :po_unit_quantity
    remove_column :inv_grn_item, :po_unit_cost

    add_index :inv_grn, :po_id, name: "fk_inv_grn_inv_po1_idx"
    add_index :inv_grn_item, :po_item_id, name: "fk_inv_grn_item_inv_po_item1_idx"

    [
      { table: :inv_po, reference_table: :organizations, name: "fk_inv_po_organzation1x", column: :store_id },
      { table: :inv_po, reference_table: :users, name: "fk_inv_po_users1x", column: :created_by },
      { table: :inv_po, reference_table: :organizations, name: "fk_inv_po_organzations1", column: :supplier_id },
      { table: :inv_po, reference_table: :mst_currency, name: "fk_inv_po_mst_currency1", column: :currency_id },
      { table: :inv_po, reference_table: :users, name: "fk_inv_po_users2", column: :approved_by },
      { table: :inv_po_item, reference_table: :inv_prn_item, name: "fk_inv_po_item_inv_prn_item1", column: :prn_item_id },
      { table: :inv_po_item, reference_table: :mst_inv_unit, name: "fk_inv_po_item_mst_inv_unit1", column: :unit_id },
      { table: :inv_po_item, reference_table: :inv_po, name: "fk_inv_po_item_inv_po1", column: :po_id },
      { table: :inv_po_tax, reference_table: :inv_po, name: "fk_inv_po_tax_inv_po1", column: :po_id },
      { table: :inv_grn, reference_table: :inv_po, name: "fk_inv_grn_inv_po1", column: :po_id },
      { table: :inv_grn_item, reference_table: :inv_po_item, name: "fk_inv_grn_item_inv_po_item1", column: :po_item_id },
    ]
    .each do |f|
      add_foreign_key f[:table], f[:reference_table], name: f[:name], column: f[:column]
    end

    drop_table :inv_prn_grn_item

  end
end