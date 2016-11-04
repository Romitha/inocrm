class AddTicketLoggedAtToSptTicket < ActiveRecord::Migration
  def change
    execute "ALTER TABLE spt_ticket ADD logged_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP"
    add_column :spt_ticket, :logged_by, "INT(10) UNSIGNED NOT NULL"
    add_index :spt_ticket, :logged_by, name: "spt_ticket_logged_by_user_index_idx"
    add_column :spt_ticket, :updated_by, "INT(10) UNSIGNED"
    add_index :spt_ticket, :ticket_updated_by, name: "spt_ticket_updated_by_user_index_idx"

    execute "SET FOREIGN_KEY_CHECKS = 0"
    add_foreign_key :spt_ticket, :users, name: "spt_ticket_logged_by_user_foreign_id", column: :logged_by
    add_foreign_key :spt_ticket, :users, name: "spt_ticket_updated_by_user_foreign_id", column: :ticket_updated_by
    execute "SET FOREIGN_KEY_CHECKS = 1"

  end
end