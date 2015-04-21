class WarrantiesController < ApplicationController
  before_action :authenticate_user!

  # before_action :set_warranty, only: [:]

  def index
    @product = Product.find(session[:product_id])
    Warranty
    # @warranties = params[:search_warranties].present? ? WarrantyType.find(params[:search_warranties]).warranties : []
    @warranties = @product.warranties
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
    @ticket.update_attribute(:warranty_type_id, @warranty.warranty_type.id)
    # @ticket.warranty_type_id = @warranty.warranty_type_id
  end

  def select_for_warranty
    @warranty = Warranty.find params[:warranty_id]
    @ticket = Ticket.find session[:ticket_id]
    @product = Product.find session[:product_id]

    @warranty.update_attribute(:product_serial_id, @product.id)
    @ticket.update_attribute(:warranty_type_id, @warranty.warranty_type.id)
    session[:warranty_id] = @warranty.id

    render "tickets/remarks"
  end

  private
    def warranty_params
      params.require(:warranty).permit(:start_at, :end_at, :product_serial_id, :warranty_type_id, :period_part, :period_labour, :corporate_onsight, :care_pack_product_no, :care_pack_reg_no, :note)
    end
end
