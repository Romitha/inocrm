class AddColumnPaymentTermIdToPo < ActiveRecord::Migration
  def change
    remove_column :inv_po, :payment_term

    # add_column :inv_po, :payment_term_id, "INT UNSIGNED NOT NULL"

    # remove_column :inv_po, :payment_term_id

    add_column :inv_po, :payment_term_id, "INT UNSIGNED NOT NULL"
    add_index :inv_po, :payment_term_id, name: "fk_inv_po_mst_spt_payment_term1_idx"
    execute "SET FOREIGN_KEY_CHECKS = 0"
    add_foreign_key :inv_po, :mst_spt_payment_term, name: "fk_inv_po_mst_spt_payment_term", column: :payment_term_id
    execute "SET FOREIGN_KEY_CHECKS = 1"
  end
end