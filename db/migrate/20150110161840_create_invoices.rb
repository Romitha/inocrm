class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.integer :invoice_number
      t.integer :paid
      t.integer :total
      t.integer :balance
      t.date :date
      t.date :due_date
      t.string :invoice_type

      #t.references :customer, index: true
      t.column :customer_id, "int(10) UNSIGNED"
      #t.string :customer_type
      t.timestamps
    end
  end
end
