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
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
    @problem_category = @ticket.problem_category
    @customer = Customer.find(session[:customer_id])
    @warranty = Warranty.new(product_serial_id: session[:product_id])
    QAndA

    @ge_questions = GeQAndA.where(action_id: 1)
    if params[:function_param] == "display_form"
      @display_form = true
    elsif params[:function_param] == "display_form_for_pop"
      @display_form_for_pop = true
    elsif params[:function_param] == "select_for_pop"
      @select_for_pop = true
    end
    @product = Product.find((session[:product_id] or params[:product_id]))
    @warranties = @product.warranties
  end

  def create
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
    @customer = Customer.find(session[:customer_id])
    @product = Product.find(session[:product_id])
    @warranties = @product.warranties
    @ge_questions = GeQAndA.where(action_id: 1)
    ContactNumber
    QAndA
    if params[:warranty_id]
      @warranty = Warranty.find(params[:warranty_id])
    else
      @warranty = Warranty.new warranty_params
      if @warranty.save
        Rails.cache.write([:created_warranty, request.remote_ip.to_s, session[:time_now]], @warranty)
        @problem_category = @ticket.problem_category
        @ticket.warranty_type_id = @warranty.warranty_type.id
        Rails.cache.write([:new_ticket, request.remote_ip.to_s, session[:time_now]], @ticket)

        @select_for_pop = true if params[:function_param] == 'select_for_pop'

      else
        if params[:function_param] == 'select_for_pop'
          @display_form_for_pop = true
        else
          @display_form = true
        end
      end
    end
    render :new

  end

  def select_for_warranty
    @product = Product.find session[:product_id]
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])

    if params[:warranty_id]
      @warranty = Warranty.find params[:warranty_id]
      @warranty.update_attribute(:product_serial_id, @product.id)
      @ticket.warranty_type_id = @warranty.warranty_type.id
      session[:warranty_id] = @warranty.id
    end
    Rails.cache.write([:new_ticket, request.remote_ip.to_s, session[:time_now]], @ticket)
    @problem_category = @ticket.problem_category

    render "tickets/remarks"
    # render "q_and_as/q_and_answer_record"
  end

  def destroy
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
    @customer = Customer.find(session[:customer_id])
    @product = Product.find(session[:product_id])
    @ge_questions = GeQAndA.where(action_id: 1)
    @warranties = @product.warranties
    ContactNumber

    @warranty = Warranty.find(params[:id])

    if @warranty.destroy
      Rails.cache.delete([:created_warranty, request.remote_ip.to_s, session[:time_now]])

      if params[:function_param] == "select_for_pop"
        @select_for_pop = true
      else
        @nothing = true
      end

      render :new
    end
  end

  private
    def warranty_params
      params.require(:warranty).permit(:start_at, :end_at, :product_serial_id, :warranty_type_id, :period_part, :period_labour, :period_onsight, :care_pack_product_no, :care_pack_reg_no, :note)
    end
end
