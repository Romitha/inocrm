class AddMoreColumnsInInventories < ActiveRecord::Migration
  def change
    add_column :inv_srn, :so_no, :string
    add_column :inv_grn, :po_no, :string
    add_column :inv_inventory_serial_part, :added, :boolean, null: false, default: false
    add_column :inv_srn, :so_customer_id, "INT UNSIGNED"

    add_index :inv_srn, :so_customer_id, name: "fk_inv_srn_organzations1_idx"
    add_foreign_key :inv_srn, :organizations, name: "fk_inv_srn_organzations1", column: :so_customer_id

  end
end
