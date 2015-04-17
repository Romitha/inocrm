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
    session[:ticket_id] = nil
    session[:product_category_id] = nil
    session[:product_brand_id] = nil
    session[:product_id] = nil
    session[:customer_id] = nil
    session[:serial_no] = nil
    session[:warranty_id] = nil
    session[:ticket_initiated_attributes] = {}
    @ticket_no = (Ticket.order("created_at ASC").last.try(:ticket_no).to_i + 1)
    @status = TicketStatus.first
    @ticket_logged_at = DateTime.now

    session[:ticket_initiated_attributes] = {ticket_no: @ticket_no, status_id: @status.id}
    @ticket = Ticket.new(session[:ticket_initiated_attributes])
    respond_with(@ticket)
  end

  def edit
  end

  def create
    @new_ticket = Ticket.new ticket_params
    @ticket = @new_ticket
    respond_to do |format|

      if @new_ticket.save
        session[:ticket_id] = @new_ticket.id
        session[:ticket_initiated_attributes] = {}
        @new_ticket.products << Product.find_by_id(session[:product_id])
        @notice = "Great! new ticket is initiated."

        User
        ContactNumber
        @new_customer = Customer.new
        @new_customer.contact_type_values.build([{contact_type_id: 2}, {contact_type_id: 4}])
        format.js {render :new_customer}
      else

        @product = Product.find session[:product_id]
        format.js {render :find_by_serial}
      end

    end
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
    session[:product_id] = nil
    session[:customer_id] = nil
    session[:serial_no] = serial_no
    @product = Product.find_by_serial_no(serial_no) || Product.new(serial_no: serial_no, corporate_product: false)
    Warranty
    @base_currency = Currency.find_by_base_currency(true)
    if @product.persisted?
      @product_brand = @product.product_brand
      @product_category = @product.product_category
      session[:ticket_initiated_attributes].merge!({})

      session[:product_id] = @product.id


      @ticket = Ticket.new session[:ticket_initiated_attributes]
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

  def new_product_brand
    session[:product_brand_id] = nil
    Product
    @new_product_brand = ProductBrand.new
    respond_to do |format|
      format.js
    end
  end

  def new_product_category
    session[:product_category_id] = nil
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
        session[:product_brand_id] = @new_product_brand.id
        @notice = "Great! #{@new_product_brand.name} is saved. You can create new category."

        @new_product_category = ProductCategory.new
        format.js {render :new_product_category}
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
        session[:product_category_id] = @new_product_category.id
        @notice = "Great! #{@new_product_category.name} is saved. You can create new product."

        @product_brands = ProductBrand.all
        @product_categories = ProductCategory.all
        @product = Product.new serial_no: session[:serial_no]
        format.js {render :find_by_serial}
      else
        format.js {render :new_product_category}
      end
    end
  end

  def new_product
    session[:product_id] = nil
    @new_product = Product.new
  end

  def create_product
    Ticket
    ContactNumber
    @new_product = Product.new product_params
    respond_to do |format|
      if @new_product.save
        session[:product_id] = @new_product.id
        @notice = "Great! #{@new_product.serial_no} is saved. You can create new Customer."
        # @new_customer = Customer.new
        # @new_customer.contact_type_values.build([{contact_type_id: 2}, {contact_type_id: 4}])
        session[:ticket_initiated_attributes].merge!({})

        @product = @new_product
        @ticket = @product.tickets.build session[:ticket_initiated_attributes]
        format.js {render :find_by_serial}
      else
        format.js {render :new_product}
      end
    end
  end

  def new_customer
    User
    ContactNumber
    if params[:function_param]
      @customers = []
      @organizations = []
      @display_select_option = true if params[:function_param]=="create"
    elsif params[:search_customer]
      @customers = Customer.where("name like ?", "%#{params[:search_customer]}%")
      @organizations = Organization.where("name like ?", "%#{params[:search_customer]}%")
    end
    @new_customer = Customer.new
    @new_customer.contact_type_values.build([{contact_type_id: 2}, {contact_type_id: 4}])
    respond_to do |format|
      format.js
    end
  end

  def create_customer
    User
    ContactNumber
    @ticket = Ticket.find_by_id(session[:ticket_id])
    respond_to do |format|
      if params[:customer_id]
        @new_customer = Customer.find params[:customer_id]
        @new_customer.tickets << @ticket
        session[:customer_id] = @new_customer.id
        @notice = "Great! #{@new_customer.name} is added. You can add new contact person details."

        format.js {render :create_contact_persons}
      else
        @new_customer = Customer.new customer_params
        if @new_customer.save
          @new_customer.tickets << @ticket
          session[:customer_id] = @new_customer.id
          @notice = "Great! #{@new_customer.name} is saved. You can add new contact person details."
          format.js {render :create_contact_persons}
        else
          @display_select_option = true
          format.js {render :new_customer}
        end
        
      end
      
    end
  end

  def create_contact_persons
    User
    ContactNumber
    case params[:data_param]
    when "select_contact_person1"
      @contact_persons = []
      @customers = []

      @submit_contact_person = "submit_contact_person1"
    when "select_contact_person2"
      @contact_persons = []
      @customers = []

      @submit_contact_person = "submit_contact_person2"
    when "select_report_person"
      @contact_persons = []
      @customers = []

      @submit_contact_person = "submit_report_person"
    when "initiate_contact_person"
      @contact_person_for_customer = params[:contact_person_id].present? ? Customer.find(params[:contact_person_id]) : Customer.new
      @contact_person_attribs = {title_id: @contact_person_for_customer.title_id, name: @contact_person_for_customer.name}
      @c_p_c_t_attribs = @contact_person_for_customer.contact_type_values.map{|c_t_v| {contact_type_id: c_t_v.contact_type_id, value: c_t_v.value}}
      @ticket = Ticket.find_by_id(session[:ticket_id])
      if params[:contact_person] == "1"
        @build_contact_person = @ticket.build_contact_person1(@contact_person_attribs)
        @contact_person_frame = "#contact_persons_form1"
        @submitted_contact_person = "one"
      elsif params[:contact_person] == "2"
        @build_contact_person = @ticket.build_contact_person2(@contact_person_attribs)
        @contact_person_frame = "#contact_persons_form2"
        @submitted_contact_person = "two"
      elsif params[:contact_person] == "3"
        @build_contact_person = @ticket.build_report_person(@contact_person_attribs)
        @contact_person_frame = "#report_persons_form"
        @submitted_contact_person = "three"
      end

      @header = "Contact Person"
    when "assign_contact_person"
      @ticket = Ticket.find_by_id(session[:ticket_id])
      if params[:contact_person] == "1"
        puts params[:contact_person].class
        @build_contact_person = ContactPerson1.find(params[:contact_person_id])
        @ticket.update_attribute(:contact_person1_id, @build_contact_person.id)
        @contact_person_frame = "#contact_persons_form1"
        @submitted_contact_person = "one"

      elsif params[:contact_person] == "2"
        @build_contact_person = ContactPerson2.find(params[:contact_person_id])
        @ticket.update_attribute(:contact_person2_id, @build_contact_person.id)
        @contact_person_frame = "#contact_persons_form2"
        @submitted_contact_person = "two"

      elsif params[:contact_person] == "3"
        @build_contact_person = ReportPerson.find(params[:contact_person_id])
        @ticket.update_attribute(:reporter_id, @build_contact_person.id)
        @contact_person_frame = "#report_persons_form"
        @submitted_contact_person = "three"    
      end
    else
      if params[:submit_contact_person1]
        @submitted_contact_person = 1
        @submit_contact_person = "submit_contact_person1"
        @contact_persons = params[:search_contact_person].present? ? ContactPerson1.where("name like ?", "%#{params[:search_contact_person]}%") : []

      elsif params[:submit_contact_person2]
        @submitted_contact_person = 2
        @submit_contact_person = "submit_contact_person2"
        @contact_persons = params[:search_contact_person].present? ? ContactPerson2.where("name like ?", "%#{params[:search_contact_person]}%") : []
      elsif params[:submit_report_person]
        @submitted_contact_person = 3
        @submit_contact_person = "submit_report_person"
        @contact_persons = params[:search_contact_person].present? ? ReportPerson.where("name like ?", "%#{params[:search_contact_person]}%") : []
      end
      @customers = params[:search_contact_person].present? ? Customer.where("name like ?", "%#{params[:search_contact_person]}%") : []
    end
    render :select_contact_person
  end

  def create_contact_person_record
    @ticket = Ticket.find(session[:ticket_id])
    ContactNumber

    if params[:one]
      if params[:persisted]
        @new_contact_person = ContactPerson1.find(params[:persisted])
        @new_contact_person.update(contact_person1_params)
        @new_contact_person = ContactPerson1.find(params[:persisted])
      else
        @new_contact_person = ContactPerson1.new(contact_person1_params)
      end
      @ticket.contact_person1 = @new_contact_person
      @submitted_contact_person = "one"
    elsif params[:two]
      if params[:persisted]
        @new_contact_person = ContactPerson2.find(params[:persisted])
        @new_contact_person.update(contact_person2_params)
        @new_contact_person = ContactPerson2.find(params[:persisted])
      else
        @new_contact_person = ContactPerson2.new(contact_person2_params)
      end
      @ticket.contact_person2 = @new_contact_person
      @submitted_contact_person = "two"

    elsif params[:three]
      if params[:persisted]
        @new_contact_person = ReportPerson.find(params[:persisted])
        @new_contact_person.update(report_person_params)
        @new_contact_person = ReportPerson.find(params[:persisted])
      else
        @new_contact_person = ReportPerson.new(report_person_params)
      end
      @ticket.report_person = @new_contact_person
      @submitted_contact_person = "three"      
    end
    respond_to do |format|
      if @new_contact_person.save
        @ticket.save
      end
      @build_contact_person = @new_contact_person
      format.js      
    end
  end

  def contact_persons
    User
    ContactNumber
    respond_to do |format|
      @new_customer = Customer.find(session[:customer_id])
      @ticket = @new_customer.tickets.find(session[:ticket_id])
      format.js {render :create_contact_persons}
    end
  end

  def select_sla
    if params[:search_sla]
      @slas = SlaTime.where(sla_time: params[:search_sla_value].to_f).present? ? SlaTime.where(sla_time: params[:search_sla_value].to_f) : SlaTime.all
    else
      @header = "Select SLA Time"
      @slas = SlaTime.all
    end
  end

  def create_sla
    if params[:create_sla]
      @new_sla = SlaTime.new sla_time_params
      if @new_sla.save
        session[:sla_id] = @new_sla.id
        @new_sla = SlaTime.new
        @modal_close = true
      end
    else
      @new_sla = SlaTime.new
      @header = "Create New SLA Time"
    end
  end

  def create_problem_category
    Ticket
    Warranty
    if params[:status_param] == "initiate"
      @new_problem_category = ProblemCategory.new
    elsif params[:status_param] == "create"
      @new_problem_category = ProblemCategory.new problem_category_params
      @new_problem_category.save
      @ticket = Ticket.new session[:ticket_initiated_attributes]
      @product = Product.find(session[:product_id])
    elsif params[:status_param] == "back"
      @ticket = Ticket.new session[:ticket_initiated_attributes]
      @product = Product.find(session[:product_id])
    end
  end

  def create_accessory
    Product
    Ticket
    Warranty
    if params[:status_param] == "initiate"
      @new_accessory = Accessory.new
    elsif params[:status_param] == "create"
      @new_accessory = Accessory.new accessory_params
      @new_accessory.save
      @ticket = Ticket.new session[:ticket_initiated_attributes]
      @product = Product.find(session[:product_id])
    elsif params[:status_param] == "back"
      @ticket = Ticket.new session[:ticket_initiated_attributes]
      @product = Product.find(session[:product_id])
    end
  end

  def remarks
    @ticket = Ticket.find(session[:id])
    @warranty = Warranty.find(session[:warranty_id])
  end

  private
    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    def set_organization_for_ticket
    @organization = Organization.owner      
    end

    def ticket_params
      params.require(:ticket).permit(:ticket_no, :serial_no, :base_currency_id, :contact_type_id, :cus_chargeable, :informed_method_id, :job_type_id, :other_accessories, :priority, :problem_category_id, :problem_description, :remarks, :resolution_summary, :status_id, :ticket_type_id, :warranty_type_id)
    end

    def product_brand_params
      params.require(:product_brand).permit(:sla_id, :name, :parts_return_days, :warenty_date_formate, :currency_id)
    end

    def product_params
      params.require(:product).permit(:serial_no, :product_brand_id, :product_category_id, :model_no, :product_no, :pop_status_id, :coparate_product, :pop_note)
    end

    def category_params
      params.require(:product_category).permit(:name, :product_brand_id, :sla_time)
    end

    def customer_params
      params.require(:customer).permit(:name, :title_id, :address1, :address2, :address3, :address4,:district_id, contact_type_values_attributes: [:id, :contact_type_id, :value, :_destroy])
    end

    def sla_time_params
      params.require(:sla_time).permit(:sla_time, :description)
    end

    def contact_person1_params
      params.require(:contact_person1).permit(:title_id, :name, contact_person_contact_types_attributes: [:id, :contact_type_id, :value, :_destroy])
    end

    def contact_person2_params
      params.require(:contact_person2).permit(:title_id, :name, contact_person_contact_types_attributes: [:id, :contact_type_id, :value, :_destroy])
    end

    def report_person_params
      params.require(:report_person).permit(:title_id, :name, contact_person_contact_types_attributes: [:id, :contact_type_id, :value, :_destroy])
    end

    def problem_category_params
      params.require(:problem_category).permit(:name)
    end
end