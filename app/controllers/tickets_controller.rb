class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket, only: [:show, :edit, :update, :destroy]
  before_action :set_organization_for_ticket, only: [:new, :edit]

  respond_to :html

  def index
    @tickets = Ticket.all
    respond_with(@tickets)
  end

  def show
    respond_with(@ticket)
  end

  def new
    @ticket = @organization.tickets.build
    respond_with(@ticket)
  end

  def edit
  end

  def create
    @ticket = Ticket.new(ticket_params)
    @ticket.save
    respond_with(@ticket)
  end

  def update
    @ticket.update(ticket_params)
    respond_with(@ticket)
  end

  def destroy
    @ticket.destroy
    respond_with(@ticket)
  end

  # post params and response json value
  def find_customer
    request = params[:find_by]
    case request
    when "customer"
      @label = "Customer"
      @customers = User.customers
    when "invoice"
      @label = "Invoice"
    when "serial_number"
      @label = "Product serial number"
    when "related_ticket"
      @label = "Related ticket"
    when "create_customer"
      @label = "Create Customer"
    end
    respond_to do |format|
      format.json
    end
  end

  private
    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    def set_organization_for_ticket
    @organization = Organization.owner      
    end

    def ticket_params
      params.require(:ticket).permit(:type, :status, :subject, :priority, :description, :deleted, {document_attachment: [:file_path, :attachable_id, :attachable_type, :downloadable]}, :organization_id, :department_id, :agent_ids, :customer_id)
    end
end
