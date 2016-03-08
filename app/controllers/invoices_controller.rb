class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @invoices = Invoice.all
    respond_with(@invoices)
  end

  def show
    respond_with(@invoice)
  end

  def new
    @invoice = Invoice.new
    respond_with(@invoice)
  end

  def edit
  end

  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.save
    respond_with(@invoice)
  end

  def update
    @invoice.update(invoice_params)
    respond_with(@invoice)
  end

  def destroy
    @invoice.destroy
    respond_with(@invoice)
  end

  def edit_estimation_ajax
    TicketEstimation

    quotation_id = params[:quotation_id]
    if quotation_id.present?
      @quotation = CustomerQuotation.find quotation_id
    else
      @quotation = CustomerQuotation.new
    end
    @ticket = Ticket.find params[:ticket_id]
    @estimations = @ticket.ticket_estimations.page(params[:page]).per(params[:per_page])
  end

  def edit_invoice_ajax
    invoice_id = params[:invoice_id]
    if invoice_id.present?
      @invoice = TicketInvoice.find invoice_id
    else
      @invoice = TicketInvoice.new
    end
    @ticket = Ticket.find params[:ticket_id]
  end

  def paginate_estimations
    @estimations = @estimations.page(params[:page]).per(params[:per_page])
    render "invoices/paginate_estimations"
  end

  def click_for_receipt
    @ticket = Ticket.find params[:ticket_id]
    @ticket_payment_received = TicketPaymentReceived.find params[:re_id]
    @estimation = TicketEstimation.find params[:estimation_id]
    @continue = false
    render "tickets/tickets_pack/invoice_advance_payment/update_invoice_advance_payment"
  end

  def update_invoice_advance_payment
    Ticket
    Organization
    Invoice
    TaskAction

    # @estimation = TicketEstimation.find params[:advance_payment_estimation_id]
    @ticket = Ticket.find params[:ticket_id]
    @customer_quotation = @ticket.customer_quotations.find params[:advance_payment_estimation_id] if params[:advance_payment_estimation_id].to_i > 0

    @ticket_payment_received = @ticket.ticket_payment_receiveds.build ticket_payment_received_params

    # @ticket_payment_received = @estimation.build_ticket_payment_received ticket_payment_received_params

    @ticket_payment_received.attributes = @ticket_payment_received.attributes.merge received_at: DateTime.now, received_by: current_user.id, type_id: TicketPaymentReceivedType.find_by_code("AD").id, currency_id: @ticket.ticket_currency.id, receipt_no: CompanyConfig.first.increase_sup_last_receipt_no, receipt_print_count: 0, customer_quotation_id: @customer_quotation.try(:id)


    complete_payment_received = params[:invoicing_completed].present?

    continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

    if continue

      if @ticket_payment_received.amount > 0

        if @ticket_payment_received.save

          # 28 - Invoice Advance Payment
          user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(28).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
          user_ticket_action.build_act_payment_received(ticket_payment_received_id: @ticket_payment_received.id, invoice_completed: complete_payment_received)
          user_ticket_action.save

          if complete_payment_received
            responsible_resource = @ticket
            if @customer_quotation
              responsible_resource = @customer_quotation
            end
            responsible_resource.ticket_estimations.where(foc_approved: false, cust_approved: true).update_all status_id: EstimationStatus.find_by_code("CLS").id
          end

        else
          complete_payment_received = false
          flash[:error] = "Sorry! unable to update"
        end
          
        @continue = false
        @render_to_page = "tickets/tickets_pack/invoice_advance_payment/update_invoice_advance_payment"
      else
        @render_to_page = {js: "window.location.href = '#{todos_url}'"}
      end

      if complete_payment_received
        # bpm output variables
        bpm_variables = view_context.initialize_bpm_variables
        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if bpm_response[:status].upcase == "SUCCESS"
          flash[:notice] = "Successfully updated"
        else
          flash[:error] = "invoice is updated. but Bpm error"
        end
      else
        flash[:error] = "Successfully updated, but not completed"
      end

    else
      flash[:error] = "Bpm error. invoice is not updated"
      @render_to_page = {js: "window.location.href = '#{todos_url}'"}

    end

    render @render_to_page #js: "window.location.href = '#{todos_url}'"
  end

  def update_estimate_job_final
    TaskAction

    @ticket = Ticket.find params[:ticket_id]
    @ticket.attributes = ticket_params
    payment_completed = params[:payment_completed].present?

    continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])
    bpm_variables = view_context.initialize_bpm_variables

    if continue

      if ticket.final_amount_to_be_paid.to_f > 0
        @ticket.cus_payment_required = true
        @ticket.save
        d12_need_to_invoice = "Y"
      else
        @ticket.cus_payment_required = false
        @ticket.save
        d12_need_to_invoice = "N"
        payment_completed = true
      end

      if payment_completed
        @ticket.update customer_payment_completed: true
      end

      # 63 - Estimate Job Final
      user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(63).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
      user_ticket_action.save

        # bpm output variables
      bpm_variables.merge! d12_need_to_invoice: d12_need_to_invoice
      bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

      if bpm_response[:status].upcase == "SUCCESS"
        flash[:notice] = "Successfully updated"
      else
        flash[:error] = "invoice is updated. but Bpm error"
      end

    else
      flash[:error] = "Bpm error."
    end
  end

  def update_quality_control
    TaskAction
    update_ticket_params = ticket_params
    @ticket = Ticket.find params[:ticket_id]
    continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

    if continue
      # bpm output variables
      bpm_variables = view_context.initialize_bpm_variables.merge supp_engr_user: params[:supp_engr_user]

      if params[:approve] #Approve QC

        bpm_variables.merge! d37_qc_passed: "Y"

        update_ticket_params.merge! status_id: TicketStatus.find_by_code("PMT").id, qc_passed: true
        unless @ticket.cus_chargeable or @ticket.cus_payment_required or @ticket.ticket_terminated
          update_ticket_params.merge! status_id: TicketStatus.find_by_code("CFB").id
        end


      elsif params[:reject] #Reject QC

        bpm_variables.merge! d38_ticket_close_approved: "Y" unless @ticket.ticket_close_approved or !@ticket.ticket_close_approval_required
        # bpm_variables.merge! d38_ticket_close_approved: (@ticket.ticket_close_approved and @ticket.ticket_close_approval_required) or !(@ticket.ticket_close_approval_required) ? "N" : "Y"

        @ticket.update qc_passed: false, status_id: TicketStatus.find_by_code("ROP").id, re_open_count: (@ticket.re_open_count.to_i+1), job_finished: false, ticket_close_approval_required: true, ticket_close_approval_requested: false, ticket_close_approved: false

      end
      @ticket.update update_ticket_params

      bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

      if bpm_response[:status].upcase == "SUCCESS"
        flash[:notice] = "Successfully updated"
      else
        flash[:error] = "invoice is updated. but Bpm error"
      end
    else
      flash[:error] = "Bpm error."
    end

    redirect_to todos_url
  end

  def update_customer_feedback
    
    # Set 
    # move_to_next_task = true  
    # If "Re-Open" is checked then 
    #   (D39) d39_re_open = true
    #   DB.spt_ticket.status_id=  ROP (Re-Open)
    #   DB.spt_ticket.re-open_count = DB.spt_ticket.re-open_count + 1
    #   DB.spt_ticket.job_finished=false 
    #   if (DB.spt_ticket.ticket_close_approval_required = true and DB.spt_ticket.ticket_close_approved = true ) then 
    #     (D38) d38_ticket_close_approved = true 
    #     alert_re-open_info (SPT_ALT_7) 
    #     DB.spt_ticket.ticket_close_approval_required = 1  
    #     DB.spt_ticket.ticket_close_approval_requested = 0 
    #     DB.spt_ticket.ticket_close_approved = 0 
    #   end
    # else # If "Re-Open" is not checked then 
    #   #DB.spt_ticket.customer_payment_completed=true  and 
    #   if DB.spt_ticket.ticket_close_approval_required =  true Then 
    #     DB.spt_ticket.status_id = TBC (To Be Closed) 
    #   else 
    #     DB.spt_ticket.status_id= CLS (Closed)
    #   end  
    #   if DB.spt_ticket.cus_payment_required = true then
    #     if final_amount_to_be_paid > 0 then
    #         if ("Recieved Amount" > 0) then  
    #           Create DB.spt_ticket_payment_received
    #           Set Action (28) Invoice Advance Payment, DB.spt_act_payment_received.
    #           If ("Payment Completed" is checked) then 
    #             DB.spt_ticket.customer_payment_completed=true.
    #             DB.spt_ticket_payment_received.type_id = mst_spt_payment_received_type(code: "FN").id
    #           else
    #             DB.spt_ticket_payment_received.type_id = mst_spt_payment_received_type(code: "AD").id
    #             move_to_next_task = false
    #           end 
    #         end    
    #     else
    #       DB.spt_ticket.customer_payment_completed=true. 
    #     end      
    #   end      
    # end        
    # Set Action (58) Customer Feedback, DB.spt_act_customer_feedback. 



    @ticket = Ticket.find_by_id params[:ticket_id]
    re_open = params[:re_open].present?
    payment_completed = params[:payment_completed].present?

    @ticket_payment_received = TicketPaymentReceived.new ticket_payment_received_params
    @final_invoice = @ticket.ticket_invoices.order(created_at: :desc).find_by_canceled false

    continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

    if continue
        d39_re_open = "N"
        d38_ticket_close_approved = "N"
        move_to_next_task = true  
        @render_to_page = {js: "window.location.href = '#{todos_url}'"}
        if re_open then # If "Re-Open" is checked
          d39_re_open = "Y"

          if (@ticket.ticket_close_approval_required and @ticket.ticket_close_approved ) 
            d38_ticket_close_approved = "Y"
            @ticket.update ticket_close_approval_requested: false, ticket_close_approved: false
          end  

          @ticket.update status_id: TicketStatus.find_by_code("ROP").id, re_open_count: (@ticket.re_open_count.to_i+1), job_finished: false

        else # If "Re-Open" is not checked
          if @ticket.ticket_close_approval_required 
            @ticket.update status_id: TicketStatus.find_by_code("TBC").id #(To Be Closed) 
          else 
            @ticket.update status_id: TicketStatus.find_by_code("CLS").id #(Closed)
          end  
          if @ticket.cus_payment_required
            if @ticket.final_amount_to_be_paid.to_f > 0
                if @ticket_payment_received > 0

                  if payment_completed
                    @ticket.update customer_payment_completed = true
                    @ticket_payment_received.attributes = @ticket_payment_received.attributes.merge type_id: TicketPaymentReceivedType.find_by_code("FN").id
                  else
                    move_to_next_task = false
                    @ticket_payment_received.attributes = @ticket_payment_received.attributes.merge type_id: TicketPaymentReceivedType.find_by_code("AD").id
                  end                   

                  @ticket_payment_received.attributes = @ticket_payment_received.attributes.merge received_at: DateTime.now, received_by: current_user.id, currency_id: @ticket.ticket_currency.id, receipt_no: CompanyConfig.first.increase_sup_last_receipt_no, receipt_print_count: 0, invoice_id: @final_invoice.try(:id)

                  @ticket_payment_received.save

                  # 28 - Invoice Advance Payment
                  user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(28).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
                  user_ticket_action.build_act_payment_received(ticket_payment_received_id: @ticket_payment_received.id, invoice_completed: payment_completed)
                  user_ticket_action.save
                end 
            else
              @ticket.update customer_payment_completed = true 
            end  
            
            @continue = false
            @render_to_page = "tickets/tickets_pack/invoice_advance_payment/update_invoice_advance_payment"    
          end      
        end        
        # Action (58) Customer Feedback, DB.spt_act_customer_feedback.
        user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(58).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
        user_ticket_action.build_act_customer_feedback(ticket_payment_received_id: @ticket_payment_received.id, invoice_completed: payment_completed)
        user_ticket_action.save

        # bpm output variables
        bpm_variables = view_context.initialize_bpm_variables.merge d39_re_open: d39_re_open, d38_ticket_close_approved: d38_ticket_close_approved, supp_engr_user: params[:supp_engr_user]

        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if bpm_response[:status].upcase == "SUCCESS"
          flash[:notice] = "Successfully updated"
        else
          flash[:error] = "invoice is updated. but Bpm error"
        end

    else
      flash[:error] = "Bpm error."
    end

    render @render_to_page #js: "window.location.href = '#{todos_url}'"
  end

  private
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    def estimation_params
      estimation_params = params.require(:ticket_estimation).permit(:note, :id, :cust_approved, :cust_approved_by, :advance_payment_amount, :current_user_id, :approved_adv_pmnt_amount, ticket_estimation_parts_attributes: [:id, :supplier_id, :cost_price, :estimated_price, :warranty_period, :approved_estimated_price, ticket_spare_part_attributes: [:note, :id, :current_user_id]], ticket_estimation_additionals_attributes: [:id, :_destroy, :ticket_id, :additional_charge_id, :cost_price, :estimated_price, :approved_estimated_price])

      estimation_params[:current_user_id] = current_user.id
      estimation_params
    end

    def ticket_payment_received_params
      params.require(:ticket_payment_received).permit(:amount, :note, :receipt_no, :payment_type, :payment_note, :receipt_description, customer_feedbacks_attributes: [:id, :re_opened, :unit_return_customer, :feedback_id, :feedback_description])
    end

    def ticket_params
      ticket_params = params.require(:ticket).permit(:id, :remarks, :final_amount_to_be_paid, user_ticket_actions_attributes: [:id, :_destroy, :action_at, :action_id, :action_by, :re_open_index, act_quality_control_attributes: [:approved, :reject_reason]], ge_q_and_answers_attributes: [:id, :general_question_id, :ticket_action_id, :answer], q_and_answers_attributes: [:id, :problematic_question_id, :ticket_action_id, :answer])
      ticket_params[:current_user_id] = current_user.id
      ticket_params
    end
end
