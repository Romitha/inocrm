class SetUniqueToSerialNo < ActiveRecord::Migration
  def change
    add_index :spt_product_serial, :serial_no, unique: true, name: 'serial_no_to_product'
  end
end
