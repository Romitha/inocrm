module Admins
  class TicketsController < ApplicationController
    layout "admins"

    def index
      Ticket
      @ticket_statuses = TicketStatus.all
    end
  end
end