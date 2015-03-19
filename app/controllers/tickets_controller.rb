class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket, only: [:show, :edit, :update, :destroy]
  before_action :set_organization_for_ticket, only: [:new, :edit, :create_customer]

  respond_to :html, :json

  def index
    @tickets = Ticket.order("created_at DESC")
    respond_with(@tickets)
  end

  def show
    respond_with(@ticket)
  end

  def new
    ticket_no = Ticket.order("created_at ASC").last.try(:ticket_no).to_i + 1
    @status = TicketStatus.first
    @ticket_logged_at = DateTime.now

    ticket_initiated_attributes = {status_id: @status.id, ticket_no: ticket_no}
    @ticket = Ticket.new ticket_initiated_attributes
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

  def find_by_serial
    serial_no = params[:serial_search]
    @product = Product.find_by_serial_no(serial_no) || Product.new(serial_no: serial_no)
    @base_currency = Currency.find_by_base_currency(true)
    if @product.persisted?
      @product_brand = @product.product_brand
      @product_category = @product.product_category
    else
      @product_brands = ProductBrand.all
      @product_categories = ProductCategory.all

      @new_product_brand = ProductBrand.new currency_id: @base_currency.try(:id)
      @new_product_category = ProductCategory.new
    end
    respond_to do |format|
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

  def new_product_brand
    Product
    @new_product_brand = ProductBrand.new
    respond_to do |format|
      format.js
    end
  end

  def new_product_category
    Product
    @new_product_category = ProductCategory.new
    respond_to do |format|
      format.js
    end
  end

  def create_product_brand
    Product
    @new_product_brand = ProductBrand.new product_brand_params
    respond_to do |format|
      if @new_product_brand.save
        @notice = "Great! #{@new_product_brand.name} is saved. You can create another new Brand."
        @new_product_brand = ProductBrand.new
        format.js {render :new_product_brand}
      else
        format.js {render :new_product_brand}
      end
    end
  end

  def create_new_category
    Product
    @new_product_category = ProductCategory.new category_params
    respond_to do |format|
      if @new_product_category.save
        @notice = "Great! #{@new_product_category.name} is saved. You can create another new category."
        @new_product_category = ProductCategory.new
        format.js {render :new_product_category}
      else
        format.js {render :new_product_category}
      end
    end
  end

  def new_product
    @new_product = Product.new
  end

  def create_product
    @new_product = Product.new product_params
    respond_to do |format|
      if @new_product.save
        @notice = "Great! #{@new_product.serial_no} is saved. You can create another new Product."
        format.js {render :new_product}
      else
        format.js {render :new_product}
      end
      
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

    def product_brand_params
      params.require(:product_brand).permit(:name, :sla_time, :parts_return_days, :warenty_date_formate, :currency_id)
    end

    def product_params
      params.require(:product).permit(:serial_no, :product_brand_id, :product_category_id, :model_no, :product_no, :pop_status_id, :coparate_product)
    end

    def category_params
      params.require(:product_category).permit(:name, :product_brand_id, :sla_time)
    end
end