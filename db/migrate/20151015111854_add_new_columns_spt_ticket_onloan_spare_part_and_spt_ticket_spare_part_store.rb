class AddNewColumnsSptTicketOnloanSparePartAndSptTicketSparePartStore < ActiveRecord::Migration
  def change
    # add_column :spt_ticket_spare_part_store, :approved_main_inv_product_id, "int(10) UNSIGNED"
    add_column :spt_ticket_spare_part_store, :approved_store_id, "int(10) UNSIGNED"
    add_column :spt_ticket_on_loan_spare_part, :approved_store_id, "int(10) UNSIGNED"
  end
end
