class TicketsController < ApplicationController
  before_action :set_ticket, only: [:show, :edit, :update, :destroy]
  before_action :set_organization_for_ticket, only: [:new, :edit, :create_customer]
  # layout :workflow_diagram, only: [:workflow_diagram]

  respond_to :html, :json

  def index
    @tickets = Ticket.order("created_at DESC")
    respond_with(@tickets)

  end

  # available caches
    # new_ticket, ticket_params, histories, existing_customer, new_product_with_pop_doc_url, created_warranty

  def show
    Warranty
    ContactNumber
    QAndA
    @product = @ticket.products.first
    @warranties = @product.warranties
    session[:product_id] = @product.id
    Rails.cache.delete([:histories, session[:product_id]])
    Rails.cache.delete([:join, @ticket.id])
    @histories = Rails.cache.fetch([:histories, session[:product_id]]){Kaminari.paginate_array(@product.tickets.reject{|t| t == @ticket})}.page(params[:page]).per(2)
    @join_tickets = Rails.cache.fetch([:join, @ticket.id]){Kaminari.paginate_array(Ticket.where(id: @ticket.joint_tickets.map(&:joint_ticket_id)))}.page(params[:page]).per(2)
    @q_and_answers = @ticket.q_and_answers.group_by{|a| a.q_and_a && a.q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"Problematic Questions" => v})}
    @ge_q_and_answers = @ticket.ge_q_and_answers.group_by{|ge_a| ge_a.ge_q_and_a && ge_a.ge_q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"General Questions" => v})}
    # @tickets = @ticket.joint_tickets
    # Rails.cache.fetch([:histories, session[:product_id]], Kaminari.paginate_array(@product.tickets)) do
      
    # end
    # @histories = Rails.cache.read([:histories, session[:product_id]]).page(params[:page]).per(3)
    respond_with(@ticket)
  end

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

        # unless @new_ticket.products.present?
        #   @new_ticket.products << @product
        # end

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
    QAndA
    TaskAction
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

    if @ticket.status_id != @status_close_id.try(:id)
      bpm_response = view_context.send_request_process_data process_history: true, process_instance_id: 1, variable_id: "ticket_id"
      if bpm_response[:status].upcase == "ERROR"
        continue = false
        render js: "alert('BPM error. Please continue after rectify BPM.');"
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
        session[:ticket_id] = nil
        session[:product_category_id] = nil
        session[:product_brand_id] = nil
        session[:product_id] = nil
        session[:customer_id] = nil
        session[:serial_no] = nil
        session[:warranty_id] = nil
        session[:ticket_initiated_attributes] = {}
        session[:time_now]= nil

        unless @ticket.status_id == @status_close_id.try(:id)
          # bpm output variables
          ticket_id = @ticket.id
          di_pop_approval_pending = ["RCD", "RPN", "APN", "LPN", "APV"].include?(@ticket.products.first.product_pop_status.try(:code)) ? "Y" : "N"
          priority = @ticket.priority

          bpm_response = view_context.send_request_process_data start_process: true, process_name: "sppt", query: {ticket_id: ticket_id, d1_pop_approval_pending: di_pop_approval_pending, priority: priority}

          if bpm_response[:status].upcase == "SUCCESS"
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
      @q_and_answers = @ticket.q_and_answers.group_by{|a| a.q_and_a && a.q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"Problematic Questions" => v})}
      @ge_q_and_answers = @ticket.ge_q_and_answers.group_by{|ge_a| ge_a.ge_q_and_a && ge_a.ge_q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"General Questions" => v})}
      @user_ticket_action = @ticket.user_ticket_actions.build(action_id: 2)
      @user_assign_ticket_action = @user_ticket_action.user_assign_ticket_actions.build
      @assign_regional_support_center = @user_ticket_action.assign_regional_support_centers.build
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/assign_ticket"}
    end
  end

  def pop_note

  end

  def resolution
    
  end

  def after_printer

    case params[:ticket_action]
    when "print_ticket"
      @ticket = Ticket.find(params[:ticket_id])
      @ticket.update_attribute(:ticket_print_count, (@ticket.ticket_print_count+1))
      @ticket.user_ticket_actions.create(action_id: TaskAction.find_by_action_no(68).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
    when "ticket_complete"
      @ticket = Ticket.find(params[:ticket_id])
      # @ticket.user_ticket_actions.create(action_id: TAskAction.find_by_action_no(68).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
    when "print_fsr"
      "as"
      #fsr_id references spt_ticket_fsr
    when "print_invoice"
      "as"
      # invoice_id, references spt_invoice
    end
    render nothing: true
  end

  def get_template
    print_template = PrintTemplate.first.try(:ticket)
    render json: {print_template: print_template}
  end

  def workflow_diagram
    @ticket_id = params[:ticket_id]
    @ticket = Ticket.find @ticket_id
    @workflow_processes = @ticket.ticket_workflow_processes.to_a
    @workflow_process_ids = @workflow_processes.map { |p| p.process_id }
    @task_list = []
    @workflow_process_ids.each do |workflow_process_id|

      ["InProgress", "Reserved"].each do |status|
        @task_list << view_context.send_request_process_data(task_list: true, status: status, process_instance_id: workflow_process_id, query: {})
      end

    end

    @task_content = @task_list.map { |list| list[:content] and list[:content]["task_summary"]["name"] }

    render "tickets/tickets_pack/workflow_index", layout: "workflow_diagram"
  end

  private
    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    def set_organization_for_ticket
      @organization = Organization.owner
    end

    def ticket_params
      params.require(:ticket).permit(:ticket_no, :sla_id, :serial_no, :base_currency_id, :regional_support_job, :contact_type_id, :cus_chargeable, :informed_method_id, :job_type_id, :other_accessories, :priority, :problem_category_id, :problem_description, :remarks, :inform_cp, :resolution_summary, :status_id, :ticket_type_id, :warranty_type_id, ticket_accessories_attributes: [:id, :accessory_id, :note, :_destroy], q_and_answers_attributes: [:problematic_question_id, :answer, :ticket_action_id, :id], joint_tickets_attributes: [:joint_ticket_id, :id, :_destroy], ge_q_and_answers_attributes: [:id, :general_question_id, :answer], user_ticket_actions_attributes: [:id, :_destroy, :action_at, :action_by, :action_id, :re_open_index, user_assign_ticket_actions_attributes: [:sbu_id, :_destroy, :assign_to, :recorrection], assign_regional_support_centers_attributes: [:regional_support_center_id, :_destroy]], ticket_extra_remarks_attributes: [:id, :note, :created_by, :extra_remark_id])
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

    def ticket_bpm_headers(process_id, ticket_id, spare_part_id)
      # h1 = [Ticket No] Customer Name(Max 20charactors)  [OP:IF terminated :Terminated][OP:If Re-Open-Count>0: RE-OPEN][Product Brand:HP][Job Type:Softwear][Ticket Type:In-House][OP: If Regional: Regional][OP: If Repaire Type = External : External Repaire]  
      # Eg1: [T0012345] Inova IT Systems Pvt [HP][Hardwear][In-House]

      # h2 = [Ticket No] Customer Name(Max 20charactors)  [Stock Part Description (Mac 15 Charactors)][OP:If Re-Open-Count>0: RE-OPEN][Product Brand:HP][Job Type:Softwear][Ticket Type:Inhouse][OP: If Regional: Regional][OP: If Repaire Type = External : External Repaire]
      # Eg1:  [T0012345] Inova IT Systems Pvt [Hard Disc][HP][Hardwear][In-House]

      # h3 = [Ticket No] Customer Name(Max 20charactors)  [Manufacture Part No-Part Description (Mac 15 Charactors)][OP:If Re-Open-Count>0: RE-OPEN][Product Brand:HP][Job Type:Softwear][Ticket Type:Inhouse][OP: If Regional: Regional][OP: If Repaire Type = External : External Repaire]
      # Eg1:  [T0012345] Inova IT Systems Pvt [15896-Battery][HP][Hardwear][In-House]
      @ticket = Ticket.find_by_id(ticket_id)

      if process_id.present? and @ticket.present?
        ticket_no = @ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG["ticket_no_format"])
        ticket_no  = "[#{ticket_no}]"

        customer_name = "#{@ticket.customer.name}".truncate(23)

        terminated = @ticket.terminated ? "[Terminated]" : ""

        re_open = @ticket.re_open_count > 0 ? "[Re-Open]" : ""

        product_brand = "[#{@ticket.products.first.product_brand.name.truncate(13)}]"

        job_type = "[#{@ticket.job_type.name}]"

        ticket_type = "[#{@ticket.ticket_type.name}]"

        regional = @ticket.regional_support_job ? "[Regional]" : ""

        repair_type = @ticket.repair_type.code == "EX" ? "[#{@ticket.repair_type.name}]" : ""

        @h1 = "#{ticket_no}#{customer_name}#{terminated}#{re_open}#{product_brand}#{job_type}#{ticket_type}#{regional}#{repair_type}"

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
end