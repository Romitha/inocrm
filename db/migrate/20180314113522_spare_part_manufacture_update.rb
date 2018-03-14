class SparePartManufactureUpdate < ActiveRecord::Migration
  def change
	add_column :spt_ticket_spare_part_manufacture, :order_pending, "INT NULL"
  end
end
