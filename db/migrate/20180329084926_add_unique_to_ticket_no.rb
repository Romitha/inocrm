class AddUniqueToTicketNo < ActiveRecord::Migration
  def change
  	add_index :spt_ticket, :ticket_no, unique: true, name: 'unique_ticket_no'
  end
end
