class AddTicketLoggedAtToSptTicket < ActiveRecord::Migration
  def change
    # add_column :spt_ticket, :ticket_logged_at, :datetime, null: false, default: `CURRENT_TIMESTAMP`
    execute "ALTER TABLE spt_ticket ADD ticket_logged_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP"
  end
end
