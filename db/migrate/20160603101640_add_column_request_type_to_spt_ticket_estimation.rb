class AddColumnRequestTypeToSptTicketEstimation < ActiveRecord::Migration
  def change
  	add_column :spt_ticket_estimation, :request_type, :string, null: false
  end
end
