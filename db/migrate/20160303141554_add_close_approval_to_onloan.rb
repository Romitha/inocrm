class AddCloseApprovalToOnloan < ActiveRecord::Migration
  def change
  	add_column :spt_ticket_on_loan_spare_part, :close_approved, :boolean
  	add_column :spt_ticket_on_loan_spare_part, :close_approved_action_id, "INT UNSIGNED NULL"
  end
end
