class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket, only: [:show, :edit, :update, :destroy]
  before_action :set_organization_for_ticket, only: [:new, :edit, :create_customer]

  respond_to :html

  def index
    @tickets = Ticket.order("created_at DESC")
    respond_with(@tickets)
  end

  def show
    respond_with(@ticket)
  end

  def new
    @ticket = Ticket.new
    respond_with(@ticket)
  end

  def edit
  end

  def create
    t_params = ticket_params
    t_params["due_date_time"] = DateTime.strptime(t_params["due_date_time"], '%m/%d/%Y %I:%M %p') if t_params["due_date_time"].present?
    @ticket = Ticket.new(t_params)
    @organization = @ticket.organization
    @ticket.initiated_by = (current_user.user_name || current_user.email)
    @ticket.initiated_by_id = current_user.id
    @ticket.save
    respond_with(@ticket)
  end

  def update
    t_params = ticket_params
    t_params["due_date_time"] = DateTime.strptime(t_params["due_date_time"], '%m/%d/%Y %I:%M %p') if t_params["due_date_time"].present?
    @ticket.update(t_params)
    # respond_with(@ticket)
    respond_to do |format|
      if @ticket.update(t_params)
        format.html {redirect_to @ticket, notice: "Successfully updated."}
        format.json {render json: @ticket}
      else
        format.html {redirect_to @ticket, error: "Unable to update ticket. Please validate your inputs."}
        format.json {render json: @ticket.errors}
      end
    end
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
    @csrf_token = view_context.form_authenticity_token
    respond_to do |format|
      format.json
      format.js
    end
  end

  def create_customer
    request = params.require(:user).permit(:NIC, :email, :full_name, :is_customer, :primary_address, :primary_phone_number)
    @user = @organization.users.build(request)
    @user.user_name = "#{@user.first_name}_#{@user.last_name}_#{rand(100)}"
    if @organization.save
      render json: {success: "success"}
    else
      render json: {errors: @user.errors.full_messages.join(", ").to_json}
    end
  end

  def customer_summary
    @customer = User.find params[:customer_id]
    # respond_with(@customer)
      render json: {id: @customer.id, email: @customer.email, full_name: @customer.full_name, phone_number: @customer.primary_phone_number.try(:value), address: @customer.primary_address.try(:address), nic: @customer.NIC, avatar: view_context.image_tag((@customer.avatar.thumb.url || "no_image.jpg"), alt: @customer.email)}
  end

  def comment_methods
    @ticket_id = params[:ticket_id]
    @customer = params[:customer]
    @to_email = params[:to_email]
    case params[:comment_method]
    when "reply"
      @subject = "reply to: #{params[:to_email]}"
      @from = current_user.email
      @hide_content = "hide"
      @content = "#{@from} replied to #{@to_email}"
      @comment_method = reply_ticket_tickets_path
      @history = @content
    when "forward"
      @subject = "Forward"
      @from = current_user.email

    end
    @csrf_token = view_context.form_authenticity_token
    respond_to do |format|
      format.json
    end
  end

  def reply_ticket
    @ticket_id = params[:comment][:ticket_id]
    ticket_params = params.require(:comment).permit(:subject, :content, :ticket_id, :history)
    ticket_params[:history] = ticket_params[:history]+" on #{DateTime.now.strftime("%d %b, %Y at %H:%M:%S")}"
    @comment = Comment.new ticket_params
    @comment.agent = current_user
    @comment.ticket = Ticket.find(@ticket_id)
    if @comment.save
      @result = @comment
    else
      @error = @comment.errors.full_messages.join(", ")
    end
    respond_to do |format|
      format.json
      format.js
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
      params.require(:ticket).permit(:initiated_through, :ticket_type, :status, :subject, :priority, :description, {document_attachment: [:file_path, :attachable_id, :attachable_type, :downloadable]}, :organization_id, :department_id, :agent_ids, :customer_id, :due_date_time)
    end
end