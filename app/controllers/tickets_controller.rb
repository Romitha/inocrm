class TicketsController < ApplicationController
  before_action :set_ticket, only: [:show, :edit, :update, :destroy, :update_change_ticket_cus_warranty, :update_change_ticket_repair_type, 
    :update_start_action, :update_re_assign, :update_hold, :update_create_fsr, :update_edit_serial_no_request, :update_edit_fsr, 
    :update_terminate_job, :update_action_taken, :update_request_spare_part, :update_request_on_loan_spare_part, :update_hp_case_id, :update_resolved_job, :update_deliver_unit, :update_job_estimation_request, :update_recieve_unit, :update_un_hold]
  before_action :set_organization_for_ticket, only: [:new, :edit, :create_customer]
  # layout :workflow_diagram, only: [:workflow_diagram]

  respond_to :html, :json

  def index
    @tickets = Ticket.order("created_at DESC")
    respond_with(@tickets)

  end

  # available caches
    # new_ticket, ticket_params, histories, existing_customer, new_product_with_pop_doc_url, created_warranty

  def new
    Rails.cache.delete([:new_ticket, request.remote_ip.to_s, session[:time_now]])
    Rails.cache.delete([:ticket_params, request.remote_ip.to_s, session[:time_now]])
    Rails.cache.delete([:histories, request.remote_ip.to_s, session[:time_now]])
    Rails.cache.delete([:existing_customer, request.remote_ip.to_s, session[:time_now]])
    session[:time_now] = nil
    session[:ticket_id] = nil
    session[:product_category_id] = nil
    session[:product_brand_id] = nil
    session[:product_id] = nil
    session[:customer_id] = nil
    session[:serial_no] = nil
    session[:warranty_id] = nil
    session[:ticket_initiated_attributes] = {}
    @ticket_no = (Ticket.any? ? (Ticket.order("created_at ASC").map{|t| t.ticket_no.to_i}.max + 1) : 1)
    @status = TicketStatus.find_by_code("OPN")
    @ticket_logged_at = DateTime.now

    session[:ticket_initiated_attributes] = {ticket_no: @ticket_no, status_id: @status.id}
    @ticket = Ticket.new(session[:ticket_initiated_attributes])
    respond_with(@ticket)
  end

  def edit
  end

  def create
    # Rails.cache.write(:ticket_params, ticket_params)
    session[:time_now] ||= Time.now.strftime("%H%M%S")
    @new_ticket = (Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]]) || Ticket.new)
    @new_ticket.ticket_accessories.clear
    @new_ticket.attributes = ticket_params

    Rails.cache.write([:new_ticket, request.remote_ip.to_s, session[:time_now]], @new_ticket)

    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])

    @product = Product.find session[:product_id]
    @product_brand = @product.product_brand
    @product_category = @product.product_category
    @new_ticket.sla_id = (@product_category.sla_id || @product_brand.sla_id)

    Warranty
    respond_to do |format|

      if @new_ticket.valid?
        session[:ticket_initiated_attributes] = {}

        @notice = "Great! new ticket is initiated."
        Rails.cache.write([:new_ticket, request.remote_ip.to_s, session[:time_now]], @new_ticket)
        User
        ContactNumber
        @existing_customer = (Customer.find_by_id(session[:customer_id]) || @product.tickets.last.try(:customer))
        Rails.cache.fetch([:existing_customer, request.remote_ip.to_s, session[:time_now]]) do
          @existing_customer
        end
        @new_customer = Customer.new
        @new_customer.contact_type_values.build([{contact_type_id: 2}, {contact_type_id: 4}])
        format.js {render :new_customer}
      else

        # format.js {render :find_by_serial}
        format.js {render js: "alert('Please enter valid and required information.');"}
      end

    end
  end

  def update
    t_params = ticket_params
    t_params["remarks"] = "#{ticket_params['remarks']} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@ticket.remarks}" if ticket_params["remarks"].present?
    # @ticket.update(t_params)
    # respond_with(@ticket)
    t_params[:user_ticket_actions_attributes].first[:action_at] = Time.now if t_params[:user_ticket_actions_attributes].present?
    respond_to do |format|
      if @ticket.update(t_params)
        format.html {redirect_to @ticket, notice: "Successfully updated."}
        format.json {render json: @ticket}
      else
        format.html {redirect_to @ticket, error: "Unable to update ticket. Please validate resposible fields as instructed."}
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
    if serial_no.blank?
      render js: "alert('Please enter any serial no');"
    else
      session[:product_id] = nil
      session[:customer_id] ||= nil
      session[:serial_no] = serial_no
      @product = (Product.find_by_serial_no(serial_no) || Product.new(serial_no: serial_no, corporate_product: false))
      Warranty
      #@base_currency = Currency.find_by_base_currency(true)
      if @product.persisted?
        @product_brand = @product.product_brand
        @product_category = @product.product_category
        session[:ticket_initiated_attributes].merge!({sla_id: (@product_category.sla_id || @product_brand.sla_id)})
        session[:product_id] = @product.id

        @ticket = (Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]]) || Ticket.new(session[:ticket_initiated_attributes]))

        # @ticket.ticket_accessories.uniq!{|ac| ac.id}
        @customer = @product.tickets.last.try(:customer)
        Rails.cache.write([:histories, session[:product_id]], Kaminari.paginate_array(@product.tickets.reject{|t| t==@ticket}))
        @histories = Rails.cache.read([:histories, session[:product_id]]).page(params[:page]).per(3)
      else
        @product_brands = ProductBrand.all
        @product_categories = ProductCategory.all

        @new_product_brand = ProductBrand.new# currency_id: @base_currency.try(:id)
        @new_product_category = ProductCategory.new
      end
      respond_to do |format|
        format.js
      end
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
    @new_product = Product.new serial_no: session[:serial_no]
  end

  def create_product
    Ticket
    ContactNumber
    Warranty

    respond_to do |format|
      if product_params[:pop_doc_url]
        @new_product = Product.new product_params

        Rails.cache.write([:new_product_with_pop_doc_url, request.remote_ip], @new_product)
        format.js {render :new_product}
      else
        @new_product = (Rails.cache.read([:new_product_with_pop_doc_url, request.remote_ip]) or Product.new)
        @new_product.attributes = product_params
        if @new_product.save
          Rails.cache.delete([:new_product_with_pop_doc_url, request.remote_ip])
          session[:product_id] = @new_product.id
          @notice = "Great! #{@new_product.serial_no} is saved."
          @product_brand = @new_product.product_brand
          @product_category = @new_product.product_category
          session[:ticket_initiated_attributes].merge!({sla_id: (@product_category.sla_id || @product_brand.sla_id)})

          @product = @new_product
          @ticket = @product.tickets.build session[:ticket_initiated_attributes]

          @histories = Kaminari.paginate_array(@product.tickets)
          Rails.cache.write([:histories, session[:product_id]], Kaminari.paginate_array(@product.tickets))
          @histories = Rails.cache.read([:histories, session[:product_id]]).page(params[:page]).per(3)
          format.js {render :find_by_serial}
        else
          format.js {render :new_product}
        end
      end
    end
  end

  def new_customer
    User
    ContactNumber
    Warranty
    @existing_customer = Rails.cache.fetch([:existing_customer, request.remote_ip.to_s, session[:time_now]])
    if params[:function_param]
      @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
      @customers = []
      @organizations = []
      @display_select_option = true if params[:function_param]=="create"
    elsif params[:select_customer]
      search_customer = params[:search_customer].strip
      customers_nameonly = Customer.where("name like ?", "%#{search_customer}%")
      customers_nameandnum = ContactTypeValue.where("value like ?", "%#{search_customer}%").map{|c| c.customer}
      customers_borth = customers_nameonly + customers_nameandnum
      @customers = Kaminari.paginate_array(customers_borth.uniq).page(params[:page]).per(INOCRM_CONFIG["pagination"]["customer_per_page"])
      @organizations = Kaminari.paginate_array(Organization.where("name like ?", "%#{search_customer}%")).page(params[:page]).per(INOCRM_CONFIG["pagination"]["organization_per_page"])
    end
    if params[:customer_id].present?
      existed_customer = Customer.find params[:customer_id]
      existed_customer_attribs = existed_customer.contact_type_values.map{|c| {contact_type_id: c.contact_type_id, value: c.value}}
      @new_customer = Customer.new existed_customer.attributes.except("id")

      @new_customer.contact_type_values.build existed_customer_attribs
    else
      @new_customer = Customer.new
      @new_customer.contact_type_values.build([{contact_type_id: 2}, {contact_type_id: 4}])
    end
    respond_to do |format|
      format.js
    end
  end

  def create_customer
    User
    ContactNumber
    Warranty
    @product = Product.find session[:product_id]
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
    respond_to do |format|
      if params[:customer_id]
        @new_customer = Customer.find params[:customer_id]
        @ticket.customer_id = @new_customer.id
        @ticket.contact_person1 ||= @product.tickets.last.try(:contact_person1)
        @ticket.contact_person2 ||= @product.tickets.last.try(:contact_person2)
        @ticket.report_person ||= @product.tickets.last.try(:report_person)
        puts @ticket.contact_person1
        Rails.cache.write([:new_ticket, request.remote_ip.to_s, session[:time_now]], @ticket)
        session[:customer_id] = @new_customer.id
        @notice = "Great! #{@new_customer.name} is added."

        format.js {render :create_contact_persons}
      else
        @new_customer = Customer.new customer_params
        if @new_customer.save
          @ticket.customer_id = @new_customer.id
          session[:customer_id] = @new_customer.id
          Rails.cache.write([:new_ticket, request.remote_ip.to_s, session[:time_now]], @ticket)
          @notice = "Great! #{@new_customer.name} is saved."
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
    Warranty
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
      @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
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
      @contact_person_for_customer.new_record? ? @build_contact_person.contact_person_contact_types.build([{contact_type_id: 2}, {contact_type_id: 4}]) : @build_contact_person.contact_person_contact_types.build(@c_p_c_t_attribs)

      @header = "Contact Person"
    when "edit_create_contact_person"
      @ticket = Ticket.find_by_id(session[:ticket_id])
      if params[:contact_person] == "1"
        found_contact_person = ContactPerson1.find(params[:contact_person_id])
        @c_p_c_t_attribs = found_contact_person.contact_person_contact_types.map{|c_t_v| {contact_type_id: c_t_v.contact_type_id, value: c_t_v.value}}
        @build_contact_person = ContactPerson1.new title_id: found_contact_person.title_id, name: found_contact_person.name
        @build_contact_person.contact_person_contact_types.build @c_p_c_t_attribs
        @contact_person_frame = "#contact_persons_form1"
        @submitted_contact_person = "one"

      elsif params[:contact_person] == "2"
       found_contact_person = ContactPerson2.find(params[:contact_person_id])
       @c_p_c_t_attribs = found_contact_person.contact_person_contact_types.map{|c_t_v| {contact_type_id: c_t_v.contact_type_id, value: c_t_v.value}}
        @build_contact_person = ContactPerson2.new title_id: found_contact_person.title_id, name: found_contact_person.name
        @build_contact_person.contact_person_contact_types.build @c_p_c_t_attribs
        @contact_person_frame = "#contact_persons_form2"
        @submitted_contact_person = "two"

      elsif params[:contact_person] == "3"
        found_contact_person = ReportPerson.find(params[:contact_person_id])
        @c_p_c_t_attribs = found_contact_person.contact_person_contact_types.map{|c_t_v| {contact_type_id: c_t_v.contact_type_id, value: c_t_v.value}}
        @build_contact_person = ReportPerson.new title_id: found_contact_person.title_id, name: found_contact_person.name
        @build_contact_person.contact_person_contact_types.build @c_p_c_t_attribs
        @contact_person_frame = "#report_persons_form"
        @submitted_contact_person = "three"    
      end
    when "assign_contact_person"
      if params[:contact_person] == "1"
        @build_contact_person = ContactPerson1.find(params[:contact_person_id])
        @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
        @ticket.contact_person1_id = @build_contact_person.id
        Rails.cache.write([:new_ticket, request.remote_ip.to_s, session[:time_now]], @ticket)
        @contact_person_frame = "#contact_persons_form1"
        @submitted_contact_person = "one"

      elsif params[:contact_person] == "2"
        @build_contact_person = ContactPerson2.find(params[:contact_person_id])
        @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
        @ticket.contact_person2_id = @build_contact_person.id
        Rails.cache.write([:new_ticket, request.remote_ip.to_s, session[:time_now]], @ticket)
        @contact_person_frame = "#contact_persons_form2"
        @submitted_contact_person = "two"

      elsif params[:contact_person] == "3"
        @build_contact_person = ReportPerson.find(params[:contact_person_id])
        @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
        @ticket.reporter_id = @build_contact_person.id
        Rails.cache.write([:new_ticket, request.remote_ip.to_s, session[:time_now]], @ticket)
        @contact_person_frame = "#report_persons_form"
        @submitted_contact_person = "three"    
      end
    else
      if params[:submit_contact_person1]
        @submitted_contact_person = 1
        search_contact_person = params[:search_contact_person].strip
        @submit_contact_person = "submit_contact_person1"
        contact_person1_name = ContactPerson1.where("name like ?", "%#{search_contact_person}%")
        contact_person1_nameandnum = ContactPersonContactType.where("value like ?", "%#{search_contact_person}%").map{|c| c.contact_person1}
        contact_person1_uniq = contact_person1_name + contact_person1_nameandnum
        @contact_persons = Kaminari.paginate_array(contact_person1_uniq.uniq).page(params[:page]).per(3)

      elsif params[:submit_contact_person2]
        @submitted_contact_person = 2
        search_contact_person = params[:search_contact_person].strip
        @submit_contact_person = "submit_contact_person2"
        contact_person2_name = ContactPerson2.where("name like ?", "%#{search_contact_person}%")
        contact_person2_nameandnum = ContactPersonContactType.where("value like ?", "%#{search_contact_person}%").map{|c| c.contact_person2}
        contact_person2_uniq = contact_person2_name + contact_person2_nameandnum
        @contact_persons = Kaminari.paginate_array(contact_person2_uniq.uniq).page(params[:page]).per(3)
      elsif params[:submit_report_person]
        @submitted_contact_person = 3
        search_contact_person = params[:search_contact_person].strip
        @submit_contact_person = "submit_report_person"
        report_person_name = ReportPerson.where("name like ?", "%#{search_contact_person}%")
        report_person_nameandnum = ContactPersonContactType.where("value like ?", "%#{search_contact_person}%").map{|c| c.report_person}
        report_person_uniq = report_person_name + report_person_nameandnum
        @contact_persons = Kaminari.paginate_array(report_person_uniq.uniq).page(params[:page]).per(3)
      end
      search_contact_person = params[:search_contact_person].strip
      contact_customer_byname = Customer.where("name like ?", "%#{search_contact_person}%")
      contact_customer_bynum =  ContactTypeValue.where("value like ?", "%#{search_contact_person}%").map{|c| c.customer}
      contact_customer_byboth =  contact_customer_byname + contact_customer_bynum
      @customers = Kaminari.paginate_array(contact_customer_byboth.uniq).page(params[:page]).per(3)
    end
    render :select_contact_person
  end

  def create_contact_person_record
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
    ContactNumber
    Warranty

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
    Rails.cache.write([:new_ticket, request.remote_ip.to_s, session[:time_now]], @ticket)
    respond_to do |format|
      if @new_contact_person.save
        @build_contact_person = @new_contact_person
        format.js
      else
        format.js {render js: "alert('Please complete required fields. Thank you')"}
      end
    end
  end

  def contact_persons
    User
    ContactNumber
    @product = Product.find session[:product_id]
    respond_to do |format|
      @new_customer = Customer.find(session[:customer_id])
      @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
      format.js {render :create_contact_persons}
    end
  end

  def select_sla
    if params[:search_sla]
      @slas = params[:search_sla_value].present? ? SlaTime.where(sla_time: params[:search_sla_value].to_f) : SlaTime.all
    else
      @header = "Select SLA Time"
      @slas = SlaTime.all
    end
  end

  def create_sla
    if params[:create_sla]
      @new_sla = SlaTime.new sla_time_params
      @new_sla.created_by = current_user.id
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
    @histories = Rails.cache.read([:histories, session[:product_id]]).page(params[:page]).per(3)
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

  def create_product_country
    @new_product = Product.new serial_no: session[:serial_no]
    if params[:status_param] == "initiate"
      @new_product_country = ProductSoldCountry.new
    elsif params[:status_param] == "create"
      @new_product_country = ProductSoldCountry.new product_country_params
      @new_product_country.save
      @ticket = Ticket.new session[:ticket_initiated_attributes]
      render :new_product
    elsif params[:status_param] == "back"
      @ticket = Ticket.new session[:ticket_initiated_attributes]
      render :new_product
    end
  end

  def create_accessory
    Product
    Ticket
    Warranty
    @histories = Rails.cache.read([:histories, session[:product_id]]).page(params[:page]).per(3)
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

  def create_extra_remark
    Product
    Ticket
    Warranty
    QAndA
    if params[:status_param] == "initiate"
      @new_extra_remark = ExtraRemark.new
    elsif params[:status_param] == "create"
      @new_extra_remark = ExtraRemark.new extra_remark_params
      @new_extra_remark.save
      @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
      render "remarks"
    elsif params[:status_param] == "back"
      @ticket = Ticket.new session[:ticket_initiated_attributes]
      @product = Product.find(session[:product_id])
    end
  end

  def remarks
    QAndA
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
    @product = Product.find session[:product_id]
  end

  def finalize_ticket_save
    WorkflowMapping
    QAndA
    TaskAction
    Warranty
    @product = Product.find session[:product_id]
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])

    if params[:first_resolution]
      @status_close_id = TicketStatus.find_by_code("CLS").id
      @ticket.status_id = @status_close_id
      @ticket.attributes = ticket_params.merge({ticket_closed_at: DateTime.now, open_time_duration: 0, open_time_duration_sla: 0, sla_finished_at: DateTime.now})
      @status_resolve_id = TicketStatusResolve.find_by_code("FST").try(:id)
    else
      @status_resolve_id = TicketStatusResolve.find_by_code("NAP").try(:id)
    end

    @repair_type_id = RepairType.find_by_code("IN").try :id
    @manufacture_currency_id = @product.product_brand.currency.id
    @ticket.attributes = ticket_params.merge({created_by: current_user.id, slatime: @ticket.sla_time.try(:sla_time), status_resolve_id: @status_resolve_id, repair_type_id: @repair_type_id, manufacture_currency_id: @manufacture_currency_id, ticket_print_count: 0, ticket_complete_print_count: 0})
    q_and_answers = @ticket.q_and_answers.to_a
    ge_q_and_answers = @ticket.ge_q_and_answers.to_a
    @ticket.q_and_answers.clear
    @ticket.ge_q_and_answers.clear

    continue = true
    warranty_constraint = true

    if ["CW", "MW"].include?(@ticket.warranty_type.code)
      warranty_constraint = @product.warranties.select{|w| w.warranty_type_id == @ticket.warranty_type_id and (w.start_at.to_date..w.end_at.to_date).include?(Date.today)}.present?
    end

    if @ticket.status_id != @status_close_id
      bpm_response = view_context.send_request_process_data process_history: true, process_instance_id: 1, variable_id: "ticket_id"
      if bpm_response[:status].try(:upcase) == "ERROR"
        continue = false
        render js: "alert('BPM error. Please continue after rectify BPM.');"
      elsif not warranty_constraint
        continue = false
        render js: "alert('There are no present #{@ticket.warranty_type.name} for the product to initiate particular warranty related ticket.')"
      end
    end

    if continue
      if @ticket.save
        @ticket.products << @product
        @product.update_attribute :last_ticket_id, @ticket.id

        ticket_user_action = @ticket.user_ticket_actions.create(action_at: DateTime.now, action_by: current_user.id, re_open_index: 0, action_id: TaskAction.find_by_action_no(1).id) # Add ticket action

        q_and_answers.each{|q| q.ticket_action_id= ticket_user_action.id; @ticket.q_and_answers << q}
        ge_q_and_answers.each{|q| q.ticket_action_id= ticket_user_action.id; @ticket.ge_q_and_answers << q}

        Rails.cache.delete([:new_ticket, request.remote_ip.to_s, session[:time_now]])
        Rails.cache.delete([:ticket_params, request.remote_ip.to_s, session[:time_now]])
        Rails.cache.delete([:created_warranty, request.remote_ip.to_s, session[:time_now]])
        Rails.cache.delete([:existing_customer, request.remote_ip.to_s, session[:time_now]])
        Rails.cache.delete([:histories, session[:product_id]])
        session[:ticket_id] = nil
        session[:product_category_id] = nil
        session[:product_brand_id] = nil
        session[:product_id] = nil
        session[:customer_id] = nil
        session[:serial_no] = nil
        session[:warranty_id] = nil
        session[:ticket_initiated_attributes] = {}
        session[:time_now]= nil

        unless @ticket.status_id == @status_close_id
          # bpm output variables
          ticket_id = @ticket.id
          di_pop_approval_pending = ["RCD", "RPN", "APN", "LPN", "APV"].include?(@ticket.products.first.product_pop_status.try(:code)) ? "Y" : "N"
          priority = @ticket.priority

          bpm_response = view_context.send_request_process_data start_process: true, process_name: "SPPT", query: {ticket_id: ticket_id, d1_pop_approval_pending: di_pop_approval_pending, priority: priority}

          if bpm_response[:status].try(:upcase) == "SUCCESS"
            @ticket.ticket_workflow_processes.create(process_id: bpm_response[:process_id], process_name: bpm_response[:process_name])
            ticket_bpm_headers bpm_response[:process_id], @ticket.id, ""
          else
            @bpm_process_error = true
          end
        end
        flash_message = @bpm_process_error ? "Ticket successfully saved. But BPM error. Please continue after rectifying BPM" : "Thank you. ticket is successfully registered."
        render js: "alert('#{flash_message}'); window.location.href='#{ticket_path(@ticket)}';"

      else
        render :remarks
      end
     # render plain: @ticket_params.inspect
    end
  end

  def product_update
    @product = Product.find(params[:product_id])
    formatted_product_params = product_params
    formatted_product_params["pop_note"] = "#{formatted_product_params['pop_note']} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@product.pop_note}" if formatted_product_params["pop_note"].present?
    @product.update(formatted_product_params)
    respond_with(@product)
  end

  def ticket_update
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
    t_attributes = @ticket.attributes
    t_attributes.merge! ticket_params
    @ticket.attributes = t_attributes
    respond_to do |format|
      if @ticket.valid?
        format.html {redirect_to @ticket, notice: "Successfully updated."}
        Rails.cache.write([:new_ticket, request.remote_ip.to_s, session[:time_now]], @ticket)
        format.json {render json: @ticket}
      else
        format.html {redirect_to @ticket, error: "Unable to update ticket. Please validate your inputs."}
        format.json {render json: @ticket.errors}
      end
    end
  end

  def q_and_answer_save
    QAndA
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
    @ticket.q_and_answers.clear
    @ticket.ge_q_and_answers.clear
    @ticket.attributes = ticket_params
    if @ticket.valid?
      Rails.cache.write([:new_ticket, request.remote_ip.to_s, session[:time_now]], @ticket)
      # Rails.cache.write(:ticket_params, ticket_params)
      # render js: "alert('Q and A are successfully saved');"
      render "remarks"
    else
      render js: "alert('Please complete required questions');"
    end
  end

  def join_tickets
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
    @ticket.joint_tickets.clear
    if params[:ticket].present?
      @ticket.attributes = ticket_params
      Rails.cache.write([:new_ticket, request.remote_ip.to_s, session[:time_now]], @ticket)
    end
    render js: "alert('tickets joint updated.');"
  end

  def paginate_ticket_histories
    @rendering_id = params[:rendering_id]
    @rendering_file = params[:rendering_file]
    if @rendering_file == "join"
      @histories = Rails.cache.fetch([:join, params[:ticket_id]]).page(params[:page]).per(params[:per_page])
    else
      @histories = Rails.cache.read([:histories, session[:product_id]]).page(params[:page]).per(params[:per_page])
    end
  end

  def show
    Warranty
    ContactNumber
    QAndA
    @product = @ticket.products.first
    @warranties = @product.warranties
    session[:product_id] = @product.id
    session[:process_id] = nil
    session[:task_id] = nil
    session[:owner] = nil
    # Rails.cache.delete([:histories, session[:product_id]])
    Rails.cache.delete([:join, @ticket.id])
    @histories = Rails.cache.fetch([:histories, session[:product_id]]){Kaminari.paginate_array(@product.tickets.reject{|t| t == @ticket})}.page(params[:page]).per(2)

    @join_tickets = Rails.cache.fetch([:join, @ticket.id]){Kaminari.paginate_array(Ticket.where(id: @ticket.joint_tickets.map(&:joint_ticket_id)))}.page(params[:page]).per(2)

    @q_and_answers = Rails.cache.fetch([:q_and_answers, @ticket.id]){ @ticket.q_and_answers.group_by{|a| a.q_and_a && a.q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"Problematic Questions" => v})} }

    @ge_q_and_answers = Rails.cache.fetch([:ge_q_and_answers, @ticket.id]){ @ticket.ge_q_and_answers.group_by{|ge_a| ge_a.ge_q_and_a && ge_a.ge_q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"General Questions" => v})} }

    respond_with(@ticket)
  end

  def assign_ticket
    ContactNumber
    QAndA
    TaskAction
    @ticket = Ticket.find_by_id params[:ticket_id]
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])
      @histories = Rails.cache.fetch([:histories, session[:product_id]]){Kaminari.paginate_array(@product.tickets)}.page(params[:page]).per(2)

      @join_tickets = Rails.cache.fetch([:join, @ticket.id]){Kaminari.paginate_array(Ticket.where(id: @ticket.joint_tickets.map(&:joint_ticket_id)))}.page(params[:page]).per(2)

      @q_and_answers = Rails.cache.fetch([:q_and_answers, @ticket.id]){ @ticket.q_and_answers.group_by{|a| a.q_and_a && a.q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"Problematic Questions" => v})} }

      @ge_q_and_answers = Rails.cache.fetch([:ge_q_and_answers, @ticket.id]){ @ticket.ge_q_and_answers.group_by{|ge_a| ge_a.ge_q_and_a && ge_a.ge_q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"General Questions" => v})} }

      @user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(2).id)
      @user_assign_ticket_action = @user_ticket_action.user_assign_ticket_actions.build
      @assign_regional_support_center = @user_ticket_action.assign_regional_support_centers.build
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/assign_ticket"}
    end
  end

  def update_assign_ticket
    @ticket = Ticket.find(params[:ticket_id])
    TaskAction
    continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if continue

      t_params = ticket_params
      t_params["remarks"] = t_params["remarks"].present? ? "#{t_params['remarks']} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@ticket.remarks}" : @ticket.remarks

      t_params["user_ticket_actions_attributes"].first.merge!("action_at" => DateTime.now.strftime("%Y-%m-%d %H:%M:%S"))
      puts t_params
      @ticket.attributes = t_params

      user_ticket_action = @ticket.user_ticket_actions.last
      user_ticket_action.user_assign_ticket_actions.first.regional_support_center_job = @ticket.regional_support_job
      user_assign_ticket_action = user_ticket_action.user_assign_ticket_actions.first
      h_assign_regional_support_center = user_ticket_action.assign_regional_support_centers.first

      user_ticket_action.assign_regional_support_centers.reload unless !user_assign_ticket_action.recorrection and user_assign_ticket_action.regional_support_center_job

      if @ticket.save

        @ticket.update status_id: TicketStatus.find_by_code("ASN").id



        if !user_assign_ticket_action.recorrection and user_assign_ticket_action.regional_support_center_job

          regional_ticket_user_action = @ticket.user_ticket_actions.create(action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count, action_id: TaskAction.find_by_action_no(4).id) #assign regional support center action.          
          h_assign_regional_support_center.update(ticket_action_id: regional_ticket_user_action.id)

        end

        if !user_assign_ticket_action.recorrection
          @ticket.update owner_engineer_id: user_assign_ticket_action.assign_to
        end


        # bpm output variables
        d2_recorrection = user_assign_ticket_action.recorrection ? "Y" : "N"
        d3_regional_support_job = user_assign_ticket_action.regional_support_center_job ? "Y" : "N"
        supp_engr_user = user_assign_ticket_action.assign_to
        supp_hd_user = @ticket.created_by

        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: {d2_re_correction: d2_recorrection, d3_regional_support_job: d3_regional_support_job, supp_engr_user: supp_engr_user, supp_hd_user: supp_hd_user}

        if bpm_response[:status].upcase == "SUCCESS"
          @flash_message = "Successfully updated."
        else
          @flash_message = "ticket is updated. but Bpm error"
        end
      end
    end
    # redirect_to todos_url, notice: @flash_message
    redirect_to @ticket, notice: @flash_message
  end

  def pop_approval
    ContactNumber
    QAndA
    TaskAction
    @ticket = Ticket.find_by_id params[:ticket_id]
    @new_warranty = Warranty.new
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])
      @histories = Rails.cache.fetch([:histories, session[:product_id]]){Kaminari.paginate_array(@product.tickets)}.page(params[:page]).per(2)

      @join_tickets = Rails.cache.fetch([:join, @ticket.id]){Kaminari.paginate_array(Ticket.where(id: @ticket.joint_tickets.map(&:joint_ticket_id)))}.page(params[:page]).per(2)

      @q_and_answers = Rails.cache.fetch([:q_and_answers, @ticket.id]){ @ticket.q_and_answers.group_by{|a| a.q_and_a && a.q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"Problematic Questions" => v})} }

      @ge_q_and_answers = Rails.cache.fetch([:ge_q_and_answers, @ticket.id]){ @ticket.ge_q_and_answers.group_by{|ge_a| ge_a.ge_q_and_a && ge_a.ge_q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"General Questions" => v})} }

      @user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(2).id)
      @user_assign_ticket_action = @user_ticket_action.user_assign_ticket_actions.build
      @assign_regional_support_center = @user_ticket_action.assign_regional_support_centers.build
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/pop_approval"}
    end
  end

  def update_pop_approval
    TaskAction
    Warranty
    t_params = ticket_params.except('products_attributes')
    product_params = ticket_params["products_attributes"]
    product_id = product_params.keys.first

    @ticket = Ticket.find params[:ticket_id]
    @product = Product.find product_id

    @ticket.attributes = t_params

    # product_params[product_id]["pop_note"] = product_params[product_id]["pop_note"].present? ? "#{product_params[product_id]["pop_note"]} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@product.pop_note}" : @product.pop_note


    @product.attributes = product_params[product_id]

    @product.pop_note = "#{@product.pop_note} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@product.pop_note_was}" if @product.pop_note_changed?
    warranty_constraint = true

    if ["CW", "MW"].include?(@ticket.warranty_type.code)
      warranty_constraint = @product.warranties.select{|w| w.warranty_type_id == @ticket.warranty_type_id and (w.start_at.to_date..w.end_at.to_date).include?(Date.today)}.present?
    end

    if warranty_constraint
      @ticket.save
      @product.save

      if params["pop_completed"]

        user_ticket_action = @ticket.user_ticket_actions.create(action_id: TaskAction.find_by_action_no(62).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)

        # calling bpm
        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: {}

        if bpm_response[:status].upcase == "SUCCESS"
          @flash_message = "Successfully updated."
        else
          @flash_message = "ticket is updated. but Bpm error"
        end
      end

      redirect_to @ticket, notice: @flash_message
    else
      redirect_to pop_approval_tickets_path, notice: "There are no present #{@ticket.warranty_type.name} for the product to initiate particular warranty related ticket.')"  
    end
  end

  def resolution
    Inventory
    Warranty
    ContactNumber
    QAndA
    TaskAction
    ticket_id = (params[:ticket_id] or session[:ticket_id])
    @ticket = Ticket.find_by_id ticket_id
    session[:ticket_id] = @ticket.id
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])
      @histories = Rails.cache.fetch([:histories, session[:product_id]]){Kaminari.paginate_array(@product.tickets)}.page(params[:page]).per(2)
      @join_tickets = Rails.cache.fetch([:join, @ticket.id]){Kaminari.paginate_array(Ticket.where(id: @ticket.joint_tickets.map(&:joint_ticket_id)))}.page(params[:page]).per(2)
      @q_and_answers = @ticket.q_and_answers.group_by{|a| a.q_and_a && a.q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"Problematic Questions" => v})}
      @ge_q_and_answers = @ticket.ge_q_and_answers.group_by{|ge_a| ge_a.ge_q_and_a && ge_a.ge_q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"General Questions" => v})}
      @user_ticket_action = @ticket.user_ticket_actions.build(action_id: 2)
      @user_assign_ticket_action = @user_ticket_action.user_assign_ticket_actions.build
      @assign_regional_support_center = @user_ticket_action.assign_regional_support_centers.build

      @ge_questions = GeQAndA.where(action_id: 5)
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/resolution"}
    end
  end

  def edit_ticket
    ContactNumber
    QAndA
    TaskAction
    @ticket = Ticket.find_by_id params[:ticket_id]
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])
      @histories = Rails.cache.fetch([:histories, session[:product_id]]){Kaminari.paginate_array(@product.tickets)}.page(params[:page]).per(2)
      @join_tickets = Rails.cache.fetch([:join, @ticket.id]){Kaminari.paginate_array(Ticket.where(id: @ticket.joint_tickets.map(&:joint_ticket_id)))}.page(params[:page]).per(2)
      @q_and_answers = @ticket.q_and_answers.group_by{|a| a.q_and_a && a.q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"Problematic Questions" => v})}
      @ge_q_and_answers = @ticket.ge_q_and_answers.group_by{|ge_a| ge_a.ge_q_and_a && ge_a.ge_q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"General Questions" => v})}
      @user_ticket_action = @ticket.user_ticket_actions.build(action_id: 2)
      @user_assign_ticket_action = @user_ticket_action.user_assign_ticket_actions.build
      @assign_regional_support_center = @user_ticket_action.assign_regional_support_centers.build
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/edit_ticket"}
    end
  end

  def estimate_job
    ContactNumber
    QAndA
    TaskAction
    TicketEstimation
    @ticket = Ticket.find_by_id params[:ticket_id]
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])
      @histories = Rails.cache.fetch([:histories, session[:product_id]]){Kaminari.paginate_array(@product.tickets)}.page(params[:page]).per(2)
      @join_tickets = Rails.cache.fetch([:join, @ticket.id]){Kaminari.paginate_array(Ticket.where(id: @ticket.joint_tickets.map(&:joint_ticket_id)))}.page(params[:page]).per(2)
      @q_and_answers = @ticket.q_and_answers.group_by{|a| a.q_and_a && a.q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"Problematic Questions" => v})}
      @ge_q_and_answers = @ticket.ge_q_and_answers.group_by{|ge_a| ge_a.ge_q_and_a && ge_a.ge_q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"General Questions" => v})}

    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/estimate_job"}
    end
  end

  def deliver_unit
    ContactNumber
    QAndA
    TaskAction
    TicketSparePart
    @ticket = Ticket.find_by_id params[:ticket_id]
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])
      @histories = Rails.cache.fetch([:histories, session[:product_id]]){Kaminari.paginate_array(@product.tickets)}.page(params[:page]).per(2)
      @join_tickets = Rails.cache.fetch([:join, @ticket.id]){Kaminari.paginate_array(Ticket.where(id: @ticket.joint_tickets.map(&:joint_ticket_id)))}.page(params[:page]).per(2)
      @q_and_answers = @ticket.q_and_answers.group_by{|a| a.q_and_a && a.q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"Problematic Questions" => v})}
      @ge_q_and_answers = @ticket.ge_q_and_answers.group_by{|ge_a| ge_a.ge_q_and_a && ge_a.ge_q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"General Questions" => v})}

    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/deliver_unit"}
    end
  end

  def after_printer

    case params[:ticket_action]
    when "print_ticket"
      @ticket = Ticket.find(params[:print_object_id])
      @ticket.update_attribute(:ticket_print_count, (@ticket.ticket_print_count+1))
      @ticket.user_ticket_actions.create(action_id: TaskAction.find_by_action_no(68).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
    when "ticket_complete"
      @ticket = Ticket.find(params[:print_object_id])
      # @ticket.user_ticket_actions.create(action_id: TAskAction.find_by_action_no(68).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
    when "print_fsr"
      @ticket_fsr = TicketFsr.find(params[:print_object_id])
      @ticket_fsr.update_attribute(:print_count, (@ticket_fsr.print_count+1))

      user_ticket_action = @ticket_fsr.ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(70).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket_fsr.ticket.re_open_count)
      user_ticket_action.build_act_fsr(print_fsr: true, fsr_id: @ticket_fsr.id)

      user_ticket_action.save

    when "print_invoice"
      "as"
      # invoice_id, references spt_invoice
    end
    render nothing: true
  end

  def get_template
    print_object = case params[:print_object]
    when "ticket"
      Ticket.find_by_id params[:print_object_id]
    when "fsr"
      TicketSparePart
      TicketFsr.find_by_id params[:print_object_id]
    end
    print_template_object = PrintTemplate.first
    print_template = print_template_object.try(params[:print_object].to_sym) # example :ticket, :fsr
    request_type = print_template_object.try(params[:request_type].to_sym) # example ticket_request_type
    url = INOCRM_CONFIG["printer_url"]
    request_printer_template = view_context.request_printer_application(request_type, view_context.send(params[:tag_value], print_object), print_template) # print_ticket_tag_value
    render json: {request_printer_template: request_printer_template, url: url}
  end

  def workflow_diagram
    @ticket_id = params[:ticket_id]
    @ticket = Ticket.find @ticket_id
    @workflow_processes = @ticket.ticket_workflow_processes.to_a
    @workflow_process_ids = @workflow_processes.map { |p| p.process_id }
    @task_list = []
    @workflow_process_ids.each do |workflow_process_id|

      ["Ready", "InProgress", "Reserved"].each do |status|
        @task_list << view_context.send_request_process_data(task_list: true, status: status, process_instance_id: workflow_process_id, query: {})
      end

    end

    @task_content = @task_list.map { |list| list[:content] and (list[:content]["task_summary"].is_a?(Hash) ? [{list[:content]["task_summary"]["name"] => list[:content]["task_summary"]["created_on"]}] : list[:content]["task_summary"].map{|l| {l["name"] => l["created_on"]}}) }

    render "tickets/tickets_pack/workflow_index", layout: "workflow_diagram"
  end

  def call_resolution_template
    TaskAction
    TicketSparePart
    @call_template = params[:call_template]
    @ticket = Ticket.find session[:ticket_id]
    @user_ticket_action = @ticket.user_ticket_actions.build
    case @call_template
    when "re_assign"
      @re_assign_request = @user_ticket_action.build_ticket_re_assign_request
    when "action_taken"
      @ticket_action_taken = @user_ticket_action.build_ticket_action_taken
    when "hp_case_id"
      @hp_case = @user_ticket_action.build_hp_case
    when "resolved_job"
      @ticket_finish_job = @user_ticket_action.build_ticket_finish_job
    when "terminate_job"
      @ticket_terminate_job = @user_ticket_action.build_ticket_terminate_job
    when "hold"
      @act_hold = @user_ticket_action.build_act_hold
    when "create_fsr"
      @ticket_fsr = @ticket.ticket_fsrs.build
      @user_ticket_action.build_act_fsr
    when "edit_fsr"
      @select_fsrs = @ticket.ticket_fsrs
      if params[:select_fsr_id]
        @ticket_fsr = @ticket.ticket_fsrs.find_by_id(params[:select_fsr_id])
        @display_form = true
      end
    when "recieve_unit"
      @recieve_unit = @ticket.ticket_deliver_units.where(received: false).first
    when "deliver_unit"
      TicketEstimation
      @ticket_deliver_unit = @ticket.ticket_deliver_units.build
      @report_bys = @ticket.ticket_estimation_externals.select{|ts| (ts.ticket_estimation.status_id == EstimationStatus.find_by_code("EST").id) and (ts.ticket_estimation.cust_approved or ( !ts.ticket_estimation.cust_approval_required and ts.ticket_estimation.approved ) or ( !ts.ticket_estimation.cust_approval_required and !ts.ticket_estimation.approval_required ))}.map { |ts| [ts.organization.name, ts.organization.id] }

    when "edit_serial_no_request"
      @serial_request = @user_ticket_action.build_serial_request
    when "job_estimation_request"
      @ticket_estimation = @ticket.ticket_estimations.build
      @user_ticket_action.build_job_estimation

    when "request_spare_part"
      session[:store_id] = nil
      session[:inv_product_id] = nil
      session[:mst_store_id] = nil
      session[:mst_inv_product_id] = nil

      @ticket_spare_part = @ticket.ticket_spare_parts.build
    when "request_on_loan_spare_part"
      session[:store_id] = nil
      session[:inv_product_id] = nil
      session[:mst_store_id] = nil
      session[:mst_inv_product_id] = nil

      @ticket_on_loan_spare_part = @ticket.ticket_on_loan_spare_parts.build
    end
  end

  def update_start_action

    TaskAction
    continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if continue
      if @ticket.update(append_remark_ticket_params(@ticket))
        @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(5).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)

        @ticket.ticket_status_resolve = TicketStatusResolve.find_by_code("NAP")
        @ticket.ticket_status = TicketStatus.find_by_code("RSL")

        @ticket.save

        # bpm output variables

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id)

        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if bpm_response[:status].upcase == "SUCCESS"
          @flash_message = "Successfully updated."
        else
          @flash_message = "ticket is updated. but Bpm error"
        end

        redirect_to @ticket, notice: @flash_message
      else
        redirect_to @ticket, notice: "start action failed to updated."
      end
    else
      redirect_to todos_url, notice: @flash_message
    end
  end

  def update_change_ticket_cus_warranty
    Warranty

    warranty_constraint = true
    warranty_id = ticket_params[:warranty_type_id].to_i

    if [1, 2].include?(warranty_id)
      warranty_constraint = @ticket.products.first.warranties.select{|w| w.warranty_type_id == warranty_id and (w.start_at.to_date..w.end_at.to_date).include?(Date.today)}.present?
    end

    if warranty_constraint
      if @ticket.update append_remark_ticket_params(@ticket)
        user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(72).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
        user_ticket_action.build_action_warranty_repair_type(ticket_warranty_type_id: @ticket.warranty_type_id, cus_chargeable: @ticket.cus_chargeable)

        @ticket.save

        redirect_to resolution_tickets_url, notice: "Ticket Warranty Type and Customer Chargeable Updated."
      else
        redirect_to resolution_tickets_url(process_id: params[:process_id], task_id: params[:task_id], owner: params[:owner], ticket_id: @ticket.id, supp_engr_user: params[:supp_engr_user]), notice: "Ticket Warranty Type and Customer Chargeable faild to Updated."
      end
    else
      redirect_to resolution_tickets_url, alert: "Selected warranty is not presently applicable to ticket."
    end

  end

  def update_change_ticket_repair_type
    if @ticket.update append_remark_ticket_params(@ticket)
      user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(73).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
      user_ticket_action.build_action_warranty_repair_type(ticket_repair_type_id: @ticket.repair_type_id)

      redirect_to ticket_url(@ticket), notice: "ticket repair type is updated." if @ticket.save
    else
      redirect_to ticket_url(@ticket), notice: "ticket repair type is faild to updated."
    end
  end

  def update_re_assign
    continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if continue
      if @ticket.update append_remark_ticket_params(@ticket)

        # bpm output variables

        bpm_variables = view_context.initialize_bpm_variables.merge(d4_job_complete: "Y", d5_re_assigned: "Y")

        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if bpm_response[:status].upcase == "SUCCESS"
          @flash_message = "Successfully updated."
        else
          @flash_message = "ticket is updated. but Bpm error"
        end

        redirect_to @ticket, notice: @flash_message
      else
        redirect_to @ticket, alert: @flash_message
      end    
    else
      redirect_to @ticket, alert: @flash_message
    end
  end

  def update_hold
    TaskAction
 
    if @ticket.update append_remark_ticket_params(@ticket)

      act_hold = @ticket.user_ticket_actions.last.act_hold

      @ticket.hold_reason_id = act_hold.reason_id
      @ticket.last_hold_action_id = act_hold.user_ticket_action.id

      @ticket.save
      act_hold.update_attribute(:sla_pause, act_hold.reason.sla_pause)

      redirect_to @ticket, notice: "Ticket is successfully updated."
    else
      redirect_to @ticket, alert: "Ticket is failed to update."
    end
  end

  def update_un_hold

    if @ticket.update ticket_params

      user_ticket_action = @ticket.user_ticket_actions.find_by_id(@ticket.last_hold_action_id)

      user_ticket_action.act_hold.update(un_hold_action_id: @ticket.user_ticket_actions.last.id)

      redirect_to @ticket, notice: "Ticket is successfully updated."
    else
      redirect_to @ticket, alert: "Ticket is failed to update."
    end
  end

  def update_create_fsr
    TicketSparePart

    @ticket.attributes = ticket_params
    user_ticket_action = @ticket.user_ticket_actions.last
    # @ticket.user_ticket_actions.reload
    ticket_fsr = @ticket.ticket_fsrs.last
    ticket_fsr.save
    last_ticket_fsr = @ticket.ticket_fsrs.last
    act_fsr = user_ticket_action.act_fsr
    act_fsr.fsr_id = ticket_fsr.id

    user_ticket_action.save
    print_fsr = false

    if act_fsr and act_fsr.print_fsr
      user_ticket_action1 = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(70).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
      user_ticket_action1.build_act_fsr(fsr_id: act_fsr.ticket_fsr.id)
      user_ticket_action1.save
      print_fsr = true
    end
    if request.xhr?
      render json: {print_fsr: print_fsr, fsr_id: last_ticket_fsr.id, ticket_id: @ticket.id}
    else
      redirect_to @ticket, notice: "Ticket is successfully to update."
    end
  end

  def update_edit_fsr
    TicketSparePart
    t_params = ticket_fsr_params
    @ticket_fsr = @ticket.ticket_fsrs.find_by_id params[:ticket_fsr_id]
    t_params["resolution"] = t_params["resolution"].present? ? "#{t_params['resolution']} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@ticket_fsr.resolution}" : @ticket_fsr.resolution

    t_params["ticket_attributes"]["remarks"] = t_params["ticket_attributes"]["remarks"].present? ? "#{t_params['ticket_attributes']['remarks']} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@ticket.remarks}" : @ticket.remarks

    if @ticket_fsr.update t_params
      user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(12).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
      user_ticket_action.build_act_fsr(print_fsr: false, fsr_id: @ticket_fsr.id)

      user_ticket_action.save

      redirect_to @ticket, notice: "Successfully updated."
    else
      redirect_to @ticket, alert: "Unable to update. Please try again with fields validation."
    end
  end

  def update_terminate_job
    TaskAction
    continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if continue
      if @ticket.update append_remark_ticket_params(@ticket)

        # bpm output variables
          # Set (D4) d4_job_Complete = true, 
          # (D8) d8_job_finished =  true,
          # DB.spt_ticket.job_finished=true, 
          # (D11) d11_terminate_job = true, 
          # if DB.spt_ticket.ticket_type_id=IH (in House) then (D9)  d9_qc_required= true, 
          # DB.spt_ticket.cus_payment_required=true, 
          # if (DB.spt_ticket.cus_chargable or DB.spt_ticket.cus_payment_required) then (D10) d10_job_estimate_required_final = true, 
          # if (DB.spt_ticket.cus_chargable or DB.spt_ticket.cus_payment_required) then (D12) d12_need_to_invoice = true, 
          # if (FSR,Count>0 or Parts.count>0) then (D6) d6_close_approval_ required  = true and DB.spt_ticket.ticket_close_approval_required = true, 
          # DB.spt_ticket.status_resolve_id =  TER(Terminated) and 
          # if DB.spt_ticket.ticket_type_id=IH (in House) then DB.spt_ticket.status_id=  QCT (Quality Control) Else if (D10) d10_job_estimate_required_final = true then DB.spt_ticket.status_id=  PMT (Final Payment Calculation) else DB.spt_ticket.status_id=  CFB (Customer Feedback). 
          # Set Action (7) Terminate Job, DB.spt_act_terminate_job, DB.spt_act_terminate_job_payment.

        @ticket.job_finished = true
        @ticket.cus_payment_required = true
        @ticket.ticket_close_approval_required = (@ticket.ticket_spare_parts.any? or @ticket.ticket_fsrs.any?)
        @ticket.ticket_status_resolve = TicketStatusResolve.find_by_code("TER")
        if @ticket.ticket_type.code == "IH"
          @ticket.ticket_status = TicketStatus.find_by_code("QCT")

        elsif (@ticket.cus_chargeable or @ticket.cus_payment_required)
          @ticket.ticket_status = TicketStatus.find_by_code("PMT")

        else
          @ticket.ticket_status = TicketStatus.find_by_code("CFB")

        end

        @ticket.save

        bpm_variables = view_context.initialize_bpm_variables.merge(d4_job_complete: "Y", d8_job_finished: "Y", d11_terminate_job:  "Y", d9_qc_required:(@ticket.ticket_type.code == "IH" ? "Y" : "N"), d10_job_estimate_required_final: ((@ticket.cus_chargeable or @ticket.cus_payment_required) ? "Y" : "N"), d12_need_to_invoice: ((@ticket.cus_chargeable or @ticket.cus_payment_required) ? "Y" : "N"), d6_close_approval_required: ((@ticket.ticket_fsrs.any? or @ticket.ticket_spare_parts.any?) ? "Y" : "N"))

        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if bpm_response[:status].upcase == "SUCCESS"
          @flash_message = "Successfully updated."
        else
          @flash_message = "ticket is updated. but Bpm error"
        end

        redirect_to @ticket, notice: @flash_message
      else
        redirect_to @ticket, alert: "Unable to save ticket"
      end    
    else
      redirect_to @ticket, alert: @flash_message
    end
  end

  def update_action_taken

    TaskAction
    continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if continue
      if @ticket.update append_remark_ticket_params(@ticket)

        # bpm output variables

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id, d7_close_approval_requested: (@ticket.ticket_close_approval_requested ? "Y" : "N") )

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

        @ticket.user_ticket_actions.create(action_id: TaskAction.find_by_action_no(55).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count) if @ticket.ticket_close_approval_requested

        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if bpm_response[:status].upcase == "SUCCESS"
          @flash_message = "Successfully updated."
        else
          @flash_message = "ticket is updated. but Bpm error"
        end
      else
        @flash_message = "ticket is failed to updated."
      end
    else
      @flash_message = @flash_message
    end
    redirect_to @ticket, notice: @flash_message
  end

  def update_resolved_job
    TaskAction
    TicketSparePart
    continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if continue
      if @ticket.update append_remark_ticket_params(@ticket)

        # bpm output variables
          # (D4)d4_Job_Completed = true,
          # (D8) d8_job_finished =  true,
          # if DB.spt_ticket.ticket_type_id=IH (in House) then (D9) d9_qc_required = true, 
          # if DB.spt_ticket.cus_chargeable=true(chargable) then (D10) d10_job_estimate_required_final = true, 
          # if DB.spt_ticket.cus_chargeable=true (chargable) then (D12) d12_need_to_invoice = true,  
          # if (FSR,Count>0 or Parts.count>0) then (D6) d6_close_approval_ required  = true and DB.spt_ticket.ticket_close_approval_required = true, 

          # Set DB.spt_ticket.status_resolve_id=  RSV (Resolved) 
          # if DB.spt_ticket.ticket_type_id=IH (in House) then DB.spt_ticket.status_id=  QCT (Quality Control) Else if (D10) d10_job_estimate_required_final = true then DB.spt_ticket.status_id=  PMT (Final Payment Calculation) else DB.spt_ticket.status_id=  CFB (Customer Feedback).
          #  Set Action (21) Resolve the Job (Finish the Job), DB.spt_act_finish_job.

          # if "Request to close the ticket" is checked then Set (D7) d7_close_approval_requested = true and DB.spt_ticket.ticket_close_approval_requested = true and Set Action (55) Request to Close Ticket.

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id, d7_close_approval_requested: (@ticket.ticket_close_approval_requested ? "Y" : "N"), d4_job_complete: "Y", d8_job_finished: "Y", d9_qc_required: (@ticket.ticket_type.code == "IH" ? "Y" : "N"), d10_job_estimate_required_final: (@ticket.cus_chargeable ? "Y" : "N"), d12_need_to_invoice: (@ticket.cus_chargeable ? "Y" : "N"), d6_close_approval_required: ((@ticket.ticket_fsrs.any? or @ticket.ticket_spare_parts.any?) ? "Y" : "N"))

        @ticket.ticket_close_approval_required = (@ticket.ticket_fsrs.any? or @ticket.ticket_spare_parts.any?)
        @ticket.ticket_status_resolve = TicketStatusResolve.find_by_code("RSV")


        if @ticket.ticket_type.code == "IH"
          @ticket.ticket_status = TicketStatus.find_by_code("QCT")
        elsif @ticket.cus_chargeable
          @ticket.ticket_status = TicketStatus.find_by_code("PMT")
        else
          @ticket.ticket_status = TicketStatus.find_by_code("CFB") 
        end  

        @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(55).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count) if @ticket.ticket_close_approval_requested

        @ticket.save

        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if bpm_response[:status].upcase == "SUCCESS"
          @flash_message = "Successfully updated."
        else
          @flash_message = "ticket is updated. but Bpm error"
        end
      else
        @flash_message = "ticket is failed to updated."
      end
    else
      @flash_message = @flash_message
    end
    redirect_to @ticket, notice: @flash_message
  end

  def update_hp_case_id

    TaskAction
    continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if continue
      if @ticket.update append_remark_ticket_params(@ticket)

        # bpm output variables

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id)

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if bpm_response[:status].upcase == "SUCCESS"
          @flash_message = "Successfully updated."
        else
          @flash_message = "ticket is updated. but Bpm error"
        end
      else
        @flash_message = "ticket is failed to updated."
      end
    else
      @flash_message = @flash_message
    end
    redirect_to @ticket, notice: @flash_message
  end

  def update_edit_serial_no_request

    TaskAction
    continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if continue
      if @ticket.update append_remark_ticket_params(@ticket)

        # bpm output variables

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id, d21_edit_serial_no: "Y")

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if bpm_response[:status].upcase == "SUCCESS"
          @flash_message = "Successfully updated."
        else
          @flash_message = "ticket is updated. but Bpm error"
        end
      else
        @flash_message = "ticket is failed to updated."
      end
    else
      @flash_message = @flash_message
    end
    redirect_to @ticket, notice: @flash_message
  end

  def update_deliver_unit
    TaskAction
    continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if continue

      t_params = ticket_params
      t_params["remarks"] = t_params["remarks"].present? ? "#{t_params['remarks']} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@ticket.remarks}" : @ticket.remarks

      @ticket.attributes = t_params
      ticket_deliver_unit = @ticket.ticket_deliver_units.last

      ticket_deliver_unit.note = "#{ticket_deliver_unit.note} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{ticket_deliver_unit.note_was}" if ticket_deliver_unit and ticket_deliver_unit.note.present?

      if @ticket.save
        ticket_deliver_unit = @ticket.ticket_deliver_units.last
        user_ticket_action = @ticket.user_ticket_actions.last
        user_ticket_action.build_deliver_unit(ticket_deliver_unit_id: ticket_deliver_unit.id)
        user_ticket_action.save

        # bpm output variables

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id, d22_deliver_unit: "Y", deliver_unit_id: ticket_deliver_unit.id, d23_delivery_items_pending: "N")

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        ticket_bpm_headers params[:process_id], @ticket.id, ""

        if bpm_response[:status].upcase == "SUCCESS"
          @flash_message = "Successfully updated."
        else
          @flash_message = "ticket is updated. but Bpm error"
        end

      else
        @flash_message = "Unsuccessfully updated."
      end
    else
      @flash_message = @flash_message
    end
    redirect_to @ticket, notice: @flash_message
  end

  def update_recieve_unit
    ticket_delivery_unit_id = ticket_params["ticket_deliver_units_attributes"]["0"]["id"]

    t_params = ticket_params
    t_params["remarks"] = t_params["remarks"].present? ? "#{t_params['remarks']} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@ticket.remarks}" : @ticket.remarks

    @ticket.attributes = t_params
    ticket_deliver_unit = @ticket.ticket_deliver_units.find_by_id ticket_delivery_unit_id

    ticket_deliver_unit.note = "#{ticket_deliver_unit.note} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{ticket_deliver_unit.note_was}" if ticket_deliver_unit and ticket_deliver_unit.note.present?

    if @ticket.save
      user_ticket_action = @ticket.user_ticket_actions.last
      user_ticket_action.build_deliver_unit(ticket_deliver_unit_id: ticket_deliver_unit.id)
      user_ticket_action.save
      @flash_message = "Successfully updated."
    else
      @flash_message = "Un successfully updated."
    end
    redirect_to @ticket, notice: @flash_message
  end

  def update_job_estimation_request
    TaskAction
    continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if continue

      if @ticket.update append_remark_ticket_params(@ticket)

        user_ticket_action = @ticket.user_ticket_actions.last
        job_estimate = user_ticket_action.job_estimation
        ticket_estimation = @ticket.ticket_estimations.last

        job_estimate.note = ticket_estimation.note
        job_estimate.save

        ticket_estimation.ticket_estimation_externals.build(ticket_id: @ticket.id, repair_by_id: job_estimate.supplier_id)
        ticket_estimation.save

        # bpm output variables

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id, d13_job_estimate_requested_external: "Y")

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"
        @ticket.update_attribute(:status_resolve_id, TicketStatusResolve.find_by_code("ERQ").id)

        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if bpm_response[:status].upcase == "SUCCESS"
          @flash_message = {notice: "Successfully updated."}
        else
          @flash_message = {alert: "ticket is updated. but Bpm error"}
        end

      else
        @flash_message = {alert: "Unable to update."}
      end
    else
      @flash_message = @flash_message
    end
    redirect_to @ticket, @flash_message
  end

  def update_request_spare_part

    TaskAction
    WorkflowMapping
    continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if continue
      f_ticket_spare_part_params = ticket_spare_part_params
      f_ticket_spare_part_params[:ticket_attributes][:remarks] = f_ticket_spare_part_params[:ticket_attributes][:remarks].present? ? "#{f_ticket_spare_part_params[:ticket_attributes][:remarks]} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@ticket.remarks}" : @ticket.remarks
      @ticket_spare_part = TicketSparePart.new f_ticket_spare_part_params
      action_id = ""
      if @ticket_spare_part.save

        SparePartDescription.find_or_create_by(description: @ticket_spare_part.spare_part_description)

        if @ticket_spare_part.request_from == "M"

          # @ticket_spare_part.update_attribute :status_action_id, SparePartStatusAction.find_by_code("RQT").id        

          action_id = TaskAction.find_by_action_no(14).id
          @ticket_spare_part.create_ticket_spare_part_manufacture(payment_expected_manufacture: 0, manufacture_currency_id: @ticket_spare_part.ticket.manufacture_currency_id)
        elsif @ticket_spare_part.request_from == "S"

          @ticket_spare_part.update_attribute :status_action_id, SparePartStatusAction.find_by_code("STR").id unless @ticket_spare_part.cus_chargeable_part
          action_id = TaskAction.find_by_action_no(15).id

          @ticket_spare_part_store = @ticket_spare_part.create_ticket_spare_part_store(store_id: params[:store_id], inv_product_id: params[:inv_product_id], mst_inv_product_id: params[:mst_inv_product_id], estimation_required: @ticket_spare_part.cus_chargeable_part, part_of_main_product: (params[:part_of_main_product] || 0), store_requested: !@ticket_spare_part.cus_chargeable_part, store_requested_at: ( !@ticket_spare_part.cus_chargeable_part ? DateTime.now : nil), store_requested_by: ( !@ticket_spare_part.cus_chargeable_part ? current_user.id : nil))
        end
        @ticket_spare_part.ticket_spare_part_status_actions.create(status_id: @ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

        @ticket_spare_part.ticket.update_attribute :status_resolve_id, TicketStatusResolve.find_by_code("POD").id
          
        user_ticket_action = @ticket_spare_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket_spare_part.ticket.re_open_count, action_id: action_id)
        user_ticket_action.build_request_spare_part(ticket_spare_part_id: @ticket_spare_part.id)
        user_ticket_action.save


        if @ticket_spare_part.request_from == "S" and @ticket_spare_part.cus_chargeable_part

          action_id = TaskAction.find_by_action_no(33).id
          user_ticket_action = @ticket_spare_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket_spare_part.ticket.re_open_count, action_id: action_id)
          user_ticket_action.build_request_spare_part(ticket_spare_part_id: @ticket_spare_part.id)

          @ticket_estimation = @ticket_spare_part.ticket.ticket_estimations.build requested_at: DateTime.now, requested_by: current_user.id, approval_required: true, status_id: EstimationStatus.find_by_code("RQS").id, currency_id: @ticket_spare_part.ticket.base_currency_id
          ticket_estimation_part = @ticket_estimation.ticket_estimation_parts.build ticket_id: @ticket_spare_part.ticket.id, ticket_spare_part_id: @ticket_spare_part.id

          user_ticket_action.save
          @ticket_estimation.save

          @ticket_spare_part_store.update_attribute :ticket_estimation_part_id, ticket_estimation_part.id

        end

        # bpm output variables

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id, request_spare_part_id: @ticket_spare_part.id, onloan_request: "N", d15_part_estimate_required: (@ticket_spare_part.cus_chargeable_part ? "Y" : "N"), part_estimation_id: (@ticket_spare_part.cus_chargeable_part ? @ticket_estimation.id : "-"), d16_request_manufacture_part: (@ticket_spare_part.request_from == "M" ? "Y" : "N"), d17_request_store_part: ((@ticket_spare_part.request_from == "S" and !@ticket_spare_part.cus_chargeable_part) ? "Y" : "N"))

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        # bpm output variables
        ticket_id = @ticket.id
        request_spare_part_id = @ticket_spare_part.id
        supp_engr_user = current_user.id
        priority = @ticket.priority

        part_estimation_id = @ticket_estimation.try(:id)

        request_onloan_spare_part_id = "-"
        onloan_request = "N"

        if @ticket_spare_part.request_from == "M"
          # Create Process "SPPT_MFR_PART_REQUEST",

          bpm_response1 = view_context.send_request_process_data start_process: true, process_name: "SPPT_MFR_PART_REQUEST", query: {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, supp_engr_user: supp_engr_user, priority: priority}

        elsif @ticket_spare_part.request_from == "S"
          if @ticket_spare_part.cus_chargeable_part
            # part_estimation_id = DB.spt_ticket_estimation.id,
            # Create Process "SPPT_PART_ESTIMATE"

            bpm_response1 = view_context.send_request_process_data start_process: true, process_name: "SPPT_PART_ESTIMATE", query: {ticket_id: ticket_id, part_estimation_id: part_estimation_id, supp_engr_user: supp_engr_user, priority: priority}
          else
            # Create Process "SPPT_STORE_PART_REQUEST"

            bpm_response1 = view_context.send_request_process_data start_process: true, process_name: "SPPT_STORE_PART_REQUEST", query: {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, request_onloan_spare_part_id: request_onloan_spare_part_id, onloan_request: onloan_request, supp_engr_user: supp_engr_user, priority: priority}
          end
        end

        if bpm_response1[:status].try(:upcase) == "SUCCESS"
          @ticket.ticket_workflow_processes.create(process_id: bpm_response1[:process_id], process_name: bpm_response1[:process_name])
          ticket_bpm_headers bpm_response1[:process_id], @ticket.id, ""
        else
          @bpm_process_error = true
        end

        if bpm_response[:status].upcase == "SUCCESS"
          @flash_message = "Successfully updated."
        else
          @flash_message = "ticket is updated. but Bpm error"
        end
        
        @flash_message = "#{@flash_message} Unable to start new process." if @bpm_process_error

      else
        @flash_message = "Errors in updating. Please re-try."
      end
    else
      @flash_message = @flash_message
    end
    redirect_to @ticket, notice: @flash_message
  end

  def suggesstion_data
    TicketSparePart
    respond_to do |format|
      format.json {render json: SparePartDescription.all.map { |s| s.description }}
    end
  end

  def update_request_on_loan_spare_part
    
    TaskAction
    WorkflowMapping
    continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if continue
      f_ticket_on_loan_spare_part_params = ticket_on_loan_spare_part_params
      f_ticket_on_loan_spare_part_params[:ticket_attributes][:remarks] = f_ticket_on_loan_spare_part_params[:ticket_attributes][:remarks].present? ? "#{f_ticket_on_loan_spare_part_params[:ticket_attributes][:remarks]} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@ticket.remarks}" : @ticket.remarks
      @ticket_on_loan_spare_part = TicketOnLoanSparePart.new f_ticket_on_loan_spare_part_params

      if @ticket_on_loan_spare_part.save

        action_id = TaskAction.find_by_action_no(18).id


        @ticket_on_loan_spare_part.ticket_on_loan_spare_part_status_actions.create(status_id: @ticket_on_loan_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

        @ticket_on_loan_spare_part.ticket.update_attribute :status_resolve_id, TicketStatusResolve.find_by_code("POD").id

        user_ticket_action = @ticket_on_loan_spare_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket_on_loan_spare_part.ticket.re_open_count, action_id: action_id)
        user_ticket_action.build_request_on_loan_spare_part(ticket_on_loan_spare_part_id: @ticket_on_loan_spare_part.id)
        user_ticket_action.save


        # bpm output variables

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id, request_onloan_spare_part_id: @ticket_on_loan_spare_part.id, onloan_request: "Y", d17_request_store_part: "Y")

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

        bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        # bpm output variables
        ticket_id = @ticket.id
        request_spare_part_id = "-"
        supp_engr_user = current_user.id
        priority = @ticket.priority

        part_estimation_id = "-"

        request_onloan_spare_part_id = @ticket_on_loan_spare_part.id
        onloan_request = "Y"

        # Create Process "SPPT_STORE_PART_REQUEST"

        bpm_response1 = view_context.send_request_process_data start_process: true, process_name: "SPPT_STORE_PART_REQUEST", query: {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, request_onloan_spare_part_id: request_onloan_spare_part_id, onloan_request: onloan_request, supp_engr_user: supp_engr_user, priority: priority}


        if bpm_response1[:status].try(:upcase) == "SUCCESS"
          @ticket.ticket_workflow_processes.create(process_id: bpm_response1[:process_id], process_name: bpm_response1[:process_name])
          ticket_bpm_headers bpm_response1[:process_id], @ticket.id, ""
        else
          @bpm_process_error = true
        end

        if bpm_response[:status].upcase == "SUCCESS"
          @flash_message = "Successfully updated."
        else
          @flash_message = "ticket is updated. but Bpm error"
        end

        @flash_message = "#{@flash_message} Unable to start new process." if @bpm_process_error

      else
        @flash_message = "Errors in updating. Please re-try."
      end
    else
      @flash_message = @flash_message
    end
    redirect_to @ticket, notice: @flash_message
  end

  private
    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    def set_organization_for_ticket
      @organization = Organization.owner
    end

    def ticket_params
      params.require(:ticket).permit(:ticket_no, :sla_id, :serial_no, :status_hold, :repair_type_id, :base_currency_id, :ticket_close_approval_required, :ticket_close_approval_requested, :regional_support_job, :job_started_action_id, :job_start_note, :job_started_at, :contact_type_id, :cus_chargeable, :informed_method_id, :job_type_id, :other_accessories, :priority, :problem_category_id, :problem_description, :remarks, :inform_cp, :resolution_summary, :status_id, :ticket_type_id, :warranty_type_id, :status_resolve_id, ticket_deliver_units_attributes: [:deliver_to_id, :note, :created_at, :created_by, :received, :id, :received_at], ticket_accessories_attributes: [:id, :accessory_id, :note, :_destroy], q_and_answers_attributes: [:problematic_question_id, :answer, :ticket_action_id, :id], joint_tickets_attributes: [:joint_ticket_id, :id, :_destroy], ge_q_and_answers_attributes: [:id, :general_question_id, :answer], ticket_estimations_attributes: [:note, :currency_id, :status_id, :requested_at, :requested_by], user_ticket_actions_attributes: [:id, :_destroy, :action_at, :action_by, :action_id, :re_open_index, user_assign_ticket_actions_attributes: [:sbu_id, :_destroy, :assign_to, :recorrection], assign_regional_support_centers_attributes: [:regional_support_center_id, :_destroy], ticket_re_assign_request_attributes: [:reason_id, :_destroy], ticket_action_taken_attributes: [:action, :_destroy], ticket_terminate_job_attributes: [:id, :reason_id, :foc_requested, :_destroy], act_hold_attributes: [:id, :reason_id, :_destroy, :un_hold_action_id], hp_case_attributes: [:id, :case_id, :case_note], ticket_finish_job_attributes: [:resolution, :_destroy], ticket_terminate_job_payments_attributes: [:id, :amount, :payment_item_id, :_destroy, :ticket_id, :currency_id], act_fsr_attributes: [:print_fsr], serial_request_attributes: [:reason], job_estimation_attributes: [:supplier_id]], ticket_extra_remarks_attributes: [:id, :note, :created_by, :extra_remark_id], products_attributes: [:id, :sold_country_id, :pop_note, :pop_doc_url, :pop_status_id], ticket_fsrs_attributes: [:work_started_at, :work_finished_at, :hours_worked, :down_time, :travel_hours, :engineer_time_travel, :engineer_time_on_site, :resolution, :completion_level, :created_by])
    end

    def product_brand_params
      params.require(:product_brand).permit(:sla_id, :name, :parts_return_days, :warenty_date_formate, :currency_id)
    end

    def product_params
      params.require(:product).permit(:serial_no, :pop_doc_url, :product_brand_id, :sold_country_id, :product_category_id, :model_no, :product_no, :pop_status_id, :coparate_product, :pop_note)
    end

    def category_params
      params.require(:product_category).permit(:name, :product_brand_id, :sla_id)
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
      params.require(:problem_category).permit(:name, q_and_as_attributes: [:_destroy, :id, :active, :answer_type, :question, :action_id, :compulsory])
    end

    def accessory_params
      params.require(:accessory).permit(:accessory)
    end

    def product_country_params
      params.require(:product_sold_country).permit(:code, :Country)
    end

    def extra_remark_params
      params.require(:extra_remark).permit(:extra_remark)
    end

    def ticket_fsr_params
      params.require(:ticket_fsr).permit(:travel_hours, :work_started_at, :work_finished_at, :hours_worked, :down_time, :engineer_time_travel, :engineer_time_on_site, :resolution, :completion_level, :remarks, :ticket_id, ticket_attributes: [:remarks, :id])
    end

    def ticket_spare_part_params
      params.require(:ticket_spare_part).permit(:spare_part_no, :spare_part_description, :ticket_id, :ticket_fsr, :cus_chargeable_part, :request_from, :faulty_serial_no, :faulty_ct_no, :note, :status_action_id, :status_use_id, ticket_attributes: [:remarks, :id])
    end

    def ticket_on_loan_spare_part_params
      params.require(:ticket_on_loan_spare_part).permit(:ref_spare_part_id, :note, :ticket_id, :status_action_id, :status_use_id, :store_id, :inv_product_id, :main_inv_product_id, :part_of_main_product, ticket_attributes: [:remarks, :id])
    end

    def ticket_bpm_headers(process_id, ticket_id, spare_part_id)
      TicketSparePart

      @ticket = Ticket.find_by_id(ticket_id)

      if process_id.present? and @ticket.present?
        ticket_no = @ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG["ticket_no_format"])
        ticket_no  = "[#{ticket_no}]"

        customer_name = "#{@ticket.customer.name}".truncate(23)

        terminated = @ticket.ticket_terminated ? "[Terminated]" : ""

        re_open = @ticket.re_open_count > 0 ? "[Re-Open]" : ""

        product_brand = "[#{@ticket.products.first.product_brand.name.truncate(13)}]"

        job_type = "[#{@ticket.job_type.name}]"

        ticket_type = "[#{@ticket.ticket_type.name}]"

        regional = @ticket.regional_support_job ? "[Regional]" : ""

        repair_type = @ticket.repair_type.code == "EX" ? "[#{@ticket.repair_type.name}]" : ""

        delivery_stage = @ticket.ticket_deliver_units.any?{|d| !d.received} ? "[to-be collected]" : (@ticket.ticket_deliver_units.any?{|d| !d.delivered} ? "[to-be delivered]" : "")

        @h1 = "#{ticket_no}#{customer_name}#{terminated}#{re_open}#{product_brand}#{job_type}#{ticket_type}#{regional}#{repair_type}#{delivery_stage}"

        if spare_part_id.present?
          spare_part = @ticket.ticket_spare_parts.find_by_id(spare_part_id)
          store_part = spare_part.ticket_spare_part_store
          # store_part_name = (store_part && store_part.inventory_product) ? store_part.inventory_product.try(:description)) 

          if store_part and store_part.inventory_product
            store_part_name = "[#{store_part.inventory_product.description}]".truncate(18)

            @h2 = "#{ticket_no}#{customer_name}#{store_part_name}#{terminated}#{re_open}#{product_brand}#{job_type}#{ticket_type}#{regional}#{repair_type}"
          else
            @h2 = ""
          end

          if spare_part
            spare_part_name = "[#{spare_part.spare_part_no}-#{spare_part.spare_part_description}]".truncate(18)
            @h3 = "#{ticket_no}#{customer_name}#{spare_part_name}#{terminated}#{re_open}#{product_brand}#{job_type}#{ticket_type}#{regional}#{repair_type}"
          else
            @h3 = ""
          end

        end

        found_process_id = WorkflowHeaderTitle.where(process_id: process_id)
        if found_process_id.present?
          found_process_id.first.update(h1: @h1, h2: @h2, h3: @h3)
        else
          WorkflowHeaderTitle.create(process_id: process_id, h1: @h1, h2: @h2, h3: @h3)
        end
      end

    end

    def append_remark_ticket_params(ticket)
      t_params = ticket_params
      t_params["remarks"] = t_params["remarks"].present? ? "#{t_params['remarks']} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{ticket.remarks}" : ticket.remarks

      t_params

    end
end