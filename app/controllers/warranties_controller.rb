class WarrantiesController < ApplicationController
  # before_action :user_session_expired

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
    @ticket = Rails.cache.read(:new_ticket)
    @problem_category = @ticket.problem_category
    @customer = Customer.find(session[:customer_id])
    @warranty = Warranty.new(product_serial_id: session[:product_id])
    QAndA

    @ge_questions = GeQAndA.where(action_id: 1)
    if params[:function_param] == "display_form"
      @display_form = true
    else
      @product = Product.find(session[:product_id])
      @warranties = @product.warranties
    end
  end

  def create
    @ticket = Rails.cache.read(:new_ticket)
    @customer = Customer.find(session[:customer_id])
    @product = Product.find(session[:product_id])
    @warranties = @product.warranties
    ContactNumber
    if params[:warranty_id]
      @warranty = Warranty.find(params[:warranty_id])
    else
      @warranty = Warranty.new warranty_params
      if @warranty.save
        Rails.cache.write(:created_warranty, @warranty)
        @problem_category = @ticket.problem_category
        @display_form = false
        # render "q_and_as/q_and_answer_record"
      else
        @display_form = true
      end
    end
    @ticket.warranty_type_id = @warranty.warranty_type.id
    Rails.cache.write(:new_ticket, @ticket)
    render :new
    # @ticket.warranty_type_id = @warranty.warranty_type_id
  end

  def select_for_warranty
    @product = Product.find session[:product_id]
    @ticket = Rails.cache.read(:new_ticket)

    if params[:warranty_id]
      @warranty = Warranty.find params[:warranty_id]
      @warranty.update_attribute(:product_serial_id, @product.id)
      @ticket.warranty_type_id = @warranty.warranty_type.id
      session[:warranty_id] = @warranty.id
    end
    Rails.cache.write(:new_ticket, @ticket)
    @problem_category = @ticket.problem_category

    render "tickets/remarks"
    # render "q_and_as/q_and_answer_record"
  end

  def destroy
    @ticket = Rails.cache.read(:new_ticket)
    @customer = Customer.find(session[:customer_id])
    @product = Product.find(session[:product_id])
    @warranties = @product.warranties
    ContactNumber

    @warranty = Warranty.find(params[:id])

    if @warranty.destroy
      Rails.cache.delete(:created_warranty)
      render :new
    end
  end

  private
    def warranty_params
      params.require(:warranty).permit(:start_at, :end_at, :product_serial_id, :warranty_type_id, :period_part, :period_labour, :corporate_onsight, :care_pack_product_no, :care_pack_reg_no, :note)
    end
end
