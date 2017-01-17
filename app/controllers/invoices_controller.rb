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

  def edit_quotation_ajax
    @ticket = Ticket.find params[:ticket_id]
    TicketEstimation
    Tax
    @action_type = params[:action_type]
    quotation_id = params[:quotation_id]
    if quotation_id.present?
      @quotation = CustomerQuotation.find quotation_id
      @estimations = (@ticket.ticket_estimations.where(status_id: EstimationStatus.find_by_code("EST").id) + @quotation.ticket_estimations).uniq{ |q| q.id }
    else
      @quotation = CustomerQuotation.new
      @estimations = @ticket.ticket_estimations.where(status_id: EstimationStatus.find_by_code("EST").id)
    end
  end

  def edit_invoice_ajax
    Invoice
    TaskAction
    Organization
    @ticket = Ticket.find params[:ticket_id]
    @action_type = params[:action_type]
    invoice_id = params[:invoice_id]
    if invoice_id.present?
      @invoice = TicketInvoice.find invoice_id
      @estimations = @ticket.ticket_estimations.where(cust_approved: true)
    else
      @invoice = TicketInvoice.new
      @estimations = (@ticket.ticket_estimations.where(cust_approved: true) + @invoice.ticket_estimations).uniq{ |q| q.id }
    end
    @ticket_payment_receiveds = @ticket.ticket_payment_receiveds
    @act_terminate_job_payments = @ticket.act_terminate_job_payments
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

    out_from_bpm = params[:check_payment].present?

    @ticket = Ticket.find params[:ticket_id]
    @customer_quotation = @ticket.customer_quotations.find params[:advance_payment_estimation_id] if params[:advance_payment_estimation_id].to_i > 0

    @ticket_payment_received = @ticket.ticket_payment_receiveds.build ticket_payment_received_params

    @ticket_payment_received.attributes = @ticket_payment_received.attributes.merge received_at: DateTime.now, received_by: current_user.id, type_id: TicketPaymentReceivedType.find_by_code("AD").id, currency_id: @ticket.ticket_currency.id, receipt_no: CompanyConfig.first.increase_sup_last_receipt_no, receipt_print_count: 0, customer_quotation_id: @customer_quotation.try(:id)


    complete_payment_received = params[:invoicing_completed].present?

    continue = if out_from_bpm
      true
    else
      view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])
    end

    if continue

      if @ticket_payment_received.amount > 0

        if @ticket_payment_received.save

          if @ticket.final_amount_to_be_paid.to_f > 0
            @ticket.decrement! :final_amount_to_be_paid, @ticket_payment_received.amount 
            @ticket.update cus_payment_completed: true if @ticket.final_amount_to_be_paid.to_f <= 0
          end

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

      if complete_payment_received and not out_from_bpm
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
    Invoice

    updated_only = params[:update_only].present?

    @ticket = Ticket.find params[:ticket_id]
    @ticket.attributes = ticket_params
    payment_completed = params[:payment_completed].present?

    foc_payment_required = (params[:foc_payment_required].present? and params[:foc_payment_required].to_bool)
    act_terminate_job = @ticket.user_ticket_actions.map{|u| u.ticket_terminate_job if u.ticket_terminate_job.present? }.compact.first

    act_terminate_job.try(:update, {foc_requested: foc_payment_required})

    continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])
    bpm_variables = view_context.initialize_bpm_variables

    create_invoice = !@ticket.ticket_invoices.any? { |i| !i.canceled }
    invoice = @ticket.ticket_invoices.find_by_canceled(false)
    invoiced_payment_recives = (invoice and invoice.ticket_payment_received_ids)
    uninvoiced_items =  @ticket.ticket_estimations.any? { |i| i.invoiced.to_i<= 0 and i.approved} or @ticket.act_terminate_job_payments.any? { |i| i.invoiced.to_i<= 0 } or (@ticket.ticket_payment_received_ids != invoiced_payment_recives.to_a) #@ticket.ticket_payment_receiveds.any? { |i| !i.invoiced.to_i <= 0 }
    @ticket.final_invoice_id = invoice.try(:id)

    new_act_terminate_job_payments = @ticket.act_terminate_job_payments.select{|a| a.id.nil?}

    if create_invoice and !updated_only # or uninvoiced_items
      if create_invoice
        flash[:error] = "Please continue after creating invoice."
        redirect_to todos_url and return

      end
      if uninvoiced_items
        flash[:error] = "There are un-invoiced items, Please continue after creating invoice with all items."
        redirect_to todos_url and return

      end
    else
      if continue
        @ticket.cus_payment_required = true

        d12_need_to_invoice = foc_payment_required ? "N" : "Y"

        if !updated_only
          # 63 - Estimate Job Final
          user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(63).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
          user_ticket_action.save

          @ticket.status_id = TicketStatus.find_by_code("CFB").id

            # bpm output variables
          bpm_variables.merge! d12_need_to_invoice: d12_need_to_invoice
          bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          if bpm_response[:status].upcase == "SUCCESS"
            flash[:notice] = "Successfully updated"
          else
            flash[:error] = "invoice is updated. but Bpm error"
          end
        else
          # 85 - Estimate Job Final update
          user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(85).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
          user_ticket_action.save

          flash[:notice] = "Successfully updated"
        end
        new_act_terminate_job_payments.each { |a| a.ticket_action_id = user_ticket_action.id }
        @ticket.save

      else
        flash[:error] = "Bpm error."
      end
    end
    redirect_to todos_url
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

        bpm_variables.merge! d38_ticket_close_approved: ( !@ticket.ticket_close_approval_required or @ticket.ticket_close_approval_requested or @ticket.ticket_close_approved) ? "N" : "Y"

        @ticket.update qc_passed: false, status_id: TicketStatus.find_by_code("ROP").id, re_open_count: (@ticket.re_open_count.to_i+1), job_finished: false, job_finished_at: nil, ticket_close_approval_required: true, ticket_close_approval_requested: false, ticket_close_approved: false

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
    @ticket = Ticket.find params[:ticket_id]
    editable_ticket_params = {}
    re_open = params[:re_opened].present?
    customer_feedback_payment_completed = params[:payment_completed].present?
    customer_feedback_unit_return_customer = params[:unit_return_customer].present?
    customer_feedback_feedback_id = params[:feedback_id]
    customer_feedback_dispatch_method_id = params[:dispatch_method_id]
    customer_feedback_re_opened = params[:re_opened].present?
    customer_feedback_feedback_description = params[:feedback_description]

    @ticket_payment_received = TicketPaymentReceived.new ticket_payment_received_params if @ticket.cus_payment_required
    #@final_invoice = @ticket.ticket_invoices.order(created_at: :desc).find_by_canceled false
    @final_invoice = @ticket.final_invoice

    continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

    if continue
      d39_re_open = "N"
      d38_ticket_close_approved = "Y" #Not create Engineer task
      if re_open
        d39_re_open = "Y"

        if !@ticket.ticket_close_approval_required or @ticket.ticket_close_approval_requested or @ticket.ticket_close_approved
          d38_ticket_close_approved = "N" #Create Engineer task
          editable_ticket_params.merge! ticket_close_approval_requested: false, ticket_close_approved: false
        end
        editable_ticket_params.merge! re_open_count: (@ticket.re_open_count.to_i+1), job_finished: false, job_finished_at: nil, status_id: TicketStatus.find_by_code("ROP").id, cus_payment_completed: false

      else

        if @ticket.cus_payment_required
          if @ticket.final_amount_to_be_paid.to_f > 0
            if @ticket_payment_received.amount.to_f > 0

              if customer_feedback_payment_completed
                editable_ticket_params.merge! cus_payment_completed: true

                @ticket_payment_received.type_id = TicketPaymentReceivedType.find_by_code("FN").id
              else

                @ticket_payment_received.type_id = TicketPaymentReceivedType.find_by_code("AD").id
              end

              @ticket_payment_received.attributes = @ticket_payment_received.attributes.merge ticket_id: @ticket.id, received_at: DateTime.now, received_by: current_user.id, currency_id: @ticket.ticket_currency.id, receipt_no: CompanyConfig.first.increase_sup_last_receipt_no, receipt_print_count: 0, invoice_id: @final_invoice.try(:id)

              @ticket_payment_received.save

              @ticket.decrement! :final_amount_to_be_paid, @ticket_payment_received.amount if @ticket.final_amount_to_be_paid.to_f > 0

              # 28 - Receive Payment
              user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(28).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
              user_ticket_action.build_act_payment_received(ticket_payment_received_id: @ticket_payment_received.id, invoice_completed: customer_feedback_payment_completed)
              user_ticket_action.save
            end
          else
            editable_ticket_params.merge! cus_payment_completed: true
          end

        end

        editable_ticket_params.merge! job_closed: true, job_closed_at: DateTime.now

        editable_ticket_params.merge! status_id: TicketStatus.find_by_code("TBC").id #(To Be Closed)
        @continue = true

      end
      @ticket.update editable_ticket_params if editable_ticket_params.present?
      @ticket.set_ticket_close(current_user.id) unless re_open

      if @ticket.ticket_terminated
        # Action:(60)Terminate Job Customer Feedback, DB.spt_act_customer_feedback.
        action_no = 60
      else  
        # Action (58) Customer Feedback, DB.spt_act_customer_feedback.
        action_no = 58
      end
      user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(action_no).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
      user_ticket_action.build_customer_feedback(re_opened: customer_feedback_re_opened, unit_return_customer: customer_feedback_unit_return_customer, payment_received_id: @ticket_payment_received.try(:id), payment_completed: customer_feedback_payment_completed, feedback_id: customer_feedback_feedback_id, feedback_description: customer_feedback_feedback_description, created_at: DateTime.now, updated_at: current_user.id, dispatch_method_id: customer_feedback_dispatch_method_id, ticket_terminated: @ticket.ticket_terminated)
      user_ticket_action.save

      # bpm output variables
      bpm_variables = view_context.initialize_bpm_variables.merge d39_re_open: d39_re_open, d38_ticket_close_approved: d38_ticket_close_approved, supp_engr_user: params[:supp_engr_user]

      bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

      if bpm_response[:status].upcase == "SUCCESS"
        flash[:notice] = "Successfully updated"
        Rails.cache.delete(["/tickets/customer_feedback", params[:task_id]]) unless request.xhr?
      else
        flash[:error] = "Ticket is updated. but Bpm error"
        @continue = false
      end

    else
      flash[:error] = "Bpm error."
      @continue = false

    end
    if @continue
      @render_to_page = "tickets/tickets_pack/customer_feedback/update_customer_feedback"

    else
      @render_to_page = {js: "window.location.href = '#{todos_url}'"}

    end
    render @render_to_page
  end

  def update_quotation
    @ticket = Ticket.find_by_id params[:ticket_id]
    checked_estimation_ids = params[:estimation_ids]
    checked_estimations = TicketEstimation.where id: checked_estimation_ids
    engineer_id = params[:engineer_id]
    action_no = 0
    if params[:action_type] == "create"
      @customer_quotation = CustomerQuotation.new customer_quotation_params
      @customer_quotation.customer_quotation_no = CompanyConfig.first.increase_sup_last_quotation_no
      @customer_quotation.engineer_id = engineer_id

      checked_estimations.each { |estimation| estimation.update quoted: (estimation.quoted.to_i+1) }
      # Action (81) Create Quotation, DB.spt_act_quotation.
      action_no = 81
    elsif params[:action_type] == "update"
      @customer_quotation = CustomerQuotation.find params[:quotation_id]
      @customer_quotation.attributes = customer_quotation_params

      if @customer_quotation.canceled
        if !@customer_quotation.canceled_was
          @customer_quotation.ticket_estimations.each do |estimation|
            estimation.update quoted: estimation.quoted.to_i-1
          end
        end
      else
        if !@customer_quotation.canceled_was
          @customer_quotation.ticket_estimations.each { |estimation| estimation.update quoted: (estimation.quoted.to_i-1) }
        end

        TicketEstimation.where(id: checked_estimation_ids).each { |estimation| estimation.update quoted: (estimation.quoted.to_i+1) }
      end
      # Action (84) Edit Quotation, DB.spt_act_quotation.
      action_no = 84
    end
    @customer_quotation.ticket_id = @ticket.id
    @customer_quotation.currency_id = @ticket.ticket_currency.id
    @customer_quotation.created_by = current_user.id
    @customer_quotation.save
    @customer_quotation.ticket_estimation_ids = checked_estimation_ids

    #Action 81/84
    user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(action_no).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count, action_engineer_id: engineer_id)
    user_ticket_action.build_act_quotation(customer_quotation_id: @customer_quotation.id)
    user_ticket_action.save

    redirect_to todos_url, notice: "Successfully updated."

  end

  def update_invoice
    Tax
    Warranty
    @ticket = Ticket.find_by_id params[:ticket_id]
    checked_estimation_ids = params[:estimation_ids].to_a
    checked_act_terminate_job_payment_ids = params[:act_terminate_job_payment_ids].to_a

    action_no = 0
    canceled = false
    if params[:action_type] == "create"
      @invoice = TicketInvoice.new invoice_params
      @invoice.invoice_no = CompanyConfig.first.increase_sup_last_invoice_no

      TicketEstimation.where(id: checked_estimation_ids).each do |estimation|
        estimation.update invoiced: estimation.invoiced.to_i+1
      end

      ActTerminateJobPayment.where(id: checked_act_terminate_job_payment_ids).each do |terminate_charge|
        terminate_charge.update invoiced: terminate_charge.invoiced.to_i+1
      end

      # Action (80) Create TicketInvoice, DB.spt_act_print_invoice.
      action_no = 80
    elsif params[:action_type] == "update"
      @invoice = TicketInvoice.find params[:invoice_id]
      @invoice.attributes = invoice_params

      if @invoice.canceled
        if !@invoice.canceled_was
          @invoice.ticket_estimations.update_all "invoiced = invoiced-1"

          @invoice.act_terminate_job_payments.update_all "invoiced = invoiced-1"

          canceled = true
        end

        if @ticket.final_invoice_id == @invoice.id
          @ticket.update final_invoice_id: nil, final_amount_to_be_paid: nil, cus_payment_completed: false
        end

      else
        if !@invoice.canceled_was
          @invoice.ticket_estimations.update_all "invoiced = invoiced-1"
          @invoice.act_terminate_job_payments.update_all "invoiced = invoiced-1"
        end

        TicketEstimation.where(id: checked_estimation_ids).update_all "invoiced = invoiced+1"

        ActTerminateJobPayment.where(id: checked_act_terminate_job_payment_ids).update_all "invoiced = invoiced+1"

      end      
      # Action (83) Edit TicketInvoice, DB.spt_act_print_invoice.
      action_no = 83
    end
    @invoice.ticket = @ticket
    @invoice.created_by = current_user.id
    @invoice.print_count += @invoice.print_count.to_i
    @invoice.currency_id = @ticket.ticket_currency.id

    @invoice.ticket_estimation_ids = checked_estimation_ids
    @invoice.act_terminate_job_payment_ids = checked_act_terminate_job_payment_ids.map { |t| t.to_i }
    @invoice.ticket_payment_received_ids = @ticket.ticket_payment_received_ids if @invoice.new_record?

    #Calculate Total Cost and Total Taxes
    hash_array = {}

    @invoice.total_cost = @invoice.ticket_estimations.to_a.sum{|k| k.ticket_estimation_externals.sum(:cost_price) + k.ticket_estimation_parts.sum(:cost_price) + k.ticket_estimation_additionals.sum(:cost_price) }

    @invoice.ticket_estimations.each do |estimation|
      estimation.ticket_estimation_externals.each do |k|
        k.ticket_estimation_external_taxes.group_by{|t| t.tax_id}.each do |i, l|
          hash_array[i] = hash_array[i].to_f + l.sum{|tax| estimation.approval_required ? tax.approved_tax_amount : tax.estimated_tax_amount }.to_f
        end
      end

      estimation.ticket_estimation_parts.each do |k|
        k.ticket_estimation_part_taxes.group_by{|t| t.tax_id}.each do |i, l|
          hash_array[i] = hash_array[i].to_f + l.sum{|tax| estimation.approval_required ? tax.approved_tax_amount : tax.estimated_tax_amount }.to_f
        end
      end

      estimation.ticket_estimation_additionals.each do |k|
        k.ticket_estimation_additional_taxes.group_by{|t| t.tax_id}.each do |i, l|
          hash_array[i] = hash_array[i].to_f + l.sum{|tax| estimation.approval_required ? tax.approved_tax_amount : tax.estimated_tax_amount }.to_f
        end
      end
    end

    template_total_tax = hash_array.inject([]){|i, (k, v)| i << {tax_id: k, amount: v}}

    @invoice.ticket_invoice_total_taxes.destroy_all unless @invoice.new_record?
    @invoice.ticket_invoice_total_taxes.build template_total_tax

    @invoice.save
    @ticket.update final_amount_to_be_paid: (canceled ? nil : ([@invoice.net_total_amount.to_f] << 0).max), cus_payment_completed: !(canceled or (([@invoice.net_total_amount.to_f] << 0).max > 0))

    @ticket.update final_invoice_id: @invoice.id if !@invoice.canceled
    #Action 80/83
    user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(action_no).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
    user_ticket_action.build_act_print_invoice(invoice_id: @invoice.id)
    user_ticket_action.save
    @total_estimation_amount = @ticket.ticket_estimations.where(foc_approved: false, cust_approved: true).map { |estimation| estimation.approval_required ? (estimation.ticket_estimation_externals.sum(:approved_estimated_price)+estimation.ticket_estimation_parts.sum(:approved_estimated_price)+estimation.ticket_estimation_additionals.sum(:approved_estimated_price)) : (estimation.ticket_estimation_externals.sum(:estimated_price)+estimation.ticket_estimation_parts.sum(:estimated_price)+estimation.ticket_estimation_additionals.sum(:estimated_price)) }.compact.sum

    render "tickets/tickets_pack/estimate_job_final/estimate_job_final"

  end

  def update_inform_customer
    TaskAction
    @ticket = Ticket.find params[:ticket_id]

    #Action 61 - Inform Customer
    user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(61).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
    user_ticket_action.build_inform_customer(inform_customer_params)
    user_ticket_action.save

    flash[:notice] = "Successfully saved."
    redirect_to todos_url
  end

  def update_terminate_foc_approval
    TaskAction
    @ticket = Ticket.find params[:ticket_id]
    deducted_amount = params[:deducted_amount].to_f
    continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])
    final_invoice = @ticket.final_invoice
    ticket_terminate_job = @ticket.user_ticket_actions.order(created_at: :desc).select { |u| u.ticket_terminate_job.present? }.first.try(:ticket_terminate_job)

    cus_payment_completed = (params[:approve_foc].present? and params[:approve_foc].to_bool)

    if final_invoice.present? and ticket_terminate_job.present?
      ticket_terminate_job.foc_approved = false

      if continue
        if params[:approve_foc] and params[:approve_foc].to_bool #Approve FOC
          deducted_amount = 0
          ticket_terminate_job.foc_approved = cus_payment_completed
        end

        final_invoice.deducted_amount = deducted_amount
        final_invoice.total_deduction = deducted_amount
        final_invoice.net_total_amount = final_invoice.total_amount - final_invoice.total_advance_recieved - final_invoice.total_deduction
        final_invoice.save

        @ticket.update final_amount_to_be_paid: final_invoice.net_total_amount, cus_payment_completed: cus_payment_completed, status_id: TicketStatus.find_by_code("CFB").id

        #Action : 59 - Terminate FOC Job Approval
        user_ticket_action = @ticket.user_ticket_actions.build(action_id: 59, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
        user_ticket_action.save

        ticket_terminate_job.foc_approved_action_id = user_ticket_action.id
        ticket_terminate_job.save

        # bpm output variables
        bpm_variables = view_context.initialize_bpm_variables
        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if bpm_response[:status].upcase == "SUCCESS"
          flash[:notice] = "Successfully updated"
        else
          flash[:error] = "Ticket and invoice is updated. but Bpm error"
        end
      else
        flash[:error] = "Bpm error."
      end
    else
      flash[:error] = "Invoice or Terminate job is empty."
    end
    redirect_to todos_url

  end

  private
    def set_invoice
      @invoice = TicketInvoice.find(params[:id])
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
      ticket_params = params.require(:ticket).permit(:id, :remarks, :final_amount_to_be_paid, user_ticket_actions_attributes: [:id, :_destroy, :action_at, :action_id, :action_by, :re_open_index, act_quality_control_attributes: [:approved, :reject_reason]], ge_q_and_answers_attributes: [:id, :general_question_id, :ticket_action_id, :answer], q_and_answers_attributes: [:id, :problematic_question_id, :ticket_action_id, :answer], act_terminate_job_payments_attributes: [:id, :_destroy, :payment_item_id, :amount, :currency_id])
      ticket_params[:current_user_id] = current_user.id
      ticket_params
    end

    def customer_quotation_params
      params.require(:customer_quotation).permit(:id, :validity_period, :delivery_period, :warranty, :payment_term_id, :customer_contacted, :canceled, :note)
    end

    def invoice_params
      params.require(:ticket_invoice).permit(:id, :deducted_amount, :customer_sent, :canceled, :note, :payment_term_id, :total_amount, :total_advance_recieved, :total_deduction, :net_total_amount)
    end

    def inform_customer_params
      params.require(:inform_customer).permit(:id, :note, :contact_type_id, :contact_address, :subject)
    end
end
