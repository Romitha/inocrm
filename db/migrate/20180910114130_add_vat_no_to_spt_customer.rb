class AddVatNoToSptCustomer < ActiveRecord::Migration
  def change
    add_column :spt_customer, :vat_no, :string, limit: 100  # "VARCHAR(100) NULL"
    add_column :spt_customer, :svat_no, :string, limit: 100 # "VARCHAR(100) NULL"
  end
end
