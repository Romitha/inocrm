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

  def update_invoice_advance_payment
    Ticket

    @estimation = TicketEstimation.find params[:advance_payment_estimation_id]
    @ticket = Ticket.find params[:ticket_id]
    @ticket_payment_received = @estimation.build_ticket_payment_received ticket_payment_received_params
    complete_payment_received = params[:complete_payment_received].present?

    continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

    if continue

      if @ticket_payment_received.amount > 0
        # spt_invoice
        @invoice = @ticket_payment_received.build_invoice invoice_no: CompanyConfig.first.increase_sup_last_invoice_no, total_amount: @ticket_payment_received.amount, note: @ticket_payment_received.note, currency_id: @ticket.currency.id, print_count: 0

        # spt_invoice_item
        @invoice.invoice_items.build item_no: 1, description: params[:invoice_item_description], amount: @ticket_payment_received.amount

        if @estimation.save

          # 28 - Invoice Advance Payment
          user_ticket_action = @estimation.ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(28).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @estimation.ticket.re_open_count)
          user_ticket_action.build_act_payment_received(ticket_payment_received_id: @ticket_payment_received.id, invoice_completed: complete_payment_received)
          user_ticket_action.save

          @estimation.update status_id: EstimationStatus.find_by_code("CLS").id if complete_payment_received

        else
          complete_payment_received = false
          @flash_message = {error: "Sorry! unable to update"}
        end
      end

      if complete_payment_received
        # bpm output variables
        bpm_variables = view_context.initialize_bpm_variables
        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if bpm_response[:status].upcase == "SUCCESS"
          @flash_message = {notice: "Successfully updated"}
        else
          @flash_message = {error: "invoice is updated. but Bpm error"}
        end
      else
        @flash_message = {error: "Successfully updated, but not completed"}
      end

    else
      @flash_message = {error: "Bpm error. invoice is not updated"}
    end

    @continue = false
    render "tickets/tickets_pack/invoice_advance_payment/update_invoice_advance_payment"
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
      params.require(:ticket_payment_received).permit(:amount, :note)
    end
end
