class AddMoreSopoColumns < ActiveRecord::Migration
  def change
  	add_column :spt_so_po, :invoice_id, "INT UNSIGNED"
    add_index :spt_so_po, :invoice_id, name: "fk_spt_so_po_spt_invoice_id1_idx"
    execute "SET FOREIGN_KEY_CHECKS = 0"
    add_foreign_key :spt_so_po, :spt_invoice, name: "fk_spt_so_po_spt_invoice", column: :invoice_id
    execute "SET FOREIGN_KEY_CHECKS = 1"
  end
end
