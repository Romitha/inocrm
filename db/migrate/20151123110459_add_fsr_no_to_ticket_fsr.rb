class AddFsrNoToTicketFsr < ActiveRecord::Migration
  def change
    add_column :spt_ticket_fsr, :ticket_fsr_no, "INT(10) UNSIGNED NOT NULL"
  end
end
