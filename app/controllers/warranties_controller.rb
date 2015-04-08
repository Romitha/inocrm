class WarrantiesController < ApplicationController
  before_action :authenticate_user!

  # before_action :set_warranty, only: [:]

  def new
    @ticket = Ticket.find(session[:ticket_id])
    @customer = Customer.find(session[:customer_id])
    @warranty = Warranty.new
  end

  def create
    @warranty = Warranty.new warranty_params
  end

  private
    def warranty_params
      params.require(:warranty).permit(:start_at, :end_at)
    end
end
