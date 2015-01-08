class CreateAgentTicketInfos < ActiveRecord::Migration
  def change
    create_table :agent_ticket_infos do |t|
      t.references :agent, index: true
      t.references :ticket, index: true
      t.string :visibility

      t.timestamps
    end
  end
end
