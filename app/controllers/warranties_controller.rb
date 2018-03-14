class WarrantiesController < ApplicationController
  # before_action :user_session_expired

  # before_action :set_warranty, only: [:]

  def index
    @product = Product.find((params[:product_id] or session[:product_id]))
    Warranty
    # @warranties = params[:search_warranties].present? ? WarrantyType.find(params[:search_warranties]).warranties : []
    @warranties = @product.warranties
  end

  def new
    ContactNumber
    QAndA
    @ticket_time_now = params[:ticket_time_now]
    session[:warranty_id] = nil
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])
    @problem_category = @ticket.try :problem_category
    @customer = Customer.find_by_id(session[:customer_id])
    @warranty = Warranty.new(product_serial_id: (params[:product_id] or session[:product_id]))
    QAndA

    @ge_questions = GeQAndA.actives.where(action_id: 1)
    if params[:function_param] == "display_form"
      @display_form = true
    elsif params[:function_param] == "display_form_for_pop"
      @display_form_for_pop = true
    elsif params[:function_param] == "select_for_pop"
      @select_for_pop = true
    end
    @product = Product.find((params[:product_id] or session[:product_id]))
    @warranties = @product.warranties
  end

  def create
    ContactNumber
    QAndA
    @ticket_time_now = params[:ticket_time_now]

    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])
    @customer = Customer.find_by_id(session[:customer_id])
    @product = Product.find((params[:product_id] or session[:product_id]))
    @warranties = @product.warranties
    @ge_questions = GeQAndA.actives.where(action_id: 1)
    if params[:warranty_id]
      @warranty = Warranty.find(params[:warranty_id])
    else
      @warranty = Warranty.new warranty_params
      if @warranty.save
        Rails.cache.write([:created_warranty, request.remote_ip.to_s, @ticket_time_now], @warranty)
        @problem_category = @ticket.try :problem_category
        # @ticket.warranty_type_id = @warranty.warranty_type.id
        Rails.cache.write([:new_ticket, request.remote_ip.to_s, @ticket_time_now], @ticket)

        @select_for_pop = true if params[:function_param] == 'select_for_pop'
        @flash_message = {notice: "Successfully updated"}
      else
        if params[:function_param] == 'select_for_pop'
          @display_form_for_pop = true
        else
          @display_form = true
        end
        @flash_message = {alert: "Unable to updated"}
      end
    end
    if request.xhr?
      render :new
    else
      redirect_to todos_url, @flash_message
    end

  end

  def select_for_warranty
    @product = Product.find (params[:product_id] or session[:product_id])
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
    ContactNumber
    QAndA
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
    @customer = Customer.find_by_id(session[:customer_id])
    @product = Product.find_by_id((params[:product_id] or session[:product_id]))
    @ge_questions = GeQAndA.actives.where(action_id: 1)
    @warranties = @product.warranties

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

  def extend_warranty_update_extend_warranty
    Ticket
    @warranty = Warranty.new warranty_params
    @ticket = Ticket.find params[:ticket_id]

    continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

    if continue and @warranty.save

      # Set Action (39) "Warranty Extended". DB.spt_act_warranty_extend
      user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(39).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
      user_ticket_action.build_action_warranty_extend(extended: true)
      user_ticket_action.save

      # bpm output variables
      bpm_variables = view_context.initialize_bpm_variables

      @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

      bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

      if bpm_response[:status].upcase == "SUCCESS"
        @flash_message = {notice: "Successfully updated"}
      else
        @flash_message = {alert: "warranty is updated. but Bpm error"}
      end
    else
      @flash_message = {alert: "Unable to update, errors: #{@warranty.errors.present? and @warranty.errors.full_messages.join(', ')}"}
    end
    redirect_to todos_url, @flash_message
  end

  private
    def warranty_params
      params.require(:warranty).permit(:start_at, :end_at, :product_serial_id, :warranty_type_id, :period_part, :period_labour, :period_onsight, :care_pack_product_no, :care_pack_reg_no, :note)
    end
end
