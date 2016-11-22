class AddSptTicketSparePartNonStock < ActiveRecord::Migration
  def change
    add_column :spt_ticket_spare_part_non_stock, :requested_quantity, :decimal, default: 1, null: false, scale: 3, precision: 13, after: :approved_at
    add_column :spt_ticket_spare_part_non_stock, :approved_quantity, :decimal, scale: 3, precision: 13, after: :requested_quantity
  end
end
