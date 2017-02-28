class AddMorePoColumns < ActiveRecord::Migration
  def change
  	add_column :inv_po, :delivery_date_text, :string
  	add_column :inv_po, :quotation_no, :string
  	add_column :inv_po, :delivery_mode, :string
  end
end
