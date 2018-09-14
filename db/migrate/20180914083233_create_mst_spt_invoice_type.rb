class CreateMstSptInvoiceType < ActiveRecord::Migration
  def change
    create_table :mst_spt_invoice_type, id: false do |t|

      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.string :code, null: false, limit:200
      t.string :name, null: false, limit:200
      t.string :print_name, null: false, limit:200
      t.column :active, :boolean, null: false, default: true
      t.timestamps

    end
  end
end