class AddColumnsToTicketOnloanSparePart < ActiveRecord::Migration
  def change
    add_column :spt_ticket_on_loan_spare_part, :received_part_serial_no, :string
    add_column :spt_ticket_on_loan_spare_part, :received_part_ct_no, :string
  end
end
