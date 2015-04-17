class WarrantiesController < ApplicationController
  before_action :authenticate_user!

  # before_action :set_warranty, only: [:]

  def index
    Warranty
    @warranties = params[:search_warranties].present? ? WarrantyType.find(params[:search_warranties]).warranties : []
  end

  def new
    session[:warranty_id] = nil
    ContactNumber
    @ticket = Ticket.find(session[:ticket_id])
    @customer = Customer.find(session[:customer_id])
    @warranty = Warranty.new(product_serial_id: session[:product_id])
    @display_form = true if params[:function_param] == "display_form"
  end

  def create
    @ticket = Ticket.find(session[:ticket_id])
    if params[:warranty_id]
      @warranty = Warranty.find(params[:warranty_id])
    else
      @warranty = Warranty.new warranty_params
      if @warranty.save
        session[:warranty_id] = @warranty.id
        render "tickets/remarks"
      else
        @display_form = true
        @customer = Customer.find(session[:customer_id])
        render :new
      end
    end
    @ticket.warranty_type_id = @warranty.warranty_type_id
  end

  private
    def warranty_params
      params.require(:warranty).permit(:start_at, :end_at, :product_serial_id, :warranty_type_id, :period_part, :period_labour, :corporate_onsight, :care_pack_product_no, :care_pack_reg_no, :note)
    end
end
