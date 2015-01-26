class AddDueDateTimeToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :due_date_time, :datetime
  end
end
