class AddLocationAddressIdToSptTicketProductSerial < ActiveRecord::Migration
  def change
  	add_column :spt_ticket_product_serial, :location_address_id, "INT UNSIGNED NULL"
  	add_index  :spt_ticket_product_serial, :location_address_id, name: "fk_spt_ticket_product_serial_addresses1_idx"
  	add_foreign_key :spt_ticket_product_serial, :addresses, name: "fk_spt_ticket_product_serial_addresses1", column: :location_address_id
  end
end
