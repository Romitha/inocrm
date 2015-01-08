class AgentTicketInfo < ActiveRecord::Base
  belongs_to :agent, class_name: "User"
  belongs_to :ticket
end
