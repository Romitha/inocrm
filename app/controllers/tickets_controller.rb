class TicketsController < ApplicationController
  # skip_before_action :authenticate_user!, only: [ :update_approve_store_parts ]
  before_action :set_ticket, only: [:show, :edit, :update, :destroy, :update_change_ticket_cus_warranty, :update_change_ticket_repair_type,
    :update_start_action, :update_re_assign, :update_request_close_approval, :update_hold, :update_create_fsr, :update_edit_serial_no_request, :update_edit_fsr,
    :update_terminate_job, :update_action_taken, :update_request_spare_part, :update_request_on_loan_spare_part, :update_hp_case_id, :update_resolved_job, :update_deliver_unit, :update_job_estimation_request, :update_recieve_unit, :update_un_hold, :update_check_fsr, :update_attribute]
  before_action :set_organization_for_ticket, only: [:new, :edit, :create_customer]

  before_action :set_product_in_new_ticket, only: [:create, :save_cache_ticket, :create_accessory, :new_customer, :create_customer, :create_contact_persons, :contact_persons, :create_contact_person_record, :q_and_answer_save, :create_extra_remark, :finalize_ticket_save, :ticket_update]

  # layout :workflow_diagram, only: [:workflow_diagram]

  after_action :update_bpm_header, except: [:update_collect_parts]

  respond_to :html, :json

  def ticket_in_modal

    ct = params[:ct]
    fa = params[:fa]
    if ct == "undefined"
      @ct = ""
    else
      @ct = ct
    end

    if fa == "undefined"
      @fa = ""
    else
      @fa = fa
    end

    ticket_id = params[:ticket_id]
    @ticket = Ticket.find params[:ticket_id]

    ticket_spare_part = TicketSparePart.where("faulty_ct_no like ? and faulty_serial_no like ?", "#{ct}%", "#{fa}%")
    @filtered_ticket_spare_part = ticket_spare_part.select{|s| s.ticket_id != @ticket.id }
    render "tickets/tickets_pack/resolution/ticket_in_modal"
  end

  def index
    @tickets = Ticket.order("created_at DESC")
    respond_with(@tickets)

  end

  def new
    Rails.cache.delete([:new_ticket, request.remote_ip.to_s, session[:time_now]])
    Rails.cache.delete([:ticket_params, request.remote_ip.to_s, session[:time_now]])
    Rails.cache.delete([:histories, request.remote_ip.to_s, session[:time_now]])
    Rails.cache.delete([:existing_customer, request.remote_ip.to_s, session[:time_now]])
    Rails.cache.delete([:ticket_initiated_attributes, session[:time_now]])

    Rails.cache.delete([:ticket_contract, session[:time_now]])

    session[:time_now] = nil
    session[:ticket_id] = nil
    session[:product_category_id] = nil
    session[:product_brand_id] = nil
    session[:product_id] = nil
    session[:customer_id] = nil
    session[:serial_no] = nil
    session[:warranty_id] = nil
    # session[:ticket_initiated_attributes] = {}
    # @ticket_no = (Ticket.any? ? (Ticket.order("created_at ASC").map{|t| t.ticket_no.to_i}.max + 1) : 1)
    @ticket_no = CompanyConfig.first.sup_last_ticket_no.to_i
    @status = TicketStatus.find_by_code("OPN")
    @ticket_logged_at = DateTime.now


    @ticket_time_now = Time.now.strftime("%H%M%S")
    Rails.cache.write([:ticket_initiated_attributes, @ticket_time_now], {ticket_no: @ticket_no, status_id: @status.id, logged_by: current_user.id, logged_at: @ticket_logged_at })

    # session[:ticket_initiated_attributes] = {ticket_no: @ticket_no, status_id: @status.id, logged_by: current_user.id, logged_at: DateTime.now}
    # @ticket = Ticket.new(session[:ticket_initiated_attributes])
    @ticket = Ticket.new Rails.cache.fetch([:ticket_initiated_attributes, @ticket_time_now])

    @ticket.initiated_token = @ticket_time_now

    Rails.cache.write([:new_ticket, request.remote_ip.to_s, @ticket_time_now], @ticket)
    respond_with(@ticket)
  end

  def find_by_serial
    serial_no = params[:serial_search]
    @ticket_time_now = (params[:ticket_time_now] || Time.now.strftime("%H%M%S") )
    if serial_no.blank?
      render js: "alert('Please enter any serial no'); Tickets.remove_ajax_loader();"
    else
      session[:product_id] = nil
      session[:customer_id] ||= nil
      session[:serial_no] = serial_no
      @product = (Product.find_by_serial_no(serial_no) || Product.new(serial_no: serial_no, corporate_product: false))

      @contract = TicketContract.find(params[:contract_id]) if params[:contract_id].present?
      Rails.cache.write([:ticket_contract, @ticket_time_now], @contract)

      Warranty
      #@base_currency = Currency.find_by_base_currency(true)
      if @product.persisted?
        @product_brand = @product.product_brand
        @product_category = @product.product_category
        ticket_attr = (Rails.cache.fetch([:ticket_initiated_attributes, @ticket_time_now]) || {})
        Rails.cache.write([:ticket_initiated_attributes, @ticket_time_now], ticket_attr.merge({sla_id: (@product_category.sla_id || @product_brand.sla_id)}))

        # session[:ticket_initiated_attributes].merge!({sla_id: (@product_category.sla_id || @product_brand.sla_id)})

        session[:product_id] = @product.id

        # @ticket = (Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now]) || Ticket.new(session[:ticket_initiated_attributes]))
        @ticket = (Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now]) || Ticket.new(Rails.cache.fetch([:ticket_initiated_attributes, @ticket_time_now])))

        @ticket.contract_id = @contract.try(:id)

        # @ticket.ticket_accessories.uniq!{|ac| ac.id}
        @customer = @product.tickets.last.try(:customer)
        Rails.cache.write([:histories, @product.id], Kaminari.paginate_array(@product.tickets.reject{|t| t.id==@ticket.id}))
        @histories = Rails.cache.read([:histories, @product.id]).page(params[:page]).per(3)

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

  def create_product
    Ticket
    ContactNumber
    Warranty
    @ticket_time_now = params[:ticket_time_now]

    respond_to do |format|
      if product_params[:pop_doc_url]
        @new_product = Product.new product_params

        Rails.cache.write([:new_product_with_pop_doc_url, request.remote_ip], @new_product)
        format.js {render :new_product}
      else
        if params[:edit]
          @product = Product.find(params[:product_id])
          if @product.update product_params
            params[:edit] = nil
            render json: @product
          else
            render json: @product.errors.full_messages.join
          end
        else
          @new_product = (Rails.cache.read([:new_product_with_pop_doc_url, request.remote_ip]) or Product.new)
          @new_product.attributes = product_params
          if @new_product.save
            Rails.cache.delete([:new_product_with_pop_doc_url, request.remote_ip])
            session[:product_id] = @new_product.id
            @notice = "Great! #{@new_product.serial_no} is saved."
            @product_brand = @new_product.product_brand
            @product_category = @new_product.product_category
            # session[:ticket_initiated_attributes].merge!({sla_id: (@product_category.sla_id || @product_brand.sla_id)})

            ticket_attr = Rails.cache.fetch([:ticket_initiated_attributes, @ticket_time_now ])
            Rails.cache.write([:ticket_initiated_attributes, @ticket_time_now ], ticket_attr.merge({sla_id: (@product_category.sla_id || @product_brand.sla_id)}))

            @product = @new_product
            # @ticket = @product.tickets.build session[:ticket_initiated_attributes]
            @ticket = @product.tickets.build Rails.cache.fetch([:ticket_initiated_attributes, @ticket_time_now])

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
  end

  def update_attribute
    t_params = ticket_params
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

  def new_customer
    User
    ContactNumber
    Warranty
    # @product = Product.find (params[:product_id] || session[:product_id])
    @existing_customer = Rails.cache.fetch([:existing_customer, request.remote_ip.to_s, @ticket_time_now])
    if params[:function_param]
      @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])
      @customers = []
      @organization_customers = []
      @display_select_option = (params[:function_param]=="create")
    elsif params[:select_customer]
      search_customer = params[:search_customer].strip
      customers_nameonly = Customer.where("name like ?", "%#{search_customer}%").where(organization_id: nil)
      customers_nameandnum = ContactTypeValue.where("value like ?", "%#{search_customer}%").map{|c| c.customer if c.customer.organization_id.nil? }.compact
      customers_borth = customers_nameonly + customers_nameandnum
      @customers = Kaminari.paginate_array(customers_borth.uniq).page(params[:page]).per(INOCRM_CONFIG["pagination"]["customer_per_page"])

      org_customers_nameonly = Organization.customers.where("organizations.name like ?", "%#{search_customer}%")
      # org_customers_nameandnum = ContactTypeValue.where("value like ?", "%#{search_customer}%").map{|c| c.customer if c.customer.organization_id.present? }.compact
      org_customers_borth = org_customers_nameonly#.select{|o| o.primary_address.present? }# + org_customers_nameandnum
      @organization_customers = Kaminari.paginate_array(org_customers_borth).page(params[:page]).per(INOCRM_CONFIG["pagination"]["organization_per_page"])
    end
    if params[:customer_id].present?
      existed_customer = Customer.find params[:customer_id]
      existed_customer_attribs = existed_customer.contact_type_values.map{|c| {contact_type_id: c.contact_type_id, value: c.value}}
      @new_customer = Customer.new existed_customer.attributes.except("id")

      @new_customer.contact_type_values.build existed_customer_attribs
    else
      @new_customer = Customer.new
      @new_customer.contact_type_values.build([{contact_type_id: 2}, {contact_type_id: 3}])
    end
    respond_to do |format|
      format.js
    end
  end

  def create
    # Rails.cache.write(:ticket_params, ticket_params)
    # session[:time_now] ||= Time.now.strftime("%H%M%S")
    @new_ticket = (Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now]) || Ticket.new)
    @new_ticket.ticket_accessories.clear
    @new_ticket.attributes = ticket_params

    Rails.cache.write([:new_ticket, request.remote_ip.to_s, @ticket_time_now], @new_ticket)

    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])

    # @product = Product.find params[:product_id]
    @product_brand = @product.product_brand
    @product_category = @product.product_category
    @new_ticket.sla_id = (@product_category.sla_id || @product_brand.sla_id)

    Warranty
    respond_to do |format|

      if @new_ticket.valid?
        # session[:ticket_initiated_attributes] = {}
        Rails.cache.write([:ticket_initiated_attributes, @ticket_time_now], {})

        @notice = "Great! new ticket is initiated."
        Rails.cache.write([:new_ticket, request.remote_ip.to_s, @ticket_time_now], @new_ticket)
        User
        ContactNumber

        @existing_customer = if @new_ticket.ticket_contract.present?
          organization = @new_ticket.ticket_contract.organization
          address = (organization.addresses.primary_address.first || organization.addresses.first)

          if organization.customers.any?
            organization.customers.first

          elsif address.present?
            organization.customers.create(title_id: organization.title_id, name: organization.name, address1: address.address1, address2: address.address2, address3: address.address3, address4: address.city, district_id: address.district_id)

          end

        elsif @product.owner_customer.present?
          organization = @product.owner_customer
          address = (organization.addresses.primary_address.first || organization.addresses.first)

          if organization.customers.any?
            organization.customers.first

          elsif address.present?
            organization.customers.create(title_id: organization.title_id, name: organization.name, address1: address.address1, address2: address.address2, address3: address.address3, address4: address.city, district_id: address.district_id)

          end

        else
          (Customer.find_by_id(session[:customer_id]) || @product.tickets.last.try(:customer))

        end

        Rails.cache.fetch([:existing_customer, request.remote_ip.to_s, @ticket_time_now]){ @existing_customer }
        @new_customer = Customer.new
        @new_customer.contact_type_values.build([{contact_type_id: 2}, {contact_type_id: 4}])
        format.js {render :new_customer}
      else

        # format.js {render :find_by_serial}
        format.js {render js: "alert('Please enter valid and required information.'); Tickets.remove_ajax_loader();"}
      end

    end
  end

  def create_customer
    User
    ContactNumber
    Warranty
    # @product = Product.find (params[:product_id] || session[:product_id])
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])
    respond_to do |format|
      if params[:customer_id].present?
        @new_customer = Customer.find params[:customer_id]
        @ticket.customer_id = @new_customer.id
        @ticket.contact_person1 ||= @product.tickets.last.try(:contact_person1) # (@ticket.ticket_contract and @ticket.ticket_contract.organization.)

        @ticket.contact_person2 ||= @product.tickets.last.try(:contact_person2)
        @ticket.report_person ||= @product.tickets.last.try(:report_person)
        Rails.cache.write([:new_ticket, request.remote_ip.to_s, @ticket_time_now], @ticket)
        session[:customer_id] = @new_customer.id
        @notice = "Great! #{@new_customer.name} is added."

        format.js {render :create_contact_persons}

      elsif params[:organization_id].present?
        organization = Organization.find params[:organization_id]
        if organization.primary_address.present? or organization.addresses.present?
          address = (organization.primary_address or organization.addresses.first)
          @new_customer = Customer.new address.attributes.select{|a| ["address1", "address2", "address3", "district_id"].include? a }
          @new_customer.address4 = address.city
          @new_customer.organization_id = organization.id
          @new_customer.name = organization.name

          if @new_customer.save!
            # @product.update(owner_customer_id: organization.id)
            @product.create_product_owner_history(organization.id, current_user.id, "Added in ticket")
            @ticket.customer_id = @new_customer.id
            contact_person1 = @product.owner_customer.organization_contact_persons.contact_persons1.first
            contact_person2 = @product.owner_customer.organization_contact_persons.contact_persons2.first
            @ticket.contact_person1_id = (contact_person1 and contact_person1.report_persons.first.try(:id))
            @ticket.contact_person2_id = (contact_person2 and contact_person2.report_persons.first.try(:id))
            @ticket.reporter_id = @ticket.contact_person1_id

            contact_type_values = []

            organization.contact_numbers.each do |cn|

              contact_type_id = INOCRM_CONFIG['contact_type_values_map'][cn.organization_contact_type.id]

              contact_type_values << {value: cn.value, contact_type_id: contact_type_id}

            end

            @new_customer.contact_type_values.create! contact_type_values if contact_type_values.present?

            if !@ticket.contact_person1_id.present? and contact_person1.present?
              built_c1 = contact_person1.report_persons.build(title_id: contact_person1.title_id, name: contact_person1.name)
              {email: "E-Mail", mobile: "Mobile", telephone: "Telephone"}.each do |key, value|
                if contact_person1.send(key).present?
                  built_c1_type = built_c1.contact_person_contact_types.build
                  built_c1_type.send("contact_type_id=", ContactType.find_by_name(value).try(:id))
                  built_c1_type.send("value=", contact_person1.send(key))
                end

              end

              built_c1.save!
              @ticket.contact_person1_id = built_c1.id
              @ticket.reporter_id = built_c1.id

            end

            if !@ticket.contact_person2_id.present? and contact_person2.present?
              built_c2 = contact_person2.report_persons.build(title_id: contact_person2.title_id, name: contact_person2.name)
              {email: "E-Mail", mobile: "Mobile", telephone: "Telephone"}.each do |key, value|
                if contact_person2.send(key).present?
                  built_c2_type = built_c2.contact_person_contact_types.build
                  built_c2_type.send("contact_type_id=", ContactType.find_by_name(value).try(:id))
                  built_c2_type.send("value=", contact_person2.send(key))
                end

              end

              built_c2.save!
              @ticket.contact_person2_id = built_c2.id

            end

            session[:customer_id] = @new_customer.id
            Rails.cache.write([:new_ticket, request.remote_ip.to_s, @ticket_time_now], @ticket)
            @notice = "Great! #{@new_customer.name} is saved."
            format.js {render :create_contact_persons}
          else
            @display_select_option = true
            format.js {render :new_customer}
          end
        else
          format.js {render js: "alert('Organizatin must have atleast one address.');"}
        end
      else
        @new_customer = Customer.new customer_params
        if @new_customer.save
          @ticket.customer_id = @new_customer.id
          session[:customer_id] = @new_customer.id
          Rails.cache.write([:new_ticket, request.remote_ip.to_s, @ticket_time_now], @ticket)
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
    # @product = Product.find (params[:product_id] || session[:product_id])
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
      # @contact_person_for_customer = params[:contact_person_id].present? ? Customer.find(params[:contact_person_id]) : Customer.new
      @contact_person_for_customer = params[:contact_person_id].present? ? Organization.find(params[:contact_person_id]) : Customer.new
      @contact_person_attribs = {title_id: @contact_person_for_customer.title_id, name: @contact_person_for_customer.name}
      # @c_p_c_t_attribs = @contact_person_for_customer.contact_type_values.map{|c_t_v| {contact_type_id: c_t_v.contact_type_id, value: c_t_v.value}}
      @c_p_c_t_attribs = []

      @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])
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
      @contact_person_for_customer.new_record? ? @build_contact_person.contact_person_contact_types.build([{contact_type_id: 2}, {contact_type_id: 3}]) : @build_contact_person.contact_person_contact_types.build(@c_p_c_t_attribs)

      # @header = "Contact Person"
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
        @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])
        @ticket.contact_person1_id = @build_contact_person.id
        Rails.cache.write([:new_ticket, request.remote_ip.to_s, @ticket_time_now], @ticket)
        @contact_person_frame = "#contact_persons_form1"
        @submitted_contact_person = "one"

      elsif params[:contact_person] == "2"
        @build_contact_person = ContactPerson2.find(params[:contact_person_id])
        @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])
        @ticket.contact_person2_id = @build_contact_person.id
        Rails.cache.write([:new_ticket, request.remote_ip.to_s, @ticket_time_now], @ticket)
        @contact_person_frame = "#contact_persons_form2"
        @submitted_contact_person = "two"

      elsif params[:contact_person] == "3"
        @build_contact_person = ReportPerson.find(params[:contact_person_id])
        @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])
        @ticket.reporter_id = @build_contact_person.id
        Rails.cache.write([:new_ticket, request.remote_ip.to_s, @ticket_time_now], @ticket)
        @contact_person_frame = "#report_persons_form"
        @submitted_contact_person = "three"
      end
    else
      if params[:submit_contact_person1]
        @submitted_contact_person = 1
        search_contact_person = params[:search_contact_person].strip
        @submit_contact_person = "submit_contact_person1"
        @contact_persons = ContactPerson1.search(query: search_contact_person, page: params[:page])

      elsif params[:submit_contact_person2]
        @submitted_contact_person = 2
        search_contact_person = params[:search_contact_person].strip
        @submit_contact_person = "submit_contact_person2"

        @contact_persons = ContactPerson2.search(query: search_contact_person, page: params[:page])

      elsif params[:submit_report_person]
        @submitted_contact_person = 3
        search_contact_person = params[:search_contact_person].strip
        @submit_contact_person = "submit_report_person"

        @contact_persons = ContactPerson1.search(query: search_contact_person, page: params[:page])

      end
      search_contact_person = [params[:search_contact_person]]

      search_contact_person << "accounts_dealer_types.dealer_code:CUS OR accounts_dealer_types.dealer_code:INDCUS"
      @customers = Organization.search(query: search_contact_person.map { |s| s if s.present? }.compact.join(" AND "), page: params[:page])

    end

    render :select_contact_person

  end

  def create_contact_person_record
    ContactNumber
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])
    # @product = Product.find (params[:product_id] || session[:product_id])

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
    Rails.cache.write([:new_ticket, request.remote_ip.to_s, @ticket_time_now], @ticket)
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
    # @product = Product.find (params[:product_id] or session[:product_id])
    respond_to do |format|
      @new_customer = Customer.find(session[:customer_id])
      @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])
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
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
    @histories = Rails.cache.read([:histories, session[:product_id]]).page(params[:page]).per(3)
    if params[:status_param] == "initiate"
      @new_problem_category = ProblemCategory.new
    elsif params[:status_param] == "create"
      @new_problem_category = ProblemCategory.new problem_category_params
      @new_problem_category.save

      @product = Product.find(session[:product_id])
    elsif params[:status_param] == "back"
      # @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
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
      @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
      render :new_product
    elsif params[:status_param] == "back"
      @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
      render :new_product
    end
  end

  def create_accessory
    Product
    Ticket
    Warranty
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])
    @histories = Rails.cache.read([:histories, session[:product_id]]).page(params[:page]).per(3)
    if params[:status_param] == "initiate"
      @new_accessory = Accessory.new
    elsif params[:status_param] == "create"
      @new_accessory = Accessory.new accessory_params
      @new_accessory.save
      # @ticket = Ticket.new session[:ticket_initiated_attributes]
      @product = Product.find((params[:product_id] or session[:product_id]))
    elsif params[:status_param] == "back"
      # @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])
      # @ticket = Ticket.new session[:ticket_initiated_attributes]
      @product = Product.find((params[:product_id] or session[:product_id]))
    end
  end

  def create_extra_remark
    Product
    Ticket
    Warranty
    QAndA
    # @product = Product.find (params[:product_id] || session[:product_id])
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])
    if params[:status_param] == "initiate"
      @new_extra_remark = ExtraRemark.new
    elsif params[:status_param] == "create"
      @new_extra_remark = ExtraRemark.new extra_remark_params
      @new_extra_remark.save
      render "remarks"
    elsif params[:status_param] == "back"
      # ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
      @product = Product.find((params[:product_id] or session[:product_id]))
    end
  end

  def remarks
    QAndA
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, session[:time_now]])
    @product = Product.find (params[:product_id] or session[:product_id])
  end

  def save_cache_ticket
    # session[:time_now] ||= Time.now.strftime("%H%M%S")
    @new_ticket = (Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now]) || Ticket.new)
    @new_ticket.ticket_accessories.clear
    @new_ticket.attributes = ticket_params

    Rails.cache.write([:new_ticket, request.remote_ip.to_s, @ticket_time_now], @new_ticket)

    Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])
    render plain: "OK"
  end

  def finalize_ticket_save
    WorkflowMapping
    QAndA
    TaskAction
    Warranty
    # @product = Product.find (params[:product_id] or session[:product_id])
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])

    # reference: http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/ReentrantReadWriteLock.html

    if params[:first_resolution]
      @status_close_id = TicketStatus.find_by_code("CLS").id
      @ticket.status_id = @status_close_id
      @ticket.attributes = ticket_params.merge({ticket_closed_at: DateTime.now, open_time_duration: 0, open_time_duration_sla: 0, sla_finished_at: DateTime.now})
      @status_resolve_id = TicketStatusResolve.find_by_code("FST").try(:id)
    else
      @status_resolve_id = TicketStatusResolve.find_by_code("NAP").try(:id)
    end

    @repair_type_id = TicketRepairType.find_by_code("IN").try :id
    @manufacture_currency_id = @product.product_brand.currency.id
    @ticket.attributes = ticket_params.merge({created_by: current_user.id, slatime: @ticket.sla_time.try(:sla_time), status_resolve_id: @status_resolve_id, repair_type_id: @repair_type_id, manufacture_currency_id: @manufacture_currency_id, ticket_print_count: 0, ticket_complete_print_count: 0})
    q_and_answers = @ticket.q_and_answers.to_a
    ge_q_and_answers = @ticket.ge_q_and_answers.to_a
    @ticket.q_and_answers.clear
    @ticket.ge_q_and_answers.clear

    @continue = false
    warranty_constraint = true

    if ["CW", "MW"].include?(@ticket.warranty_type.code)
      warranty_constraint = @product.warranties.select{|w| w.warranty_type_id == @ticket.warranty_type_id and (w.start_at.to_date..w.end_at.to_date).include?(Date.today)}.present?
    end

    @bpm_response = view_context.send_request_process_data process_history: true, process_instance_id: 1, variable_id: "ticket_id"
    if !@bpm_response[:status].present? or @bpm_response[:status].upcase == "ERROR"
      render js: "alert('BPM error. Please continue after rectify BPM.');"
    elsif not warranty_constraint
      render js: "alert('There are no present #{@ticket.warranty_type.name} for the product to initiate particular warranty related ticket.')"
    else
      @continue = true
    end

    if @continue
      # sleep rand(5)
      begin
        Ticket.transaction do
          company_config = CompanyConfig.lock.first.reload

          @ticket.ticket_no = company_config.sup_last_ticket_no.to_i
          if @ticket.save!

            @ticket.products << @product
            @product.update_attribute :last_ticket_id, @ticket.id
            @ticket.customer.update_attribute :last_ticket_id, @ticket.id

            ticket_user_action = @ticket.user_ticket_actions.create(action_at: DateTime.now, action_by: current_user.id, re_open_index: 0, action_id: TaskAction.find_by_action_no(1).id) # Add ticket action

            q_and_answers.each{|q| q.ticket_action_id= ticket_user_action.id; @ticket.q_and_answers << q}
            ge_q_and_answers.each{|q| q.ticket_action_id= ticket_user_action.id; @ticket.ge_q_and_answers << q}

            Rails.cache.delete([:new_ticket, request.remote_ip.to_s, @ticket_time_now])
            Rails.cache.delete([:ticket_params, request.remote_ip.to_s, @ticket_time_now])
            Rails.cache.delete([:created_warranty, request.remote_ip.to_s, @ticket_time_now])
            Rails.cache.delete([:existing_customer, request.remote_ip.to_s, @ticket_time_now])
            Rails.cache.delete([:histories, session[:product_id]])
            session[:ticket_id] = nil
            session[:product_category_id] = nil
            session[:product_brand_id] = nil
            session[:product_id] = nil
            session[:customer_id] = nil
            session[:serial_no] = nil
            session[:warranty_id] = nil
            # session[:ticket_initiated_attributes] = {}
            Rails.cache.delete([:ticket_initiated_attributes, @ticket_time_now])

            session[:time_now]= nil

            unless @ticket.status_id == @status_close_id
              # bpm output variables
              ticket_id = @ticket.id
              di_pop_approval_pending = ["RCD", "RPN", "APN", "LPN", "APV"].include?(@ticket.products.first.product_pop_status.try(:code)) ? "Y" : "N"
              priority = @ticket.priority
              d42_assignment_required = "Y"
              engineer_id = "-"

              @bpm_response = view_context.send_request_process_data start_process: true, process_name: "SPPT", query: {ticket_id: ticket_id, d1_pop_approval_pending: di_pop_approval_pending, priority: priority, d42_assignment_required: d42_assignment_required, engineer_id: engineer_id, supp_engr_user: engineer_id, supp_hd_user: @ticket.created_by }

              if @bpm_response[:status].try(:upcase) == "SUCCESS"
                @ticket.ticket_workflow_processes.create(process_id: @bpm_response[:process_id], process_name: @bpm_response[:process_name])
              else
                @bpm_process_error = true
              end
            end
            @ticket.update_index

            email_to = params[:email_to].to_s
            cc = email_to.scan(/\bcc:+[a-zA-Z0-9._%+-]+@\w+\.\w{2,}\b/).map{|e| e[3..-1]}
            to = (email_to.scan(/\bto:+[a-zA-Z0-9._%+-]+@\w+\.\w{2,}\b/).map{|e| e[3..-1]}.first or cc.first)

            if params[:send_email].present? and params[:send_email].to_bool
              if to.present?
                view_context.send_email(email_to: to, email_cc: cc, ticket_id: @ticket.id, email_code: "NEW_TICKET")
                @email_response = "Successfully sent email to: #{to}"
              end
            end

            flash_message = @bpm_process_error ? "Ticket successfully saved. But BPM error. Please continue after rectifying BPM" : "Thank you. ticket is successfully registered. #{@email_response}"

            # WebsocketRails[:posts].trigger 'new', {task_name: "Ticket", task_id: @ticket.id, task_verb: "created.", by: current_user.email, at: Time.now.strftime('%d/%m/%Y at %H:%M:%S')}

            render js: "alert('#{flash_message}'); window.location.href='#{ticket_path(@ticket)}';"

          else
            @flash_message = "Please re-try"
            render :remarks
          end

        end

      rescue Exception => e
        if e.is_a?(ActiveRecord::RecordNotUnique)
          render js: "alert('Ticket token already taken. Please try again saving. It will save with fresh ticket token');"
        else
          render js: "alert('Some error occured. Please try again'); "
        end
      end
      
     # render plain: @ticket_params.inspect
    end
  end

  def regenerate_workflow
    @ticket = Ticket.find params[:ticket_id]
    @continue = false
    @messages = []
    @bpm_response = view_context.send_request_process_data process_history: true, process_instance_id: 1, variable_id: "ticket_id"
    if !@bpm_response[:status].present? or @bpm_response[:status].upcase == "ERROR"
      @messages << "BPM error. Please continue after rectify BPM."
    else
      @continue = true
    end

    if @continue
      @status_open_id = TicketStatus.find_by_code("OPN").id

      if (@ticket.status_id == @status_open_id) and @ticket.ticket_workflow_processes.empty?
        # bpm output variables
        ticket_id = @ticket.id
        di_pop_approval_pending = ["RCD", "RPN", "APN", "LPN", "APV"].include?(@ticket.products.first.product_pop_status.try(:code)) ? "Y" : "N"
        priority = @ticket.priority
        d42_assignment_required = "Y"
        engineer_id = "-"

        @bpm_response = view_context.send_request_process_data start_process: true, process_name: "SPPT", query: {ticket_id: ticket_id, d1_pop_approval_pending: di_pop_approval_pending, priority: priority, d42_assignment_required: d42_assignment_required, engineer_id: engineer_id, supp_engr_user: engineer_id, supp_hd_user: @ticket.created_by }

        if @bpm_response[:status].try(:upcase) == "SUCCESS"
          @ticket.ticket_workflow_processes.create(process_id: @bpm_response[:process_id], process_name: @bpm_response[:process_name])
        else
          @bpm_process_error = true
        end

        @messages << @bpm_process_error ? "Ticket successfully saved. But BPM error. Please continue after rectifying BPM" : "Thank you. ticket is successfully registered. #{@email_response}"

      else
        @messages << "Process already running"

      end

    else
      @messages << "BPM Error"
    end

    redirect_to ticket_url(@ticket), notice: @messages.join(", ")

  end

  def product_update
    @product = Product.find(params[:product_id])
    formatted_product_params = product_params
    formatted_product_params["pop_note"] = "#{formatted_product_params['pop_note']} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@product.pop_note}" if formatted_product_params["pop_note"].present?
    @product.update(formatted_product_params)
    respond_with(@product)
  end

  def ticket_update
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])
    t_attributes = @ticket.attributes
    t_attributes.merge! ticket_params
    @ticket.attributes = t_attributes
    respond_to do |format|
      if @ticket.valid?
        format.html {redirect_to @ticket, notice: "Successfully updated."}
        Rails.cache.write([:new_ticket, request.remote_ip.to_s, session[:time_now]], @ticket)
        format.json {render json: @ticket}
      else
        if params[:ticket][:logged_at].present?
          if @ticket.logged_at >= Time.now
            @ticket.errors[:logged_at] << "Date and time cannot be future than current date time"
          else
            @ticket.errors.clear
            Rails.cache.write([:new_ticket, request.remote_ip.to_s, session[:time_now]], @ticket)
            # puts "logged at saved"
          end

          format.json {render json: @ticket.errors[:logged_at].join}

        else
          format.html {redirect_to @ticket, error: "Unable to update ticket. Please validate your inputs."}
          format.json {render json: @ticket.errors.full_messages.join}
        end
      end
    end
  end

  def q_and_answer_save
    QAndA
    WorkflowMapping

    # @product = Product.find (params[:product_id] or session[:product_id])
    @ticket = Rails.cache.read([:new_ticket, request.remote_ip.to_s, @ticket_time_now])
    @ticket.q_and_answers.clear
    @ticket.ge_q_and_answers.clear
    @ticket.attributes = ticket_params
    if @ticket.valid?
      Rails.cache.write([:new_ticket, request.remote_ip.to_s, @ticket_time_now], @ticket)
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

  def paginate_payment_pending_tickets
    User
    if params[:customer_name].present?
      search_customer_name = params[:customer_name]
      @search_customers = Customer.where("name like ?", "%#{search_customer_name}%").page(params[:page]).per(params[:per_page])
      # @search_customers = Kaminari.paginate_array(@search_customers).page(params[:page]).per(params[:per_page])
    else
      @search_customers = Customer.all.page(params[:page]).per(params[:per_page])
      # @search_customers = Kaminari.paginate_array(@search_customers).page(params[:page]).per(params[:per_page])
    end

    # @search_customers = Rails.cache.read([:search_customers]).page(params[:page]).per(params[:per_page])
    render "tickets/tickets_pack/customer_advance_payment/paginate_payment_pendings"
  end

  def paginate_ticket_grn_items
    Grn
    # @rendering_id = params[:rendering_id]
    # @rendering_file = params[:rendering_file]
    @grn_items = GrnItem.where(inventory_not_updated: false).page(params[:page]).per(params[:per_page])
    render "tickets/tickets_pack/estimate_the_part_internal/paginate_grns"
  end


  def show
    Warranty
    ContactNumber
    QAndA
    Inventory
    @product = @ticket.products.first
    @warranties = @product.warranties
    session[:product_id] = @product.id
    session[:process_id] = nil
    session[:task_id] = nil
    session[:owner] = nil
    Rails.cache.delete([:join, @ticket.id])
    respond_with(@ticket)
  end

  def ajax_show
    TicketSparePart
    Warranty
    ContactNumber
    QAndA
    Inventory
    TaskAction
    Tax
    TicketEstimation
    Invoice
    @ticket = Ticket.find params[:ticket_id]
    # @edit_ticket = session[:edit_ticket]

    @rendering_dom = "#"+params[:partial_template_for_show]

    case params[:partial_template_for_show]

    when "job_info"
      params[:edit_ticket] = params[:edit_ticket].present?
      customer = @ticket.customer
      product = @ticket.products.first

      @render_template = "tickets/job_info"
      @variables = {product: product, ticket: @ticket}
      
    when "contacts"
      customer = @ticket.customer

      @render_template = "users/view_customer"
      @variables = {customer: customer, ticket: @ticket}

    when "warranties"
      product = @ticket.products.first
      warranties = product.warranties

      @render_template = "warranties/select_warranties"
      @variables = {warranties: warranties}

    when "history"
      product = @ticket.products.first
      histories = Rails.cache.fetch([:histories, session[:product_id]]){Kaminari.paginate_array(product.tickets.reject{|t| t == @ticket})}.page(params[:page]).per(2)

      @render_template = "tickets/view_histories"
      @variables = {histories: histories}

      @rendering_dom = "#history #histories_pagination"

    when "join"
      @join_tickets = Rails.cache.fetch([:join, @ticket.id]){Kaminari.paginate_array(Ticket.where(id: @ticket.joint_tickets.map(&:joint_ticket_id)))}.page(params[:page]).per(2)

      @render_template = "tickets/join"
      @variables = {join_tickets: @join_tickets, ticket: @ticket}
      @rendering_dom = "#join_pagination"

    when "q_and_a"
      product = @ticket.products.first
      ge_q_and_as = Rails.cache.fetch([:ge_q_and_answers, @ticket.id]){ @ticket.ge_q_and_answers.group_by{|ge_a| ge_a.ge_q_and_a && ge_a.ge_q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"General Questions" => v})} }

      pr_q_and_as = Rails.cache.fetch([:q_and_answers, @ticket.id]){ @ticket.q_and_answers.group_by{|a| a.q_and_a && a.q_and_a.task_action.action_description}.inject({}){|hash, (k,v)| hash.merge(k => {"Problematic Questions" => v})} }

      @render_template = "q_and_as/q_and_a"
      @variables = {ge_q_and_as: ge_q_and_as, pr_q_and_as: pr_q_and_as, ticket: @ticket}

    when "activity_history"

      # product = @ticket.products.first
      @user_ticket_actions = @ticket.cached_user_ticket_actions

      @render_template = "tickets/tickets_pack/activity_history"
      @variables = {ticket: @ticket}

    when "fsr"
      # product = @ticket.products.first
      @user_ticket_actions = @ticket.cached_user_ticket_actions

      @render_template = "tickets/tickets_pack/fsr"
      @variables = {ticket: @ticket}

    when "payment_recieved"

      # product = @ticket.products.first
      # @user_ticket_actions = @ticket.cached_user_ticket_actions
      # @new_payment_receive = TicketPaymentReceived.new
      @render_template = "tickets/tickets_pack/payment_recieved"
      @variables = {ticket: @ticket}

    when "estimation"
      params[:from_where1] = "estimations_quotations"

      Invoice
      # product = @ticket.products.first
      @user_ticket_actions = @ticket.cached_user_ticket_actions

      @render_template = "tickets/tickets_pack/estimation/estimations"
      @variables = {ticket: @ticket}

    when "parts_odered"

      # product = @ticket.products.first
      @user_ticket_actions = @ticket.cached_user_ticket_actions

      @render_template = "tickets/tickets_pack/parts_ordered/parts_ordered"
      @variables = {ticket: @ticket}

    when "workflow"

      # product = @ticket.products.first
      # @user_ticket_actions = @ticket.cached_user_ticket_actions

      @render_template = "tickets/tickets_pack/workflow"
      @variables = {ticket: @ticket}

    when "costing"
      @render_template = "tickets/tickets_pack/costing"

    else
      render js: "alert('template is unavailable');"
    end
    
  end

  def load_sbu
    case params[:type]
    when "sbu"
      @sbus = if params[:filter_sbu].present?
        sbu = Sbu.find params[:filter_sbu]
        # sbu_engineer = SbuEngineer.find params[:filter_sbu]
        # sbu = sbu_engineer.sbu

        @sbus = sbu.engineers.map { |s| {id: s.id, name: "#{s.full_name} (#{ TicketEngineer.where(user_id: s.id, job_completed_at: nil).count })"} }

      else
        @sbus = Sbu.all.map { |s| {id: s.id, name: s.sbu} }
        # @sbus = SbuEngineer.all.map { |s| {id: s.id, name: s.sbu.try(:sbu)} }

      end

    when "ticket"
      @ticketEngs = if params[:ticket_id].present?
        ticket_engineers = Ticket.find(params[:ticket_id]).ticket_engineers
        re_assigned_ticket_engineer = ticket_engineers.find_by_id(params[:re_assigned]) if params[:re_assigned].present? and params[:re_assigned] != "false"

        filtered_engineers = if re_assigned_ticket_engineer
          ticket_engineers.where(channel_no: re_assigned_ticket_engineer.channel_no)
        else
          ticket_engineers #.inject({}){|i, (k, v)| i[k] = v.sort{|p, n| p.order_no.to_i <=> n.order_no.to_i } }

        end

        filtered_engineers.group_by{ |t| t.channel_no.to_i }.map { |k, v| { channel_no: k, ticket_id: params[:ticket_id], eng_set: v.map{ |r| { name: r.user.full_name, image: r.user.avatar.url, id: r.id, order_no: r.order_no, channel_no: r.channel_no, ticket_id: r.ticket_id, deletable: r.deletable? } }.sort{ |p, n| p[:order_no].to_i <=> n[:order_no].to_i } } }

      else
        {}

      end

    end

    render json: {sbus: @sbus, ticketEngs: {new_channel_no: ((@ticketEngs.try(:last) and @ticketEngs.last[:channel_no]).to_i + 1), engs: @ticketEngs}}

  end

  def remove_eng
    Ticket
    @ticket_engineer = TicketEngineer.find(params[:ticket_engineer_id])

    response = if @ticket_engineer.deletable?
      @ticket_engineer.ticket_support_engineers.destroy_all # if delete_all is set, foreign_key will be set to null, but not deleting record.
      @ticket_engineer.destroy
    end

    render json: response
  end

  def update_assign_engineer_ticket
    assign_eng_params = ActiveSupport::JSON.decode params[:assign_eng_params]
    # { ticket_id: "10", group_no: "2", order_no: "0", sbu_id: "2", assign_to: "1", subEng: [{user_id: "1"}] }

    current_order_no = assign_eng_params["order_no"].to_i
    current_channel_no = assign_eng_params["channel_no"].to_i

    @ticket = Ticket.find assign_eng_params["ticket_id"]
    @ticket_workfow = @ticket.ticket_workflow_processes.where process_id: assign_eng_params["process_id"]
    re_assignment = @ticket.ticket_engineers.any? { |en| en.workflow_process_id == @ticket_workfow.first.try(:id)  }

    sbu_engineer = SbuEngineer.where(sbu_id: assign_eng_params["sbu_id"], engineer_id: assign_eng_params["assign_to"]).first

    # ticket_engineer = @ticket.ticket_engineers.build(user_id: assign_eng_params["assign_to"], re_open_index: @ticket.re_open_count, re_assignment: re_assignment, sbu_id: assign_eng_params["sbu_id"], task_description: assign_eng_params["task_description"], channel_no: current_channel_no, order_no: (current_order_no+1))

    ticket_engineer = @ticket.ticket_engineers.build(user_id: assign_eng_params["assign_to"], re_open_index: @ticket.re_open_count, re_assignment: re_assignment, sbu_id: sbu_engineer.try(:id), task_description: assign_eng_params["task_description"], channel_no: current_channel_no, order_no: (current_order_no+1))

    assign_eng_params["subEng"].to_a.each do |sub_eng|
      ticket_engineer.ticket_support_engineers.build( user_id: sub_eng["user_id"] )
    end

    # ticket_engineer.user_assign_ticket_actions.build(sbu_id: assign_eng_params["sbu_id"], assign_to: assign_eng_params["assign_to"])

    parent_engineer = @ticket.ticket_engineers.select{|t| t.order_no.to_i == current_order_no and t.channel_no.to_i == current_channel_no and t.re_open_index == @ticket.re_open_count }.first

    ticket_engineer.parent_engineer_id = parent_engineer.try(:id)

    ticket_engineer.save
    ticket_engineer.channel_no = current_channel_no
    ticket_engineer.order_no = (current_order_no + 1)

    render json: ticket_engineer

  end

  def assign_ticket
    ContactNumber
    QAndA
    TaskAction
    Inventory
    @ticket = Ticket.find_by_id params[:ticket_id]
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])

      @user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(2).id)
      @user_assign_ticket_action = @user_ticket_action.build_user_assign_ticket_action
      @assign_regional_support_center = @user_ticket_action.assign_regional_support_centers.build

      #@ticket_workfow = @ticket.ticket_workflow_processes.where process_id: params["process_id"]
      #@re_assignment_rq_engineer =  @ticket.ticket_engineers.where(workflow_process_id: @ticket_workfow.first.try(:id)).first
      @engineer_id = params[:engineer_id]
      @re_assignment_rq_engineer = TicketEngineer.find @engineer_id if @engineer_id.present? and @engineer_id != "-"
      @re_assignment = @re_assignment_rq_engineer.present?

      if @re_assignment
        @re_assignment_requested_by = (@re_assignment_rq_engineer and @re_assignment_rq_engineer.user.full_name)
        re_assign_request = @ticket.user_ticket_actions.find_by_action_id(TaskAction.find_by_action_no(6).id).try(:ticket_re_assign_request)
        @re_assignment_reason = (re_assign_request and re_assign_request.reason.try(:reason))
      end

    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/assign_ticket"}
    end
  end

  def update_assign_ticket
    @ticket = Ticket.find(params[:ticket_id])
    TaskAction
    @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    @ticket_workfows = @ticket.ticket_workflow_processes.where process_id: params["process_id"]
    #@re_assignment_rq_engineer =  @ticket.ticket_engineers.where(workflow_process_id: @ticket_workfows.first.try(:id)).last
    engineer_id = params[:engineer_id]
    @re_assignment_rq_engineer = TicketEngineer.find engineer_id if engineer_id.present? and engineer_id != "-"
    @re_assignment = @re_assignment_rq_engineer.present?

    t_params = ticket_params
    t_params["user_ticket_actions_attributes"].first.merge!("action_at" => DateTime.now )
    @ticket.attributes = t_params

    user_ticket_action = @ticket.user_ticket_actions.last
    user_ticket_action.user_assign_ticket_action.regional_support_center_job = @ticket.regional_support_job
    h_assign_regional_support_center = user_ticket_action.assign_regional_support_centers.first

    user_assign_ticket_action = user_ticket_action.user_assign_ticket_action

    if @continue and (@ticket.ticket_engineers.any? or user_assign_ticket_action.recorrection)

      if @ticket.ticket_engineers.any?
        user_assign_ticket_action.assign_to = @ticket.ticket_engineers.first.user_id
        user_assign_ticket_action.assign_to_engineer_id = @ticket.ticket_engineers.first.id
        user_assign_ticket_action.sbu_id = @ticket.ticket_engineers.first.sbu_engineer.try(:sbu_id)
      end

      user_ticket_action.assign_regional_support_centers.reload unless !user_assign_ticket_action.recorrection and user_assign_ticket_action.regional_support_center_job

      if @ticket.save
        @ticket.ticket_engineers.each do |ticket_engineer|
          unless ticket_engineer.created_action_id.present?
            ticket_engineer.update created_action_id: user_ticket_action.id
          end
        end

        @ticket.update status_id: TicketStatus.find_by_code("ASN").id

        if !user_assign_ticket_action.recorrection and user_assign_ticket_action.regional_support_center_job

          regional_ticket_user_action = @ticket.user_ticket_actions.create(action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count, action_id: TaskAction.find_by_action_no(4).id) #assign regional support center action.
          h_assign_regional_support_center.update(ticket_action_id: regional_ticket_user_action.id)

        end

        # if !user_assign_ticket_action.recorrection
        #   @ticket_engineer = @ticket.ticket_engineers.create user_id: user_assign_ticket_action.assign_to, created_action_id: user_ticket_action.id, created_at: DateTime.now
        #   @ticket.update owner_engineer_id: @ticket_engineer.id
        # end

        # bpm output variables
        d2_recorrection = user_assign_ticket_action.recorrection ? "Y" : "N"
        d3_regional_support_job = user_assign_ticket_action.regional_support_center_job ? "Y" : "N"
        supp_hd_user = @ticket.created_by
        supp_engr_user = "-"
        engineer_id = "-"
        d43_no_assignment = "Y"

        if  @re_assignment
          @ticket_engineer = @ticket.ticket_engineers.where(parent_engineer_id: @re_assignment_rq_engineer.id).first

          if @ticket_engineer.present?

            @ticket_engineer.update status: 1, job_assigned_at: DateTime.now, workflow_process_id: @ticket_workfows.first.try(:id)

            supp_engr_user = @ticket_engineer.user_id
            # supp_engr_user = @re_assignment_rq_engineer.user_id #modified
            engineer_id = @ticket_engineer.id
            # engineer_id = @re_assignment_rq_engineer.id # modified
            d43_no_assignment = "N"

            workflow_processes = @ticket_workfows.where( engineer_id: @re_assignment_rq_engineer.id )
            workflow_processes.update_all engineer_id: engineer_id

          else
            flash[:error] = "Please assign a new engineer."
            redirect_to @ticket and return;
          end

        elsif !user_assign_ticket_action.recorrection and @ticket.ticket_engineers.empty?
          flash[:error] = "Please assign a new engineer."
          redirect_to @ticket and return;

        end

        @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: {d2_re_correction: d2_recorrection, d3_regional_support_job: d3_regional_support_job, supp_engr_user: supp_engr_user, supp_hd_user: supp_hd_user, engineer_id: engineer_id, d43_no_assignment: d43_no_assignment}

        if @bpm_response[:status].upcase == "SUCCESS"
          all_success = true
          error_engs = []
          email_template = EmailTemplate.find_by_code("ASSIGN_JOB")

          if not(user_assign_ticket_action.recorrection or @re_assignment)
            @ticket.ticket_engineers.each do |ticket_engineer|
              unless ticket_engineer.parent_engineer.present?
                # bpm output variables
                ticket_id = @ticket.id
                di_pop_approval_pending = "N"
                priority = @ticket.priority
                d42_assignment_required = "N"
                engineer_id = ticket_engineer.id

                supp_engr_user = ticket_engineer.user_id
                supp_hd_user = @ticket.created_by

                bpm_response1 = view_context.send_request_process_data start_process: true, process_name: "SPPT", query: {ticket_id: ticket_id, d1_pop_approval_pending: di_pop_approval_pending, priority: priority, d42_assignment_required: d42_assignment_required, engineer_id: engineer_id , supp_engr_user: supp_engr_user, supp_hd_user: supp_hd_user}

                if bpm_response1[:status].try(:upcase) == "SUCCESS"


                  workflow_process = @ticket.ticket_workflow_processes.create(process_id: bpm_response1[:process_id], process_name: bpm_response1[:process_name], engineer_id: engineer_id, re_open_index: @ticket.re_open_count)

                  view_context.ticket_bpm_headers bpm_response1[:process_id], @ticket.id

                  ticket_engineer.update status: 1, job_assigned_at: DateTime.now, workflow_process_id: workflow_process.id

                  email_to = ticket_engineer.user.email
                  if email_template.try(:active)
                    view_context.send_email(email_to: email_to, ticket_id: @ticket.id, engineer_id: ticket_engineer.id, email_code: "ASSIGN_JOB") if email_to.present?

                    ticket_engineer.ticket_support_engineers.each do |support_engineer|
                      view_context.send_email(email_to: support_engineer.user.email, engineer_id: ticket_engineer.id, ticket_id: @ticket.id, email_code: "ASSIGN_JOB") if support_engineer.user.email.present?

                    end

                  end

                else
                  all_success = false
                  @bpm_process_error = true
                  error_engs << engineer_id
                end

              end
            end
          elsif @re_assignment
            email_to = @ticket_engineer.user.email
            if email_template.try(:active)
              view_context.send_email(email_to: email_to, ticket_id: @ticket.id, engineer_id: @ticket_engineer.id, email_code: "ASSIGN_JOB") if email_to.present?

              @ticket_engineer.ticket_support_engineers.each do |support_engineer|
                view_context.send_email(email_to: support_engineer.user.email, engineer_id: @ticket_engineer.id, ticket_id: @ticket.id, email_code: "ASSIGN_JOB") if support_engineer.user.email.present?
              end
            end
          end

          if all_success
            flash[:notice] = "Successfully updated."
          else
            flash[:error] = "ticket is updated. Engineer assignment error. #{error_engs.join(', ')}"
          end

          # WebsocketRails[:posts].trigger 'new', {task_name: "Assign ticket", task_id: @ticket.id, task_verb: "updated.", by: current_user.email, at: Time.now.strftime('%d/%m/%Y at %H:%M:%S')}
        else
          flash[:error] = "ticket is updated. but Bpm error"
        end
      end
    else
      flash[:error] = @continue ? 'Please add atleast one engineer.' : "ticket is not updated. Bpm error"
    end
    # redirect_to todos_url, notice: @flash_message
    redirect_to @ticket
  end

  def pop_approval
    ContactNumber
    QAndA
    TaskAction
    Inventory
    TicketSparePart
    @ticket = Ticket.find_by_id params[:ticket_id]
    @new_warranty = Warranty.new
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])
      @user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(2).id)
      @user_assign_ticket_action = @user_ticket_action.build_user_assign_ticket_action
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

    @product.attributes = product_params[product_id]

    @product.pop_note = "#{@product.pop_note} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@product.pop_note_was}" if @product.pop_note_changed?
    warranty_constraint = true

    @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if @continue

      if ["CW", "MW"].include?(@ticket.warranty_type.code)
        warranty_constraint = @product.warranties.select{|w| w.warranty_type_id == @ticket.warranty_type_id and (w.start_at.to_date..w.end_at.to_date).include?(Date.today)}.present?
      end

      if warranty_constraint
        @ticket.save
        @product.save

        if params["pop_completed"]

          user_ticket_action = @ticket.user_ticket_actions.create(action_id: TaskAction.find_by_action_no(62).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)

          # calling bpm
          @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: {}

          if @bpm_response[:status].upcase == "SUCCESS"
            flash[:notice] = "Successfully updated."
          else
            flash[:error] = "ticket is updated. but Bpm error"
          end
        end

        WebsocketRails[:posts].trigger 'new', {task_name: "Pop approval", task_id: @ticket.id, task_verb: "updated.", by: current_user.email, at: Time.now.strftime('%d/%m/%Y at %H:%M:%S')}

        redirect_to @ticket
      else
        redirect_to pop_approval_tickets_path, notice: "There are no present #{@ticket.warranty_type.name} for the product to initiate particular warranty related ticket.')"
      end
    else
      flash[:notice] = "ticket is not updated. Bpm error"
    end
  end

  def resolution
    Inventory
    Warranty
    ContactNumber
    QAndA
    TaskAction
    Inventory
    TicketSparePart
    Invoice
    Tax

    params[:from_where] = "resolution"

    ticket_id = (params[:ticket_id] or session[:ticket_id])
    @ticket = Ticket.find_by_id ticket_id
    session[:ticket_id] = @ticket.id

    @quotation = CustomerQuotation.new
    @invoice = TicketInvoice.new
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])

      @ticket_engineer = @ticket.ticket_engineers.find_by_id(params[:engineer_id])

      @user_ticket_action = @ticket.user_ticket_actions.build(action_id: 2)
      @user_assign_ticket_action = @user_ticket_action.build_user_assign_ticket_action
      @assign_regional_support_center = @user_ticket_action.assign_regional_support_centers.build

      @ge_questions = GeQAndA.actives.where(action_id: 5)
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/resolution"}
    end
  end

  def order_mf
    Inventory
    Warranty
    ContactNumber
    QAndA
    TaskAction
    Inventory
    ticket_id = (params[:ticket_id] or session[:ticket_id])
    @ticket = Ticket.find_by_id ticket_id
    session[:ticket_id] = @ticket.id

    request_spare_part_id = (params[:request_spare_part_id] or session[:request_spare_part_id])
    @spare_part = TicketSparePart.find request_spare_part_id
    # @spare_part = @ticket.ticket_spare_parts.find request_spare_part_id
    session[:request_spare_part_id] = params[:request_spare_part_id]
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/order_mf"}
    end
  end

  def approve_store_parts
    Inventory
    Warranty
    ContactNumber
    QAndA
    TaskAction
    TicketSparePart
    TicketEstimation
    Tax

    ticket_id = params[:ticket_id]
    @ticket = Ticket.find_by_id ticket_id
    session[:ticket_id] = @ticket.id

    @onloan_request = true if params[:onloan_request] == "Y"


    if @onloan_request
      @onloan_spare_part = @ticket.ticket_on_loan_spare_parts.find params[:request_onloan_spare_part_id]
      @spare_part = @onloan_spare_part.ticket_spare_part
    else
      @spare_part = @ticket.ticket_spare_parts.find params[:request_spare_part_id]
    end

    if @ticket
      @product = @ticket.products.first

      Rails.cache.delete([:histories, @product.id])
      Rails.cache.delete([:join, @ticket.id])
    end

    respond_to do |format|
      format.html {render "tickets/tickets_pack/approve_store_parts/approve_store_parts"}
    end
  end

  def update_approve_store_parts
    TicketSparePart
    @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]
    approved_quantity = params[:requested_quantity]
    d18_approve_request_store_part = "N"

    if @continue

      if params[:onloan_request] == "Y"
        @onloan_request = true
        @onloan_request_part = TicketOnLoanSparePart.find params[:request_onloan_spare_part_id]
        @onloan_request_part.approved_quantity = approved_quantity
        @terminated = (@onloan_request_part.status_action_id == SparePartStatusAction.find_by_code("CLS").id)
      else
        @ticket_spare_part = TicketSparePart.find params[:request_spare_part_id]
        @terminated = (@ticket_spare_part.status_action_id == SparePartStatusAction.find_by_code("CLS").id)

        @ticket_spare_part.ticket_spare_part_store.update(approved_quantity: approved_quantity) if @ticket_spare_part.ticket_spare_part_store.present?

      end

      if @terminated
        bpm_variables = view_context.initialize_bpm_variables.merge(d18_approve_request_store_part: d18_approve_request_store_part)

        @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if @bpm_response[:status].upcase == "SUCCESS"
          flash[:error] = "Request allready terminated."
        else
          flash[:error] = "Request allready terminated. but Bpm error"
        end

      else

        if @onloan_request

          if @onloan_request_part.ticket_spare_part
            tsp = @onloan_request_part.ticket_spare_part
            tsp.update ticket_spare_part_params(tsp)
          else
            @onloan_request_part.ticket.update ticket_params
          end

          @onloan_request_part.update approved_at: DateTime.now, approved_by: current_user.id


          @onloan_request_part.reload

          if @onloan_request_part.approved
            #Approve On-Loan Part for Store
            action_id = TaskAction.find_by_action_no(49).id
            d18_approve_request_store_part = "Y"

            @onloan_request_part.update status_action_id: SparePartStatusAction.find_by_code("APS").id
            @onloan_request_part.ticket_on_loan_spare_part_status_actions.create(status_id: @onloan_request_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

            srn = @onloan_request_part.approved_store.srns.create(created_by: current_user.id, created_at: DateTime.now, requested_module_id: BpmModule.find_by_code("SPT").id, srn_no: CompanyConfig.first.increase_inv_last_srn_no)#inv_srn

            srn_item = srn.srn_items.create(product_id: @onloan_request_part.approved_inventory_product.try(:id), quantity: approved_quantity, returnable: true, spare_part: true)#inv_srn_item

            @onloan_request_part.update inv_srn_id: srn.id, inv_srn_item_id: srn_item.id

          else
            #Reject On-Loan Part for Store
            action_id = TaskAction.find_by_action_no(65).id

            @onloan_request_part.update approved_inv_product_id: nil, approved_main_inv_product_id: nil, approved_store_id: nil, status_action_id: SparePartStatusAction.find_by_code("CLS").id

            # @onloan_request_part.update status_action_id: SparePartStatusAction.find_by_code("CLS").id

            @onloan_request_part.ticket_on_loan_spare_part_status_actions.create([{status_id: SparePartStatusAction.find_by_code("RJS").id, done_by: current_user.id, done_at: DateTime.now}, {status_id: SparePartStatusAction.find_by_code("CLS").id , done_by: current_user.id, done_at: DateTime.now}])
          end

          user_ticket_action = @onloan_request_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: @onloan_request_part.ticket.re_open_count, action_id: action_id)
          user_ticket_action.build_request_on_loan_spare_part(ticket_on_loan_spare_part_id: @onloan_request_part.id)
          user_ticket_action.save

          bpm_variables = view_context.initialize_bpm_variables.merge(d18_approve_request_store_part: d18_approve_request_store_part)

          @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          if @bpm_response[:status].upcase == "SUCCESS"
            flash[:notice] = "Successfully updated."
          else
            flash[:error] = "ticket is updated. but Bpm error"
          end

        else #Store Request (not On-Loan)

          @ticket_spare_part.update ticket_spare_part_params(@ticket_spare_part)

          if @ticket_spare_part.request_approved

            #update record spt_ticket_spare_part
            @ticket_spare_part.update request_approved_at: DateTime.now, request_approved_by: current_user.id

            #update record spt_ticket_spare_part_store
            @ticket_spare_part.ticket_spare_part_store.update(store_requested: true, store_requested_at: DateTime.now, store_requested_by: current_user.id )

            #Approve Spare Part for Store
            action_id = TaskAction.find_by_action_no(47).id
            d18_approve_request_store_part = "Y"

            @ticket_spare_part.update status_action_id: SparePartStatusAction.find_by_code("APS").id
            @ticket_spare_part.ticket_spare_part_status_actions.create(status_id: @ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

            #Create SRN
            @ticket_spare_part.ticket_spare_part_store.create_support_srn(current_user.id, @ticket_spare_part.ticket_spare_part_store.approved_store_id, @ticket_spare_part.ticket_spare_part_store.approved_inventory_product.try(:id), approved_quantity, @ticket_spare_part.ticket_spare_part_store.approved_main_inv_product_id)

          else
            #Reject Spare Part for Store
            action_id = TaskAction.find_by_action_no(64).id

            @ticket_spare_part.ticket_spare_part_store.update approved_inv_product_id: nil, approved_main_inv_product_id: nil, approved_store_id: nil
            @ticket_spare_part.update status_action_id: SparePartStatusAction.find_by_code("CLS").id

            @ticket_spare_part.ticket_spare_part_status_actions.create([{status_id: SparePartStatusAction.find_by_code("RJS").id, done_by: current_user.id, done_at: DateTime.now}, {status_id: SparePartStatusAction.find_by_code("CLS").id , done_by: current_user.id, done_at: DateTime.now}])
          end

          user_ticket_action = @ticket_spare_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket_spare_part.ticket.re_open_count, action_id: action_id)
          user_ticket_action.build_request_spare_part(ticket_spare_part_id: @ticket_spare_part.id)
          user_ticket_action.save

          bpm_variables = view_context.initialize_bpm_variables.merge(d18_approve_request_store_part: d18_approve_request_store_part)

          @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          if @bpm_response[:status].upcase == "SUCCESS"
            flash[:notice] = "Successfully updated."
          else
            flash[:error] = "ticket is updated. but Bpm error"
          end
        end
      end
    else
      flash[:notice] = "ticket is not updated. Bpm error"
    end
    redirect_to todos_url
  end

  def approve_manufacture_parts
    Inventory
    Warranty
    ContactNumber
    QAndA
    TaskAction
    TicketSparePart
    TicketSparePartManufacture
    TicketEstimation
    Tax

    ticket_id = params[:ticket_id]
    # ticket_id = 5
    @ticket = Ticket.find_by_id ticket_id
    session[:ticket_id] = @ticket.id

    # @onloan_request = true if params[:onloan_request] == "Y"


    # if @onloan_request
    #   @onloan_spare_part = @ticket.ticket_on_loan_spare_parts.find params[:request_onloan_spare_part_id]
    #   @spare_part = @onloan_spare_part.ticket_spare_part
    # else
    @spare_part = @ticket.ticket_spare_parts.find params[:request_spare_part_id]
    # end

    if @ticket
      @product = @ticket.products.first

      Rails.cache.delete([:histories, @product.id])
      Rails.cache.delete([:join, @ticket.id])
    end

    respond_to do |format|
      format.html {render "tickets/tickets_pack/approve_manufacture_parts/approve_manufacture_parts"}
    end
  end

  def update_approve_manufacture_parts

    @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]
    d46_manufacture_part_approved = "N"
 
    if @continue

      @ticket_spare_part = TicketSparePart.find params[:request_spare_part_id]

      if @ticket_spare_part.status_action_id == SparePartStatusAction.find_by_code("CLS").id
        @terminated = true
        bpm_variables = view_context.initialize_bpm_variables.merge(d46_manufacture_part_approved: d46_manufacture_part_approved)

        @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if @bpm_response[:status].upcase == "SUCCESS"
          flash[:error] = "Request allready terminated."
        else
          flash[:error] = "Request allready terminated. but Bpm error"
        end
      else

        @ticket_spare_part.update ticket_spare_part_params(@ticket_spare_part)

        if @ticket_spare_part.request_approved

          #update record spt_ticket_spare_part
          @ticket_spare_part.update request_approved_at: DateTime.now, request_approved_by: current_user.id, status_action_id: SparePartStatusAction.find_by_code("APM").id

          #Approve Spare Part Manufacture
          action_id = TaskAction.find_by_action_no(89).id
          d46_manufacture_part_approved = "Y"

          # @ticket_spare_part.update status_action_id: SparePartStatusAction.find_by_code("APM").id
          @ticket_spare_part.ticket_spare_part_status_actions.create(status_id: @ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

        else
          #Reject Spare Part Manufacture
          action_id = TaskAction.find_by_action_no(90).id

          @ticket_spare_part.update status_action_id: SparePartStatusAction.find_by_code("CLS").id

          @ticket_spare_part.ticket_spare_part_status_actions.create([{status_id: SparePartStatusAction.find_by_code("RJM").id, done_by: current_user.id, done_at: DateTime.now}, {status_id: SparePartStatusAction.find_by_code("CLS").id , done_by: current_user.id, done_at: DateTime.now}])
        end

        user_ticket_action = @ticket_spare_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket_spare_part.ticket.re_open_count, action_id: action_id)
        user_ticket_action.build_request_spare_part(ticket_spare_part_id: @ticket_spare_part.id)
        user_ticket_action.save

        query = {ticket_id: @ticket_spare_part.ticket_id, request_spare_part_id: @ticket_spare_part.id, supp_engr_user: params[:supp_engr_user], d46_manufacture_part_approved: d46_manufacture_part_approved}

        # bpm_variables = view_context.initialize_bpm_variables.merge(d46_manufacture_part_approved: d46_manufacture_part_approved)

        @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: query

        if @bpm_response[:status].upcase == "SUCCESS"
          # view_context.ticket_bpm_headers params[:process_id], @ticket_spare_part.ticket.id, @ticket_spare_part.id
          flash[:notice] = "Successfully updated."
        else
          flash[:error] = "ticket is updated. but Bpm error"
        end

      end
    else
      flash[:error] = "ticket is not updated. Bpm error"
    end
    redirect_to todos_url
  end

  def ticket_close_approval
    Inventory
    Warranty
    ContactNumber
    QAndA
    TaskAction
    User
    ticket_id = params[:ticket_id]
    @ticket = Ticket.find_by_id ticket_id
    session[:ticket_id] = @ticket.id

    supp_engr_user = params[:supp_engr_user]

    if @ticket
      @product = @ticket.products.first

      Rails.cache.delete([:histories, @product.id])
      Rails.cache.delete([:join, @ticket.id])
    end

    respond_to do |format|
      format.html {render "tickets/tickets_pack/ticket_close_approval"}
    end
  end

  def collect_parts

    Warranty
    TaskAction
    Inventory
    TicketSparePart
    Product

    unless request.xhr?

      session[:manufacture_ids] = []
      session[:product_brand_id] = nil
      ticket_id = params[:ticket_id]
      @ticket = Ticket.find_by_id ticket_id
      session[:ticket_id] = @ticket.id
      request_spare_part_id = params[:request_spare_part_id]
      # @spare_part = TicketSparePart.find request_spare_part_id
      @spare_part = @ticket.ticket_spare_parts.find request_spare_part_id

      @manufacture_parts = []#ReturnPartsBundle.all

      if @ticket
        @product = @ticket.products.first
        Rails.cache.delete([:histories, @product.id])
        Rails.cache.delete([:join, @ticket.id])
      end
      render "tickets/tickets_pack/collect_parts/collect_parts"
    else
      @ticket = Ticket.find session[:ticket_id]

      session[:product_brand_id] = params[:product_brand_id]

      case params[:template]
      when "collect_parts"
        # @manufacture_parts = TicketSparePartManufacture.includes(:return_parts_bundle).where(spt_return_parts_bundle: {product_brand_id: params[:product_brand_id]})
        @manufacture_parts = TicketSparePartManufacture.joins(ticket_spare_part: {ticket: {products: :product_brand}}).where(mst_spt_product_brand: {id: params[:product_brand_id]}, collect_pending_manufacture: true, collected_manufacture: false)
        @manufacture = ProductBrand.find(params[:product_brand_id]) if params[:product_brand_id].present?
        @template = 'tickets/tickets_pack/collect_parts/collect_parts'
      when "deliver_bundle"
      when "bundle_return_part"
        session[:manufacture_ids] = []
        @manufacture_parts = TicketSparePartManufacture.joins(ticket_spare_part: {ticket: {products: :product_brand}}).where(mst_spt_product_brand: {id: params[:product_brand_id]}, ready_to_bundle: true, bundled: false)
        @manufacture = ProductBrand.find(params[:product_brand_id]) if params[:product_brand_id].present?
        session[:manufacture_ids] = @manufacture_parts.ids
        session[:manufacture_rest_ids] = []
        @template = 'tickets/tickets_pack/bundle_return_part/bundle_return_part'
      end
      render "tickets/tickets_pack/collect_parts/collect_parts.js.haml"

    end
  end

  def update_request_close_approval

    TaskAction
    TicketSparePart
    @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]
    engineer_id = params[:engineer_id]

    if @continue

      ticket_workfows = @ticket.ticket_workflow_processes.where process_id: params[:process_id]
      ticket_engineers = @ticket.ticket_engineers.where(workflow_process_id: ticket_workfows.first.try(:id))

      engineer_close_approval_required = (@ticket.ticket_fsrs.any?{|fsr| ticket_engineers.ids.include?(fsr.engineer_id) } or @ticket.ticket_spare_parts.any?{|part| ticket_engineers.ids.include?(part.engineer_id) } or @ticket.ticket_on_loan_spare_parts.any?{|onloanpart| ticket_engineers.ids.include?(onloanpart.engineer_id) })

      @ticket_engineer = TicketEngineer.find engineer_id

      @ticket_engineer.update status: (engineer_close_approval_required ? 2 : 3) , job_completed_at: DateTime.now, job_close_approval_required: engineer_close_approval_required, job_close_approval_requested: engineer_close_approval_required, job_closed_at: (engineer_close_approval_required ? nil : DateTime.now)


      job_finished = (@ticket_engineer.status > 1 or @ticket.job_finished)

      if job_finished and engineer_close_approval_required

        @ticket.attributes = ticket_params
        @ticket.ticket_close_approval_requested = true

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id, d7_close_approval_requested: "Y", d4_job_complete: "Y", d9_qc_required: (@ticket.ticket_type.code == "IH" ? "Y" : "N"), d10_job_estimate_required_final: ((@ticket.cus_chargeable or @ticket.cus_payment_required) ? "Y" : "N"), d12_need_to_invoice: ((@ticket.cus_chargeable or @ticket.cus_payment_required) ? "Y" : "N"), d6_close_approval_required: "Y")

        @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(55).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count, action_engineer_id: engineer_id)

        @ticket.ticket_close_approval_required = (@ticket.ticket_fsrs.any? or @ticket.ticket_spare_parts.any? or @ticket.ticket_on_loan_spare_parts.any?)
        @ticket.ticket_close_approval_requested = true
        @ticket.ticket_close_approved = true

        if @ticket.ticket_close_approval_required
          @ticket.ticket_engineers.each do |eng|
            if eng.job_close_approval_required
              @ticket.ticket_close_approval_requested = false if eng.job_close_approval_required and not eng.job_close_approval_requested
              @ticket.ticket_close_approved = false if eng.job_close_approval_required and not eng.job_close_approved
            end
          end
        else
          @ticket.ticket_close_approval_requested = false
          @ticket.ticket_close_approved = false
        end

        if @ticket.save

          @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          if @bpm_response[:status].upcase == "SUCCESS"
            @flash_message = "Successfully updated."
          else
            @flash_message = "ticket is updated. but Bpm error"
          end
        else
          flash[:error] = "Unable to update. Please re-try with validation."
        end
      else
        @flash_message = "ticket is failed to updated."
      end
    else
      @flash_message = @flash_message
    end
    redirect_to @ticket, notice: @flash_message
  end

  def update_collect_parts
    TicketSparePart
    @continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

    if @continue

      if params[:manufacture_part]

        TicketSparePartManufacture.where(id: params[:manufacture_part]).each do |ticket_spare_part_manufacture|

          ticket_spare_part_manufacture.update(collected_manufacture: true, collect_pending_manufacture: false)
          ticket_spare_part_manufacture.ticket_spare_part.update(status_action_id: SparePartStatusAction.find_by_code("CLT").id)
          ticket_spare_part_manufacture.ticket_spare_part.ticket_spare_part_status_actions.create(status_id: ticket_spare_part_manufacture.ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

          user_ticket_action = ticket_spare_part_manufacture.ticket_spare_part.ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(36).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: ticket_spare_part_manufacture.ticket_spare_part.ticket.re_open_count)
          user_ticket_action.build_request_spare_part(ticket_spare_part_id: ticket_spare_part_manufacture.ticket_spare_part.id)
          user_ticket_action.save

          ticket_id = ticket_spare_part_manufacture.ticket_spare_part.ticket.id
          ticket_spare_part_id = ticket_spare_part_manufacture.ticket_spare_part.id
          process = TicketWorkflowProcess.where(spare_part_id: ticket_spare_part_id, ticket_id: ticket_id, process_name: "SPPT_MFR_PART_REQUEST").last

          if process
            process_id = process.process_id

            view_context.ticket_bpm_headers process_id, ticket_id, ticket_spare_part_id
            Rails.cache.delete([:workflow_header, process_id])
          end

        end
        flash[:notice] = "Successfully updated."
      end

      # bpm output variables
      d31_more_parts_collection_pending = TicketSparePart.any?{|sp| sp.ticket_spare_part_manufacture.try(:collect_pending_manufacture)} ? "Y" : "N"
      bpm_variables = view_context.initialize_bpm_variables.merge(d31_more_parts_collection_pending: d31_more_parts_collection_pending)

      @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

      unless @bpm_response[:status].upcase == "SUCCESS"
        flash[:error]= "Bpm error"
      end

    else
      flash[:error]= "Please check the Bpm and re-try."
    end

    redirect_to todos_url
  end

  def return_store_part
    ContactNumber
    QAndA
    TaskAction
    TicketSparePart
    Inventory
    Warranty
    Gin
    Grn
    Srr
    Inventory

    @ticket = Ticket.find_by_id params[:ticket_id]

    @onloan_request = true if params[:onloan_request] == "Y"

    if @onloan_request
      @onloan_spare_part = @ticket.ticket_on_loan_spare_parts.find params[:request_onloan_spare_part_id]
      @spare_part = @onloan_spare_part.ticket_spare_part
    else
      @spare_part = @ticket.ticket_spare_parts.find params[:request_spare_part_id]
    end

    if @ticket
      @product = @ticket.products.first
      Rails.cache.delete([:histories, @product.id])
      Rails.cache.delete([:join, @ticket.id])
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/return_store_part/return_store_part"}
    end
  end

  def received_and_issued
    Inventory
    Warranty
    ContactNumber
    QAndA
    TaskAction
    Inventory
    ticket_id = (params[:ticket_id] or session[:ticket_id])
    @ticket = Ticket.find_by_id ticket_id
    session[:ticket_id] = @ticket.id
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/received_and_issued/received_and_issued"}
    end
  end

  def estimate_the_part_internal
    Inventory
    Warranty
    ContactNumber
    QAndA
    TaskAction
    Inventory
    TicketEstimation
    Tax
    Grn
    Organization
    TicketSparePart
    ticket_id = params[:ticket_id]
    @ticket = Ticket.find ticket_id
    @product = @ticket.products.first

    if @ticket
      @estimation = TicketEstimation.find params[:part_estimation_id]
      @paginate_array = []

      if @estimation.ticket_estimation_parts.present?
        part_store_or_non_stock = (@estimation.ticket_estimation_parts.first.ticket_spare_part.ticket_spare_part_store or @estimation.ticket_estimation_parts.first.ticket_spare_part.ticket_spare_part_manufacture or @estimation.ticket_estimation_parts.first.ticket_spare_part.ticket_spare_part_non_stock)
        # part_store_or_non_stock = @estimation.ticket_estimation_parts.first.ticket_spare_part.ticket_spare_part_store
        # @paginate_array = part_store_or_non_stock.inventory_product.grn_items.order("grn_id DESC") if [TicketSparePartStore].include?(part_store_or_non_stock.class)
        @paginate_array = GrnItem.search(query: "inventory_product.id:#{part_store_or_non_stock.inventory_product.id}") if [TicketSparePartStore].include?(part_store_or_non_stock.class)

      end

      @paginate_grn_items = Kaminari.paginate_array(@paginate_array).page(params[:page]).per(10)
      # part_store_or_non_stock = (@estimation.ticket_estimation_parts.try(:ticket_spare_part).try(:ticket_spare_part_store) or @estimation.ticket_estimation_parts.try(:ticket_spare_part).try(:ticket_spare_part_non_stock))
      # @paginate_grn_items = part_store_or_non_stock.inventory_product.grn_items.order("grn_id DESC")

    end
    @pass_this = "yes"

    Rails.cache.delete([:histories, @product.id])
    Rails.cache.delete([:join, @ticket.id])

    respond_to do |format|
      format.html {render "tickets/tickets_pack/estimate_the_part_internal/estimate_the_part_internal"}
    end
  end

  def update_received_and_issued
    TaskAction
    spt_ticket_spare_part = TicketSparePart.find params[:request_spare_part_id]
    @ticket = spt_ticket_spare_part.ticket
    issue = (params[:issue].present? and params[:issue].to_bool)
    receive_screen = false

    @continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

    if @continue

      spt_ticket_spare_part.update ticket_spare_part_params(spt_ticket_spare_part)

      if spt_ticket_spare_part.part_terminated


        if (spt_ticket_spare_part.status_action_id != SparePartStatusAction.find_by_code("CLS").id)

          spt_ticket_spare_part.update_attributes status_action_id: SparePartStatusAction.find_by_code("CLS").id

          spt_ticket_spare_part.ticket_spare_part_status_actions.create(status_id: spt_ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

          # Set Action (34) Terminate Spare Part Order, DB.spt_act_request_spare_part.
          user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(34).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
          user_ticket_action.build_request_spare_part(ticket_spare_part_id: spt_ticket_spare_part.id, part_terminate_reason_id: spt_ticket_spare_part.part_terminated_reason_id)
          user_ticket_action.save

          @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

          if (spt_ticket_spare_part.ticket_spare_part_manufacture)
            spt_ticket_spare_part.ticket_spare_part_manufacture.update po_required: false
          end

        end

        # bpm output variables
        bpm_variables = view_context.initialize_bpm_variables

        @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if @bpm_response[:status].upcase == "SUCCESS"

          email_template = EmailTemplate.find_by_code("PART_TERMINATED")

          email_to = spt_ticket_spare_part.engineer.user.email
          if email_template.try(:active)
            view_context.send_email(email_to: email_to, ticket_id: @ticket.id, engineer_id: spt_ticket_spare_part.engineer.id, spare_part_id: spt_ticket_spare_part.id, email_code: "PART_TERMINATED") if email_to.present?
          end

          @flash_message = {notice: "Successfully updated"}
        else
          @flash_message = {error: "ticket is updated. but Bpm error"}
        end

      end

      if !spt_ticket_spare_part.part_terminated and spt_ticket_spare_part.ticket_spare_part_manufacture.try(:collected_manufacture) and !spt_ticket_spare_part.ticket_spare_part_manufacture.try(:received_manufacture) #DB.spt_ticket_spare_part.status_action_id = CLT (Collected)

        receive_screen = true

        spt_ticket_spare_part.update(status_action_id: SparePartStatusAction.find_by_code("RCS").id)

        spt_ticket_spare_part.ticket_spare_part_status_actions.create(status_id: spt_ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

        spt_ticket_spare_part.ticket_spare_part_manufacture and spt_ticket_spare_part.ticket_spare_part_manufacture.update(received_manufacture: true)

        #Set Action (37) Receive Spare part from Manufacture, DB.spt_act_request_spare_part.
        user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(37).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
        user_ticket_action.build_request_spare_part(ticket_spare_part_id: spt_ticket_spare_part.id)
        user_ticket_action.save

        email_template = EmailTemplate.find_by_code("PART_AVAILABLE")

        email_to = spt_ticket_spare_part.engineer.user.email
        if email_template.try(:active)
          view_context.send_email(email_to: email_to, ticket_id: @ticket.id, engineer_id: spt_ticket_spare_part.engineer.id, spare_part_id: spt_ticket_spare_part.id, email_code: "PART_AVAILABLE") if email_to.present?
        end

        flash[:notice]= "Successfully updated"

      end
      
      if !spt_ticket_spare_part.part_terminated and (!receive_screen or (receive_screen and issue)) and spt_ticket_spare_part.ticket_spare_part_manufacture.try(:received_manufacture) and !spt_ticket_spare_part.ticket_spare_part_manufacture.try(:issued)

        spt_ticket_spare_part.update(status_action_id: SparePartStatusAction.find_by_code("ISS").id)
        spt_ticket_spare_part.ticket_spare_part_status_actions.create(status_id: spt_ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

        spt_ticket_spare_part.ticket_spare_part_manufacture and spt_ticket_spare_part.ticket_spare_part_manufacture.update(issued: true, issued_at: DateTime.now, issued_by: current_user.id)

        #Set Action (38) Issue Spare part, DB.spt_act_request_spare_part
        user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(38).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
        user_ticket_action.build_request_spare_part(ticket_spare_part_id: spt_ticket_spare_part.id)
        user_ticket_action.save

        # bpm output variables
        bpm_variables = view_context.initialize_bpm_variables

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

        @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if @bpm_response[:status].upcase == "SUCCESS"

          WebsocketRails[:posts].trigger 'new', {task_name: "Spare part", task_id: spt_ticket_spare_part.id, task_verb: "received and issued.", by: current_user.email, at: Time.now.strftime('%d/%m/%Y at %H:%M:%S')}

          email_template = EmailTemplate.find_by_code("PART_ISSUED")

          email_to = spt_ticket_spare_part.engineer.user.email
          if email_template.try(:active)
            view_context.send_email(email_to: email_to, ticket_id: @ticket.id, engineer_id: spt_ticket_spare_part.engineer.id, spare_part_id: spt_ticket_spare_part.id, email_code: "PART_ISSUED") if email_to.present?

          end

          flash[:notice]= "Successfully updated"
        else
          flash[:error]= "Issue part is updated. but Bpm error"
        end

      end

    else
      flash[:error]= "Unable to update. Bpm error"
    end
    redirect_to todos_url
  end

  def return_manufacture_part
    Inventory
    Warranty
    ContactNumber
    QAndA
    TaskAction
    Inventory
    TicketSparePart
    ticket_id = params[:ticket_id]
    @ticket = Ticket.find_by_id ticket_id
    session[:ticket_id] = @ticket.id
    if @ticket
      @product = @ticket.products.first
      @ticket_spare_part = TicketSparePart.find params[:request_spare_part_id]
      @ticket_spare_part.request_spare_parts.build
      Rails.cache.delete([:histories, @product.id])
      Rails.cache.delete([:join, @ticket.id])
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/return_manufacture_part/return_manufacture_part"}
    end
  end

  def update_return_manufacture_part
    TaskAction
    spt_ticket_spare_part = TicketSparePart.find params[:request_spare_part_id]
    @ticket = spt_ticket_spare_part.ticket

    @continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])
    if @continue

      spt_ticket_spare_part.update ticket_spare_part_params(spt_ticket_spare_part)

      d33_return_part_reject = "N"
      d34_event_closed = "N"
      d35_parts_bundle_pending = "N"

      if spt_ticket_spare_part.returned_part_accepted
        #Returned Part Accepted
        spt_ticket_spare_part.update(status_action_id: SparePartStatusAction.find_by_code("RPA").id)
        spt_ticket_spare_part.ticket_spare_part_status_actions.create(status_id: spt_ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

        #Set Action (43) Receive Returned part, DB.spt_act_request_spare_part.
        user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(43).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
        user_ticket_action.build_request_spare_part(ticket_spare_part_id: spt_ticket_spare_part.id, reject_return_part_reason_id: params[:manual_reject_return_part_reason_id])
        user_ticket_action.save

        if spt_ticket_spare_part.ticket_spare_part_manufacture.try(:ready_to_bundle)
          #Ready to Bundle
          spt_ticket_spare_part.update(status_action_id: SparePartStatusAction.find_by_code("RBN").id)
          spt_ticket_spare_part.ticket_spare_part_status_actions.create(status_id: spt_ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

          d35_parts_bundle_pending = TicketSparePartManufacture.where.not(id: spt_ticket_spare_part.ticket_spare_part_manufacture.id).any?{ |ticket_spare_part_manufacture| ticket_spare_part_manufacture.ready_to_bundle and not ticket_spare_part_manufacture.bundled } ? "Y" : "N"
        else
          #if no need Ready to Bundle then close
          d35_parts_bundle_pending = "Y"
          spt_ticket_spare_part.update(status_action_id: SparePartStatusAction.find_by_code("CLS").id)
          spt_ticket_spare_part.ticket_spare_part_status_actions.create(status_id: spt_ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)
        end

        if spt_ticket_spare_part.ticket_spare_part_manufacture.try(:event_closed)
          #Event Closed
          #Set Action (44) Close Event, DB.spt_act_request_spare_part
          user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(44).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
          user_ticket_action.build_request_spare_part(ticket_spare_part_id: spt_ticket_spare_part.id, reject_return_part_reason_id: params[:manual_reject_return_part_reason_id])
          user_ticket_action.save

          d34_event_closed = "Y"
        end

      else
        #Returned Part Rejected
        part_returned_by_id = spt_ticket_spare_part.part_returned_by
        spt_ticket_spare_part.update(status_action_id: SparePartStatusAction.find_by_code("RPR").id, part_returned_by: nil, part_returned_at: nil, part_returned: false)
        spt_ticket_spare_part.ticket_spare_part_status_actions.create(status_id: spt_ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

        #Set Action (42) Reject Returned Part, DB.spt_act_request_spare_part
        user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(42).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
        user_ticket_action.build_request_spare_part(ticket_spare_part_id: spt_ticket_spare_part.id, reject_return_part_reason_id: params[:manual_reject_return_part_reason_id])
        user_ticket_action.save

        d33_return_part_reject = "Y"
      end

      # bpm output variables
      bpm_variables = view_context.initialize_bpm_variables.merge(d33_return_part_reject: d33_return_part_reject, d34_event_closed: d34_event_closed, d35_parts_bundle_pending: d35_parts_bundle_pending)

      @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

      if @bpm_response[:status].upcase == "SUCCESS"

        if !spt_ticket_spare_part.returned_part_accepted
          email_to =  User.cached_find_by_id(part_returned_by_id).try(:email)
          if email_to.present?
            view_context.send_email(email_to: email_to, ticket_id: @ticket.id, engineer_id: spt_ticket_spare_part.engineer.id, spare_part_id: spt_ticket_spare_part.id, email_code: "RETURNED_PART_REJECTED")
          end
        end

        flash[:notice]= "Successfully updated"
      else
        flash[:error]= "Return Manufacture part is updated. but Bpm error"
      end
    else
      flash[:error]= "Unable to update. Bpm error"
    end
    redirect_to todos_url

  end

  def bundle_return_part
    Inventory
    Warranty
    ContactNumber
    QAndA
    TaskAction
    TicketSparePart
    Inventory
    Organization
    if request.xhr?
      case params[:task_action]
      when "add"

        session[:manufacture_rest_ids] << session[:manufacture_ids].delete(params[:manufacture_id].to_i)# << params[:manufacture_id]

        @remove_manufactures = TicketSparePartManufacture.where(id: session[:manufacture_rest_ids].uniq, ready_to_bundle: true, bundled: false).map.with_index { |m, index| {id: m.id, indexer: (index+1), event_no: m.event_no, date_returned: m.ticket_spare_part.try(:part_returned_at).try(:strftime, "%m-%d-%Y"), ticket_no: m.ticket_spare_part.ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG["ticket_no_format"]), spare_part_no: m.ticket_spare_part.spare_part_no, spare_part_description: m.ticket_spare_part.spare_part_description , part_serial_no: m.ticket_spare_part.return_part_serial_no, part_status: m.ticket_spare_part.spare_part_status_action.name , task_action: "remove", task_action_name: "remove"} }
        @add_manufactures = TicketSparePartManufacture.where(id: session[:manufacture_ids].uniq, ready_to_bundle: true, bundled: false).map.with_index { |m, index| {id: m.id, indexer: (index+1), event_no: m.event_no, ticket_no: m.ticket_spare_part.ticket.ticket_no.to_s.rjust(6, INOCRM_CONFIG["ticket_no_format"]), spare_part_no: m.ticket_spare_part.spare_part_no, spare_part_description: m.ticket_spare_part.spare_part_description, part_status: m.ticket_spare_part.spare_part_status_action.name, task_action: "add", task_action_name: "add"} }

      when "remove"
        session[:manufacture_ids] << session[:manufacture_rest_ids].delete(params[:manufacture_id].to_i)

        @remove_manufactures = TicketSparePartManufacture.where(id: session[:manufacture_rest_ids].uniq, ready_to_bundle: true, bundled: false).map.with_index { |m, index| {id: m.id, indexer: (index+1), event_no: m.event_no, ticket_no: m.ticket_spare_part.ticket_id.to_s.rjust(6, INOCRM_CONFIG["ticket_no_format"]), spare_part_no: m.ticket_spare_part.spare_part_no, spare_part_description: m.ticket_spare_part.spare_part_description, part_status: m.ticket_spare_part.spare_part_status_action.name, task_action: "remove", task_action_name: "remove"} }
        @add_manufactures = TicketSparePartManufacture.where(id: session[:manufacture_ids].uniq, ready_to_bundle: true, bundled: false).map.with_index { |m, index| {id: m.id, indexer: (index+1), event_no: m.event_no, ticket_no: m.ticket_spare_part.ticket_id.to_s.rjust(6, INOCRM_CONFIG["ticket_no_format"]) , spare_part_no: m.ticket_spare_part.spare_part_no, spare_part_description: m.ticket_spare_part.spare_part_description , part_status: m.ticket_spare_part.spare_part_status_action.name , task_action: "add", task_action_name: "add"} }

      when "undelivered_bundle"
        @bundles = ReturnPartsBundle.where(delivered: false).map.with_index { |r, index| {id: r.id, indexer: (index+1), bundled_no: r.bundle_no, date_bundled: r.created_at.try(:strftime, "%Y-%m-%d"), bundled_by: User.cached_find_by_id(r.created_by).try(:user_name)} }

      when "load_bundled_manufactures"
        @bundle = ReturnPartsBundle.find(params[:manufacture_id])
        manufacture_ids = @bundle.ticket_spare_part_manufacture_ids.uniq
        manufactures_count = manufacture_ids.count
        manufactures_count += session[:manufacture_rest_ids].count

        @bundle_manufactures = TicketSparePartManufacture.where(id: manufacture_ids).map.with_index { |m, index| {id: m.id, indexer: (index+1), date_returned: m.return_parts_bundle.try(:created_at).try(:strftime, "%m-%d-%Y"), event_no: m.event_no, ticket_no:  m.ticket_spare_part.ticket_id.to_s.rjust(6, INOCRM_CONFIG["ticket_no_format"]), spare_part_no: m.ticket_spare_part.spare_part_no, spare_part_description: m.ticket_spare_part.spare_part_description, serial_no: m.ticket_spare_part.return_part_serial_no, part_status: m.ticket_spare_part.spare_part_status_action.name, task_action: "remove_from_bundle", task_action_name: "remove from bundle"} }

        @bundle = {bundle_id: @bundle.id, bundle_note: @bundle.note, bundle_no: @bundle.bundle_no, bundled_by: User.cached_find_by_id(@bundle.created_by).try(:email), manufacture_count: manufactures_count, readonly: "readonly", task_id: session[:task_id], process_id: session[:process_id], owner: session[:owner]}

      when "new_bundle"
        # @bundle_manufactures = TicketSparePartManufacture.where(id: session[:manufacture_rest_ids].uniq).map { |m| {id: m.id, event_no: m.event_no, ticket_no: m.ticket_spare_part.ticket_id, task_action: "remove", task_action_name: "remove"} }
        @bundle_manufactures = []
        manufactures_count = session[:manufacture_rest_ids].count
        # @bundle = {bundled_by: current_user.try(:email), date_bundled: Date.today.try(:strftime, "%Y-%m-%d"), manufacture_count: 0, readonly: "readonly", task_id: session[:task_id], process_id: session[:process_id], owner: session[:owner]}
        @bundle = {bundled_by: current_user.try(:email), date_bundled: Date.today.try(:strftime, "%Y-%m-%d"), manufacture_count: manufactures_count, readonly: "", task_id: session[:task_id], process_id: session[:process_id], owner: session[:owner]}
      when "remove_from_bundle"
        @ticket_spare_part_manufacture = TicketSparePartManufacture.find_by_id params[:manufacture_id]
        return_parts_bundle = @ticket_spare_part_manufacture.return_parts_bundle
        unless return_parts_bundle.delivered
          return_parts_bundle.ticket_spare_part_manufactures.delete(@ticket_spare_part_manufacture)

          @ticket_spare_part_manufacture.update ready_to_bundle: true, bundled: false, add_bundle_by: nil, add_bundle_at: nil
          @ticket_spare_part_manufacture.ticket_spare_part.update status_action_id: SparePartStatusAction.find_by_code("RBN").id

          @ticket_spare_part_manufacture.ticket_spare_part.ticket_spare_part_status_actions.create(status_id: @ticket_spare_part_manufacture.ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)


          @bundle_manufactures = return_parts_bundle.ticket_spare_part_manufactures.map { |m| {id: m.id, event_no: m.event_no, ticket_no: m.ticket_spare_part.ticket_id, task_action: "remove_from_bundle", task_action_name: "remove from bundle"} }

          session[:manufacture_ids] << params[:manufacture_id].to_i
        else
          @error_message = "Unable to remove. Because bundle is already delivered."
        end

        @add_manufactures = TicketSparePartManufacture.where(id: session[:manufacture_ids].uniq, ready_to_bundle: true, bundled: false).map.with_index { |m, index| {id: m.id, indexer: (index+1), event_no: m.event_no, ticket_no: m.ticket_spare_part.ticket_id, task_action: "add", task_action_name: "add"} }
      end
      render json: {add_manufactures: @add_manufactures, remove_manufactures: @remove_manufactures, bundles: @bundles, bundle_manufactures: @bundle_manufactures, bundle: @bundle, error_message: @error_message}
    else
      session[:manufacture_ids] = session[:manufacture_rest_ids] = []
      ticket_id = (params[:ticket_id] or session[:ticket_id])
      @ticket = Ticket.find_by_id ticket_id
      session[:ticket_id] = @ticket.id

      request_spare_part_id = params[:request_spare_part_id]
      # @spare_part = TicketSparePart.find request_spare_part_id
      session[:request_spare_part_id] = params[:request_spare_part_id]
      @manufacture_parts = []

      if @ticket
        @product = @ticket.products.first
        Rails.cache.delete([:histories, @product.id])
        Rails.cache.delete([:join, @ticket.id])
      end
      respond_to do |format|
        format.html {render "tickets/tickets_pack/bundle_return_part/bundle_return_part"}
      end
    end
  end

  def update_bundle_return_part
    # @ticket_spare_part = TicketSparePart.find params[:request_spare_part_id]
    # if @ticket_spare_part.update(ticket_spare_part_params)
    #   flash[:notice] = "Spare part is successfully saved."
    # end
    TicketSparePart
    if return_bundle_params[:id].present?
      @return_bundle = ReturnPartsBundle.find return_bundle_params[:id]
      @return_bundle.attributes = return_bundle_params
    else
      @return_bundle = ReturnPartsBundle.new return_bundle_params
      @new_bundle = true
    end
    @return_bundle.product_brand_id = session[:product_brand_id]
    @return_bundle.created_by = current_user.id

    @continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])
    if @continue

      if !@new_bundle and @return_bundle.delivered
        flash[:notice]= "Bundle is already delivered"
      else

        if @return_bundle.save
          @return_bundle.ticket_spare_part_manufacture_ids = (session[:manufacture_rest_ids] + @return_bundle.ticket_spare_part_manufacture_ids).uniq

          @return_bundle.ticket_spare_part_manufactures.each do |ticket_spare_part_manufacture|

            ticket_spare_part_manufacture.update(ready_to_bundle: false, bundled: true, add_bundle_by: current_user.id, add_bundle_at: DateTime.now)

            #Part Bundled
            ticket_spare_part_manufacture.ticket_spare_part.update(status_action_id: SparePartStatusAction.find_by_code("BND").id)
            ticket_spare_part_manufacture.ticket_spare_part.ticket_spare_part_status_actions.create(status_id: ticket_spare_part_manufacture.ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)
     
            #Set Action (45) Part Bunndled, DB.spt_act_request_spare_part for all added parts
            user_ticket_action = ticket_spare_part_manufacture.ticket_spare_part.ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(45).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: ticket_spare_part_manufacture.ticket_spare_part.ticket.re_open_count)
            user_ticket_action.build_request_spare_part(ticket_spare_part_id: ticket_spare_part_manufacture.ticket_spare_part.id)
            user_ticket_action.save

          end

          # bpm output variables
          d36_more_parts_bundle_pending = TicketSparePartManufacture.any?{ |ticket_spare_part_manufacture| ticket_spare_part_manufacture.ready_to_bundle and not ticket_spare_part_manufacture.bundled } ? "Y" : "N"
          bpm_variables = view_context.initialize_bpm_variables.merge(d36_more_parts_bundle_pending: d36_more_parts_bundle_pending, bundle_id: @return_bundle.id)

          @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          if @bpm_response[:status].upcase == "SUCCESS"

            flash[:notice]= "Successfully updated"
          else
            flash[:error]= "Bundle is updated. but Bpm error"
          end

        else
          flash[:error]= "Unable to update. Please check bpm."

        end

      end
    else
      flash[:error]= "Unable to update. Bpm error"
    end
    redirect_to todos_url
  end

  def deliver_bundle
    Inventory
    Product
    Warranty
    ContactNumber
    QAndA
    TaskAction
    Inventory
    TicketSparePart

    bundle_id = params[:bundle_id]
    @return_bundle = ReturnPartsBundle.find bundle_id
    @return_bundle_manufactures = @return_bundle.ticket_spare_part_manufactures.where(collected_manufacture: true)
    session[:bundle_id] = params[:bundle_id]

    if @ticket
      @product = @ticket.products.first
      Rails.cache.delete([:histories, @product.id])
      Rails.cache.delete([:join, @ticket.id])
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/deliver_bundle/deliver_bundle"}
    end
  end

  def update_deliver_bundle

    TicketSparePart

    @return_bundle = ReturnPartsBundle.find return_bundle_params[:id]

    @continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])
    if @continue

      if !@return_bundle.delivered

        @return_bundle.update(return_bundle_params)
        @return_bundle.update(delivered: true, delivered_at: DateTime.now, delivered_by: current_user.id)

        @return_bundle.ticket_spare_part_manufactures.each do |ticket_spare_part_manufacture|

          #Part Closed
          ticket_spare_part_manufacture.ticket_spare_part.update(status_action_id: SparePartStatusAction.find_by_code("CLS").id)
          ticket_spare_part_manufacture.ticket_spare_part.ticket_spare_part_status_actions.create(status_id: ticket_spare_part_manufacture.ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)
    
          #Set Action (46) Part Bunndl Delivered for all added parts
          user_ticket_action = ticket_spare_part_manufacture.ticket_spare_part.ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(46).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: ticket_spare_part_manufacture.ticket_spare_part.ticket.re_open_count)
          user_ticket_action.build_request_spare_part(ticket_spare_part_id: ticket_spare_part_manufacture.ticket_spare_part.id)
          user_ticket_action.save

        end
      else
        flash[:alert]= "Bundle already delivered."
      end

      # bpm output variables
      bpm_variables = view_context.initialize_bpm_variables
      @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

      if @bpm_response[:status].upcase == "SUCCESS"

        flash[:notice]= "Successfully updated"
      else
        flash[:error]= "Bundle is updated. but Bpm error"
      end

    else
      flash[:error]= "Unable to update. Bpm error"
    end
    redirect_to todos_url
  end

  def terminate_invoice
    Inventory
    Warranty
    ContactNumber
    QAndA
    TaskAction
    Invoice
    ticket_id = (params[:ticket_id] or session[:ticket_id])
    @ticket = Ticket.find_by_id ticket_id
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])

      @ticke_action = @ticket.user_ticket_actions.find_by_action_id 18
      @terminate_invoice = TerminateInvoice.new

    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/terminate_invoice"}
    end
  end

  def customer_advance_payment
    User
    if params[:customer_name].present?
      search_customer_name = params[:customer_name]
      @tickets = Kaminari.paginate_array(Ticket.joins(:customer).where(" spt_ticket.status_id != ? and spt_ticket.cus_payment_required = ? and spt_ticket.cus_payment_completed = ?", 9, true, false ).where("spt_customer.name like ?", "%#{search_customer_name}%")).page(params[:page]).per(3)
    else
      @tickets = Kaminari.paginate_array(Ticket.where("spt_ticket.status_id != ? and spt_ticket.cus_payment_required = ? and spt_ticket.cus_payment_completed = ?", 9, true, false )).page(params[:page]).per(3)
    end
    render "tickets/tickets_pack/customer_advance_payment/customer_advance_paymente"
  end

  def create_invoice_for_hp
    authorize! :create_invoice_for_hp, SoPo
    Inventory
    TicketSparePart
    Product
  end

  def js_call_invoice_for_hp
    Inventory
    TicketSparePart
    Product
    User
    if params[:product_brand_id].present?
      @product_brand_id = ProductBrand.find params[:product_brand_id]
    end
  end

  def js_call_invoice_item
    Invoice
    TicketSparePart
    User
    if params[:po_id].present?
      @so_po_id = SoPo.find params[:po_id]
      @invoice = Invoice.new
      @invoice_all = Invoice.all
      @so_po_id.so_po_items.each do |po_item|
        @invoice.invoice_items.build item_no: po_item.item_no, amount: po_item.amount
      end
    end
  end

  def js_call_view_more_inv_so
    Invoice
    TicketSparePart
    User
    if params[:po_id].present?
      @so_po_id = SoPo.find params[:po_id]
    end

    if params[:inv_id].present?
      @inv_id = Invoice.find params[:inv_id]
    end
  end

  def edit_po_note
    TicketSparePart
    if params[:edit]
      @soponote = SoPo.find params[:so_po_id]
      if @soponote.update po_params
        params[:edit] = nil
        render json: @soponote
      else
        render json: @soponote.errors.full_messages.join
      end
    end
  end

  def create_invoice_for_so
    Invoice
    TicketSparePart
    User
    so_po = SoPo.find params[:so_po_id]

    @invoice = Invoice.new invoice_so_params
    if @invoice.save
      so_po.update invoice_id: @invoice.id

      flash[:notice] = "Successfully saved."
    else
      flash[:alert] = "Unable to save. Please review..."
    end
    respond_to do |format|
      format.html { redirect_to create_invoice_for_hp_tickets_path }
    end
  end

  def invoice_advance_payment

    Inventory
    Warranty
    ContactNumber
    QAndA
    TaskAction
    TicketEstimation
    Tax
    Invoice

    ticket_id = params[:ticket_id]
    @ticket = Ticket.find_by_id ticket_id
    session[:ticket_id] = @ticket.id
    if @ticket
      @product = @ticket.products.first
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])
      @continue_info = true

      ticket_estimations = @ticket.ticket_estimations.where(foc_approved: false, cust_approved: true)
      total_part_cost = total_part_tax = total_additional_cost = total_additional_tax = 0

      ticket_estimations.each do |estimation|
        ticket_estimation_parts = estimation.ticket_estimation_parts

        ticket_estimation_additionals = estimation.ticket_estimation_additionals

        total_additional_cost += ticket_estimation_additionals.to_a.sum{|e| estimation.approval_required ? e.approved_estimated_price : e.estimated_price }

        total_additional_tax += ticket_estimation_additionals.to_a.sum{|e| estimation.approval_required ? e.ticket_estimation_additional_taxes.sum(:approved_tax_amount) : e.ticket_estimation_additional_taxes.sum(:estimated_tax_amount) }

        total_part_cost += ticket_estimation_parts.to_a.sum{|e| estimation.approval_required ? e.approved_estimated_price : e.estimated_price }

        total_part_tax += ticket_estimation_parts.to_a.sum{|e| estimation.approval_required ? e.ticket_estimation_part_taxes.sum(:approved_tax_amount) : e.ticket_estimation_part_taxes.sum(:estimated_tax_amount) }
      end

      @deducted_amount = @ticket.final_invoice.try(:total_deduction).to_f

      final_tot_tax = total_part_tax + total_additional_tax
      @total_estimation_amount = total_part_cost + total_additional_cost + final_tot_tax

      @ticket_payment_received = @ticket.ticket_payment_receiveds.build


      @total_minimum_amount = @ticket.ticket_estimations.where(foc_approved: false, cust_approved: true).inject(0){|i, k| k.approval_required ? i+k.approved_adv_pmnt_amount.to_f : i+k.advance_payment_amount.to_f }

      @all_payment_received = @ticket.ticket_payment_receiveds.sum(:amount)


    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/invoice_advance_payment/invoice_advance_payment"}
    end
  end

  def customer_inquire
    Ticket
    User
    Product
    Warranty
    @tickets = Ticket.search(params)

    render "tickets/tickets_pack/customer_inquire/customer_inquire"
  end
  def onloan_return_pending_parts
    authorize! :onloan_return_pending_parts, Ticket
    Product
    TicketSparePart
    if params[:search].present?
      refined_onloan_return_pending_parts = params[:search_return_part].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
    end
    params[:query] = refined_onloan_return_pending_parts
    @return_parts = TicketOnLoanSparePart.search(params)
    render "onloan_returns/onloan_return_pending_parts"
  end
  def delete_add_edit_contract
    Ticket
    User
    SlaTime
    @contract = TicketContract.find params[:contract_id]
    if @contract.present?
      @contract.delete
    end
    respond_to do |format|
      format.html { redirect_to add_edit_contract_tickets_path }
    end
  end

  def add_edit_contract
    Ticket
    User
    SlaTime
    if params[:edit]

      if params[:contract_id]
        @contract = TicketContract.find params[:contract_id]
        if @contract.update add_edit_contract_params
          params[:edit] = nil
          render json: @contract
        else
          render json: @contract.errors.full_messages.join
        end
      end

    else

      if params[:create]
        @contract = TicketContract.new add_edit_contract_params
        if @contract.save!
          params[:create] = nil
          @contract = TicketContract.new
        else
          flash[:error] = "Unable to save"
        end
      else
        @contract = TicketContract.new
      end
    end
    @contract_all = TicketContract.order(updated_at: :desc)
  end

  def alert

    Inventory
    Warranty
    ContactNumber
    QAndA
    TaskAction
    Inventory

    ticket_id = (params[:ticket_id] or session[:ticket_id])
    @ticket = Ticket.find_by_id ticket_id

    if @ticket
      @product = @ticket.products.first
      @estimation = @ticket.ticket_estimations.first
      @spare_part = @ticket.ticket_spare_parts.first
    end

    respond_to do |format|
      format.html {render "tickets/alerts"}
    end
  end

  def close_event
    Inventory
    Warranty
    ContactNumber
    QAndA
    TaskAction
    Inventory
    ticket_id = params[:ticket_id]
    @ticket = Ticket.find_by_id ticket_id
    session[:ticket_id] = @ticket.id

    request_spare_part_id = params[:request_spare_part_id]
    @spare_part = TicketSparePart.find request_spare_part_id

    if @ticket
      @product = @ticket.products.first
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/close_event"}
    end
  end

  def update_close_event
    TaskAction
    ticket_spare_part = TicketSparePart.find params[:request_spare_part_id]
    @ticket = ticket_spare_part.ticket
    @continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])
    if @continue
      if ticket_spare_part.update ticket_spare_part_params(ticket_spare_part)

        if ticket_spare_part.ticket_spare_part_manufacture.try(:event_closed)
          #Event Closed
          #Set Action (44) Close Event, DB.spt_act_request_spare_part
          user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(44).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
          user_ticket_action.build_request_spare_part(ticket_spare_part_id: ticket_spare_part.id, reject_return_part_reason_id: params[:manual_reject_return_part_reason_id])
          user_ticket_action.save

          # bpm output variables
          bpm_variables = view_context.initialize_bpm_variables
          @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          if @bpm_response[:status].upcase == "SUCCESS"

            flash[:notice]= "Successfully updated"
          else
            flash[:error]= "Close Event is updated. but Bpm error"
          end
        else
          flash[:notice] = "Successfully updated"
        end

      end
    else
      flash[:error]= "Unable to update. Bpm error"
    end
    redirect_to todos_url
  end

  def edit_ticket
    ContactNumber
    QAndA
    TaskAction
    Inventory
    @ticket = Ticket.find_by_id params[:ticket_id]
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])
    end
    params[:edit_ticket] = true
    respond_to do |format|
      format.html {render "tickets/tickets_pack/edit_ticket"}
    end
  end

  def update_edit_ticket
    @ticket = Ticket.find params[:ticket_id]
    update_completed = params[:update_complete].present?
    @ticket.attributes = ticket_params

    if @ticket.save
      if request.xhr?
        render json: @ticket
      else
        if update_completed
          @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]
          if @continue
            if @ticket.status_id == TicketStatus.find_by_code("CLS").id
              flash[:error] = "Ticket is closed."
            else
              # bpm output variables
              di_pop_approval_pending = ["RCD", "RPN", "APN", "LPN", "APV"].include?(@ticket.products.first.product_pop_status.try(:code)) ? "Y" : "N"
              priority = @ticket.priority

              bpm_variables = view_context.initialize_bpm_variables.merge(di_pop_approval_pending: di_pop_approval_pending, priority: priority)

              @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

              if @bpm_response[:status].upcase == "SUCCESS"
                view_context.ticket_bpm_headers params[:process_id], @ticket.id, ""
                flash[:notice] = "Successfully updated."
              else
                flash[:error] = "ticket is updated. but Bpm error"
              end
            end

          else
            flash[:error] = "Bpm error!"

          end
        else
          flash[:notice] = "Successfully saved."
        end
        redirect_to todos_url
      end
    else
      flash[:error] = "Unable to update. Please try again!"
    end

  end

  def edit_serial
    ContactNumber
    QAndA
    TaskAction
    Inventory
    TicketSparePart
    @ticket = Ticket.find_by_id params[:ticket_id]
    @edit_serial = true
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])

    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/edit_serial"}
    end
  end

  def update_edit_serial
    Ticket
    @product = Product.find params[:product_id]
    @ticket = @product.tickets.first

    @continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])
    if @continue
      if @product.update product_params

        # Set Action (35) "Edit Serial No".
        user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(35).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
        user_ticket_action.save

        if params[:complete_task]

          # bpm output variables
          bpm_variables = view_context.initialize_bpm_variables

          @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

          @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          if @bpm_response[:status].upcase == "SUCCESS"
            @flash_message = {notice: "Successfully updated"}
          end
        end
        WebsocketRails[:posts].trigger 'new', {task_name: "Serial no for", task_id: @ticket.id, task_verb: "updated.", by: current_user.email, at: Time.now.strftime('%d/%m/%Y at %H:%M:%S')}

        @flash_message = {notice: "Successfully updated"}
      else
        @flash_message = {error: "Unable to updated."}
      end
    else
      @flash_message = {error: "product is not updated. Bpm error"}
    end
    redirect_to todos_url, @flash_message
  end

  def estimate_job
    ContactNumber
    QAndA
    TaskAction
    TicketEstimation
    Inventory
    Tax
    @ticket = Ticket.find_by_id params[:ticket_id]
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/estimate_job"}
    end
  end

  def estimate_job_final
    ContactNumber
    QAndA
    TaskAction
    TicketEstimation
    Inventory
    Invoice
    Tax
    @ticket = Ticket.find_by_id params[:ticket_id]
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])
      # @ticket.act_terminate_job_payments.build

      # @ticket_payment_received = @ticket.ticket_estimations.inject(0){|i, k| i+k.ticket_payment_received.try(:amount).to_f}
      @ticket_payment_received = @ticket.ticket_payment_receiveds.sum(:amount).to_f

      @total_estimation_amount = @ticket.ticket_estimations.where(foc_approved: false, cust_approved: true).map { |estimation| estimation.approval_required ? (estimation.ticket_estimation_externals.sum(:approved_estimated_price)+estimation.ticket_estimation_parts.sum(:approved_estimated_price)+estimation.ticket_estimation_additionals.sum(:approved_estimated_price)) : (estimation.ticket_estimation_externals.sum(:estimated_price)+estimation.ticket_estimation_parts.sum(:estimated_price)+estimation.ticket_estimation_additionals.sum(:estimated_price)) }.compact.sum

    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/estimate_job_final/estimate_job_final"}
    end
  end

  def deliver_unit
    ContactNumber
    QAndA
    TaskAction
    TicketSparePart
    Inventory
    @ticket = Ticket.find_by_id params[:ticket_id]
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/deliver_unit"}
    end
  end

  def job_below_margin_estimate_approval
    ContactNumber
    QAndA
    TaskAction
    TicketSparePart
    Inventory
    Warranty
    Tax
    @ticket = Ticket.find_by_id params[:ticket_id]
    if @ticket
      # @estimation = @ticket.ticket_estimations.find params[:part_estimation_id]
      @product = @ticket.products.first
      Rails.cache.delete([:histories, @product.id])
      Rails.cache.delete([:join, @ticket.id])
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/job_below_margin_estimate_approval"}
    end
  end

  def low_margin_estimate_parts_approval
    Inventory
    Grn
    Organization
    Warranty
    ContactNumber
    QAndA
    TaskAction
    Inventory
    Tax
    ticket_id = params[:ticket_id]
    @ticket = Ticket.find_by_id ticket_id

    if @ticket
      @estimation = TicketEstimation.find params[:part_estimation_id]

      @grn_items = GrnItem.all.page(params[:page]).per(3)
      @product = @ticket.products.first
      Rails.cache.delete([:histories, @product.id])
      Rails.cache.delete([:join, @ticket.id])
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/low_margin_estimate_parts_approval/low_margin_estimate_parts_approval"}
    end
  end

  def terminate_job_foc_approval
    Inventory
    Warranty
    ContactNumber
    QAndA
    TaskAction
    Inventory
    ticket_id = params[:ticket_id]
    @ticket = Ticket.find_by_id ticket_id
    if @ticket

      @ticket_action = @ticket.user_ticket_actions.find_by_action_id 18

      # @ticket_terminate_job = @ticket_action.ticket_terminate_job
      # @terminate_job_payment = @ticket_action.ticket_terminate_job_payments.first

      @product = @ticket.products.first
      Rails.cache.delete([:histories, @product.id])
      Rails.cache.delete([:join, @ticket.id])
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/terminate_job_foc_approval/terminate_job_foc_approval"}
    end
  end

  def extend_warranty
    ContactNumber
    QAndA
    TaskAction
    TicketSparePart
    Inventory
    session[:ticket_id] ||= params[:ticket_id]
    @ticket = Ticket.find(params[:ticket_id] || session[:ticket_id])# if params[:ticket_id].present?
    if @ticket
      @product = @ticket.products.first
      @warranties = @product.warranties
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])

    end

    case params[:switch_to]
    when "warranty_extended"
      @warranty = Warranty.new
      @render_template = "tickets/tickets_pack/extend_warranty/warranty_form"
    when "r_warranty_extended"
      @reject_warranty_extend = ActionWarrantyExtend.new
      @render_template = "tickets/tickets_pack/extend_warranty/reject_extend_warranty"

    when "edit_serial_no"
      @render_template = "tickets/tickets_pack/order_manufacture_parts/edit_serial_no_request"
      @complete_task = true
    end
    respond_to do |format|
      format.js {render "tickets/tickets_pack/extend_warranty/extend_warranty"}
      format.html {render "tickets/tickets_pack/extend_warranty/extend_warranty"}
    end
  end

  def extend_warranty_update_reject_extend_warranty
    Ticket
    @continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])
    @ticket = Ticket.find params[:ticket_id]
    if @continue

      # Set Action (40) "Reject Warranty Extend". DB.spt_act_warranty_extend
      user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(40).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
      user_ticket_action.build_action_warranty_extend(act_warranty_extend_params)
      user_ticket_action.save

      # bpm output variables
      bpm_variables = view_context.initialize_bpm_variables

      @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

      @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

      if @bpm_response[:status].upcase == "SUCCESS"
        @flash_message = {notice: "Successfully updated"}
      else
        @flash_message = {error: "reject warranty is updated. but Bpm error"}
      end
    else
      @flash_message = {error: "Unable to update."}
    end
    redirect_to todos_url, @flash_message
  end

  def check_fsr
    ContactNumber
    QAndA
    TaskAction
    TicketSparePart
    Inventory
    Warranty
    Organization
    @ticket = Ticket.find_by_id params[:ticket_id]
    if @ticket
      @product = @ticket.products.first
      Rails.cache.delete([:histories, @product.id])
      Rails.cache.delete([:join, @ticket.id])
    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/check_fsr/check_fsr"}
    end
  end

  def update_check_fsr
    TaskAction
    @ticket.attributes = ticket_params
    job_close_approved = (params[:job_close_approved].present? and params[:job_close_approved].to_bool)

    @continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

    if @continue
      # bpm output variables
      bpm_variables = view_context.initialize_bpm_variables.merge supp_engr_user: params[:supp_engr_user]

      ticket_workfows = @ticket.ticket_workflow_processes.where process_id: params[:process_id]
      job_engineers =  @ticket.ticket_engineers.where(workflow_process_id: ticket_workfows.first.try(:id))

      job_engineers.each do |engineer|
        engineer.attributes = {job_close_approved: job_close_approved} if engineer.job_close_approval_required
        engineer.attributes = {job_closed_at: DateTime.now, status: 3} if job_close_approved and engineer.status < 3
        engineer.save
      end

      @ticket.save
      if job_close_approved #Approved (Checked)

        bpm_variables.merge! d40_ticket_approved_to_close: "Y"

        # Set Action:(56)Approve Close Ticket, and  DB.spt_act_ticket_close_approve
        user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(56).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
        user_ticket_action.build_act_ticket_close_approve(approved: true, owner_engineer_id: params[:owner_engineer_id])
        user_ticket_action.save

        # final close
        if @ticket.ticket_engineers.all?{|eng| eng.status.to_i == 3 }

          @ticket.update ticket_close_approved: job_close_approved, job_closed: job_close_approved, job_closed_at: DateTime.now

          #Calculate Total Costs and Time
          @ticket.calculate_ticket_total_cost

          @ticket.set_ticket_close(current_user.id)
        end

      else # Rejected (Not Checked)

        @ticket.update owner_engineer_id: nil

        #bpm_variables.merge! d41_re_open: "Y" if @ticket.status_id == TicketStatus.find_by_code("ROP").id or !@ticket.job_finished
        bpm_variables.merge! d41_re_open: "N"

#        Set Action:(66) Reject Close Ticket, and  DB.spt_act_ticket_close_approve
        user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(66).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
        user_ticket_action.build_act_ticket_close_approve(approved: false, reject_reason_id: params[:reject_reason_id])
        user_ticket_action.save

        job_engineers.update_all(job_close_approval_requested: false)

        @ticket.update ticket_close_approval_requested: false if @ticket.ticket_close_approval_requested
      end

      @ticket.ticket_spare_parts.each do |s|
        if params[:ticket_spare_part_ids].to_a.include? s.id.to_s
          s.update close_approved: true, close_approved_action_id: user_ticket_action.id

          if s.ticket_spare_part_manufacture.present? and !CompanyConfig.first.sup_mf_parts_return_required and !s.ticket_spare_part_manufacture.po_required
            s.update(status_action_id: SparePartStatusAction.find_by_code("CLS").id)
            s.ticket_spare_part_status_actions.create(status_id: s.status_action_id, done_by: current_user.id, done_at: DateTime.now)
          end

        else
          s.update close_approved: false, close_approved_action_id: nil
        end
      end

      @ticket.ticket_on_loan_spare_parts.each do |s|
        if params[:ticket_on_loan_spare_part_ids].to_a.include? s.id.to_s
          s.update close_approved: true, close_approved_action_id: user_ticket_action.id
        else
          s.update close_approved: false, close_approved_action_id: nil
        end
      end

      @ticket.ticket_fsrs.where(approved: true, approved_action_id: nil).update_all(approved_action_id: user_ticket_action.id)
      @ticket.ticket_fsrs.where(approved: false).update_all(approved_action_id: nil)

      @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

      if @bpm_response[:status].upcase == "SUCCESS"
        if !job_close_approved #Rejected
          job_engineers.each do |engineer|
            if engineer.job_close_approval_required
              email_to = engineer.user.email
              if email_to.present?
                view_context.send_email(email_to: email_to, ticket_id: @ticket.id, engineer_id: engineer.id, email_code: "FSR_CLOSE_APPROVAL_REJECTED")
              end
            end
          end
        end

        flash[:notice] = "Successfully updated"
      else
        flash[:error] = "invoice is updated. but Bpm error"
      end
    else
      flash[:error] = "Bpm error."
    end

    redirect_to todos_url
  end

  def customer_feedback
    ContactNumber
    QAndA
    TaskAction
    TicketSparePart
    Invoice
    Ticket
    TicketEstimation
    Warranty
    Tax
    @ticket = Ticket.find_by_id params[:ticket_id]
    if @ticket

      @product = @ticket.products.first
      Rails.cache.delete([:histories, @product.id])
      Rails.cache.delete([:join, @ticket.id])

      @ticket_payment_received = TicketPaymentReceived.new
      @ticket_payment_received.customer_feedbacks.build

    end
    respond_to do |format|
      format.html {render "tickets/tickets_pack/customer_feedback/customer_feedback"}
    end
  end

  def quality_control
    ContactNumber
    QAndA
    TaskAction
    TicketSparePart
    Inventory
    Warranty

    @ticket = Ticket.find params[:ticket_id]
    if @ticket
      @product = @ticket.products.first
      Rails.cache.delete([:histories, @product.id])
      Rails.cache.delete([:join, @ticket.id])
    end
    supp_engr_user = params[:supp_engr_user]
    @ge_questions = GeQAndA.actives.where(action_id: 5)
    @action_no = 57
    @user_ticket_action = @ticket.user_ticket_actions.build
    @act_quality_control = @user_ticket_action.build_act_quality_control

    respond_to do |format|
      format.html {render "tickets/tickets_pack/quality_control/quality_control"}
    end

  end

  def issue_store_part
    Inventory
    Warranty
    ContactNumber
    QAndA
    TaskAction
    Inventory
    InventoryProduct
    TicketSparePart
    TicketEstimation
    Grn
    Srn
    ticket_id = (params[:ticket_id] or session[:ticket_id])
    @ticket = Ticket.find_by_id ticket_id
    session[:ticket_id] = @ticket.id

    @main_part_serial = []

    request_spare_part_id = params[:request_spare_part_id]
    @onloan_request = true if params[:onloan_request] == 'Y'
    if @onloan_request
      @onloan_spare_part = @ticket.ticket_on_loan_spare_parts.find params[:request_onloan_spare_part_id]
      @spare_part = @onloan_spare_part.ticket_spare_part
    else
      @spare_part = @ticket.ticket_spare_parts.find request_spare_part_id
    end

    @onloan_or_store = @onloan_request ? @onloan_spare_part : @spare_part.ticket_spare_part_store

    @fifo_grn_serial_items = []

    if @onloan_or_store.approved_inventory_product.inventory_product_info
      # grn_item_ids = @onloan_or_store.approved_inventory_product.grn_items.search(query: "grn.store_id:#{@onloan_or_store.approved_store_id} AND inventory_not_updated:false").map{|grn_item| grn_item.id}
      grn_item_ids = GrnItem.search(query: "grn.store_id:#{@onloan_or_store.approved_store_id} AND inventory_not_updated:false AND inventory_product.id:#{@onloan_or_store.approved_inventory_product.id}").map{|grn_item| grn_item.id}

      if @onloan_or_store.approved_inventory_product.inventory_product_info.need_serial
        @fifo_grn_serial_items = if @onloan_or_store.approved_inventory_product.fifo
          GrnSerialItem.includes(:inventory_serial_item).where(grn_item_id: grn_item_ids, remaining: true).sort{|p, n| p.grn_item.grn.created_at <=> n.grn_item.grn.created_at}
        else
          GrnSerialItem.includes(:inventory_serial_item).where(grn_item_id: grn_item_ids, remaining: true).sort{|p, n| n.grn_item.grn.created_at <=> p.grn_item.grn.created_at}

        end

        @paginated_fifo_grn_serial_items = Kaminari.paginate_array(@fifo_grn_serial_items).page(params[:page]).per(10)

      elsif @onloan_or_store.approved_inventory_product.inventory_product_info.need_batch
        @grn_batches = GrnBatch.where(grn_item_id: grn_item_ids).where("remaining_quantity > 0").page(params[:page]).per(10)
      else

        # grn_items = @onloan_or_store.approved_inventory_product.grn_items.search(query: "grn.store_id:#{@onloan_or_store.approved_store_id} AND inventory_not_updated:false AND remaining_quantity:>0")
        grn_items = GrnItem.search(query: "grn.store_id:#{@onloan_or_store.approved_store_id} AND inventory_not_updated:false AND remaining_quantity:>0 AND inventory_product.id:#{@onloan_or_store.approved_inventory_product.id}")

        @grns = Kaminari.paginate_array(grn_items).page(params[:page]).per(10)
      end
    end

    if @onloan_or_store.approved_main_inventory_product.present?
      approved_grn_item_ids = @onloan_or_store.approved_main_inventory_product.grn_items.search(query: "grn.store_id:#{@onloan_or_store.approved_store_id} AND inventory_not_updated:false").map{|grn_item| grn_item.id}

      gen_serial_items = GrnSerialItem.includes(:inventory_serial_item).where(grn_item_id: approved_grn_item_ids, remaining: true)

      @main_part_serial = if @onloan_or_store.approved_main_inventory_product.fifo
        gen_serial_items.sort{|p, n| p.grn_item.grn.created_at <=> n.grn_item.grn.created_at }
      else
        gen_serial_items.sort{|p, n| n.grn_item.grn.created_at <=> p.grn_item.grn.created_at }
      end
    end

    if @ticket
      @product = @ticket.products.first
      session[:product_id] = @product.id
      Rails.cache.delete([:histories, session[:product_id]])
      Rails.cache.delete([:join, @ticket.id])
    end

    respond_to do |format|
      format.html {render "tickets/tickets_pack/issue_store_part"}
    end
  end

  def update_issue_store_parts
    Grn
    Inventory
    Srn

    grn_serial_item_id = params[:grn_serial_item_id]
    grn_batch_id = params[:grn_batch_id]
    grn_item_id = params[:grn_item_id]
    main_inventory_serial_part_id = params[:main_inventory_serial_part_id]
    product_condition_id = params[:product_condition_id]

    @onloan_request = params[:onloan_request] == "Y" ? true : false

    @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if @onloan_request
      @onloan_request_part = TicketOnLoanSparePart.find params[:request_onloan_spare_part_id]
      @terminated = (@onloan_request_part.status_action_id == SparePartStatusAction.find_by_code("CLS").id)
      @srn_item = @onloan_request_part.srn_item

    else
      @ticket_spare_part = TicketSparePart.find params[:request_spare_part_id]
      @terminated = (@ticket_spare_part.status_action_id == SparePartStatusAction.find_by_code("CLS").id)
      @srn_item = @ticket_spare_part.ticket_spare_part_store.srn_item

    end

    if @onloan_request
      if @onloan_request_part.ticket_spare_part
        @onloan_note = params[:ticket_spare_part][:ticket_on_loan_spare_parts_attributes].values.first["note"]
      else
        @onloan_note = params[:ticket][:ticket_on_loan_spare_parts_attributes].values.first["note"]
      end
    else
      @spare_part_note = params[:ticket_spare_part]["note"]
    end

    if @continue

      if @terminated or !@srn_item.present?

        if @srn_item.present?

          @srn_item.update issue_terminated: true, issue_terminated_at: DateTime.now, issue_terminated_by: current_user.id

          bpm_variables = view_context.initialize_bpm_variables
          @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          if @bpm_response[:status].upcase == "SUCCESS"

            flash[:error] = "Request allready terminated."
          else
            flash[:error] = "Request allready terminated. but Bpm error"
          end
        else
          flash[:error] = "SRN is not created."
        end

      else

        @iss_from_inventory_not_updated = false
        @issued = false
        @product_id = nil
        @part_cost_price  = nil
        @product_condition_id  = nil
        @main_product_id  = nil
        @inventory_not_updated = false
        @currency_id  = nil
        @iss_grn_item_id  = nil
        @iss_grn_batch_id  = nil
        @iss_grn_serial_item_id  = nil
        @iss_grn_serial_part_id  = nil
        @iss_main_part_grn_serial_item_id = nil

        if main_inventory_serial_part_id.present? #Issue Part Of Main Product

          @main_inventory_serial_part = InventorySerialPart.find(main_inventory_serial_part_id)
          if @main_inventory_serial_part.inv_status_id == InventorySerialItemStatus.find_by_code("AV").id


            @inventory_not_updated = true

            @product_id = @main_inventory_serial_part.inventory_product.id

            @main_product_id = @main_inventory_serial_part.inventory_serial_item.product_id


            @part_cost_price = @main_inventory_serial_part.grn_serial_parts.where(remaining: true).first.grn_item.current_unit_cost.to_d + @main_inventory_serial_part.inventory_serial_part_additional_costs.sum(:cost).to_d

            @currency_id = @main_inventory_serial_part.grn_serial_parts.where(remaining: true).first.grn_item.currency_id


            @product_condition_id  = @main_inventory_serial_part.product_condition_id

            @product_serial_no = @main_inventory_serial_part.serial_no

            @product_ct_no = @main_inventory_serial_part.ct_no


            @iss_main_part_grn_serial_item_id = @main_inventory_serial_part.inventory_serial_item.grn_serial_items.active_serial_items.first.try(:id)

            @grn_serial_part =  @main_inventory_serial_part.grn_serial_parts.where(remaining: true).first

            @iss_grn_serial_part_id =  @grn_serial_part.try(:id)

            @iss_grn_item_id  = @grn_serial_part.try(:grn_item).try(:id)

            # @iss_grn_serial_item_id  = nil
            # @iss_grn_batch_id  = nil

            @main_inventory_serial_part.update inv_status_id: InventorySerialItemStatus.find_by_code("NA").id, updated_by: current_user.id

            @main_inventory_serial_part.inventory_serial_item.update parts_not_completed: true, updated_by: current_user.id

            @grn_serial_part.update remaining: false

            @issued = true
          end

        else
          # @inventory_not_updated = false
          # @main_product_id  = nil

          if grn_serial_item_id.present? #Issue Serial Item
            @grn_serial_item = GrnSerialItem.find(grn_serial_item_id)

            @iss_from_inventory_not_updated = @grn_serial_item.grn_item.inventory_not_updated
            if @srn_item.quantity == 1 and @grn_serial_item.remaining and (@grn_serial_item.inventory_serial_item.inv_status_id == InventorySerialItemStatus.find_by_code("AV").id) and not @iss_from_inventory_not_updated

              @product_id = @grn_serial_item.inventory_serial_item.inventory_product.id
              @product_condition_id  = @grn_serial_item.inventory_serial_item.product_condition_id
              @part_cost_price = @grn_serial_item.grn_item.current_unit_cost.to_d + @grn_serial_item.inventory_serial_item.inventory_serial_items_additional_costs.sum(:cost).to_d #inventory_serial_items_additional_costs
              @product_serial_no = @grn_serial_item.inventory_serial_item.serial_no
              @product_ct_no = @grn_serial_item.inventory_serial_item.ct_no


              @currency_id  = @grn_serial_item.grn_item.currency_id

              @iss_grn_serial_item_id  = grn_serial_item_id
              @iss_grn_item_id  = @grn_serial_item.grn_item.id
              # @iss_grn_batch_id  = nil
              # @iss_grn_serial_part_id  = nil

              @grn_serial_item.inventory_serial_item.update inv_status_id: InventorySerialItemStatus.find_by_code("NA").id, updated_by: current_user.id

              @grn_serial_item.update remaining: false

              @grn_serial_item.grn_item.update remaining_quantity: (@grn_serial_item.grn_item.remaining_quantity-1)

              @grn_serial_item.inventory_serial_item.inventory.update stock_quantity: (@grn_serial_item.inventory_serial_item.inventory.stock_quantity - 1), available_quantity: (@grn_serial_item.inventory_serial_item.inventory.available_quantity - 1)
              @grn_serial_item.inventory_serial_item.inventory.update_relation_index
              @issued = true
            end

          elsif grn_batch_id.present? #Issue Batch Item
            @grn_batch = GrnBatch.find(grn_batch_id)

            @iss_from_inventory_not_updated = @grn_batch.grn_item.inventory_not_updated
            if @grn_batch.remaining_quantity >= @srn_item.quantity  and not @iss_from_inventory_not_updated

              @product_id = @grn_batch.grn_item.inventory_product.id
              @product_condition_id  = product_condition_id
              @part_cost_price  = @grn_batch.grn_item.current_unit_cost
              @currency_id  = @grn_batch.grn_item.currency_id

              # @iss_grn_serial_item_id  = nil
              @iss_grn_item_id  = @grn_batch.grn_item.id
              @iss_grn_batch_id  = @grn_batch.id
              # @iss_grn_serial_part_id  = nil

              @grn_batch.decrement! :remaining_quantity, @srn_item.quantity

              @grn_batch.grn_item.decrement! :remaining_quantity, @srn_item.quantity

              @inventory = Inventory.where(store_id: @grn_batch.grn_item.grn.store_id, product_id: @grn_batch.grn_item.product_id).order("created_at asc").first

              @inventory.update stock_quantity: (@inventory.stock_quantity - @srn_item.quantity), available_quantity: (@inventory.available_quantity - @srn_item.quantity)
              @inventory.update_relation_index

              @issued = true
            end

          elsif grn_item_id.present? #Issue Just a GRN Item
            @grn_item = GrnItem.find(grn_item_id)

            @iss_from_inventory_not_updated = @grn_item.inventory_not_updated
            if @grn_item.remaining_quantity >= @srn_item.quantity  and !@iss_from_inventory_not_updated

              @product_id = @grn_item.inventory_product.id
              @product_condition_id  = product_condition_id
              @part_cost_price  = @grn_item.current_unit_cost
              @currency_id  = @grn_item.currency_id

              # @iss_grn_serial_item_id  = nil
              @iss_grn_item_id  = @grn_item.id
              # @iss_grn_batch_id  = nil
              # @iss_grn_serial_part_id  = nil

              @grn_item.decrement! :remaining_quantity, @srn_item.quantity

              @inventory = Inventory.where(store_id: @grn_item.grn.store_id, product_id: @grn_item.product_id).order("created_at asc").first

              @inventory.update stock_quantity: (@inventory.stock_quantity - @srn_item.quantity), available_quantity: (@inventory.available_quantity - @srn_item.quantity)
              @inventory.update_relation_index

              @issued = true
            end

          end
        end

        if @issued
          gin = @srn_item.srn.gins.create(created_by: current_user.id, created_at: DateTime.now, gin_no: CompanyConfig.first.increase_inv_last_gin_no, store_id: @srn_item.srn.store.id, remarks: (@spare_part_note || @onloan_note) )#inv_gin

          gin_item = gin.gin_items.create(
          product_id: @product_id,
          issued_quantity: @srn_item.quantity,
          srn_item_id: @srn_item.id,
          product_condition_id: @product_condition_id,
          currency_id: @currency_id,
          main_product_id: @main_product_id,
          returned_quantity: 0,
          returnable: @onloan_request,
          return_completed: false,
          spare_part: true,
          inventory_not_updated: @inventory_not_updated
          )#inv_gin_item

          @srn_item.srn.update closed: true
          @srn_item.update closed: true

          gin_source = gin_item.gin_sources.create(grn_item_id: @iss_grn_item_id, grn_batch_id: @iss_grn_batch_id, grn_serial_item_id: @iss_grn_serial_item_id, grn_serial_part_id: @iss_grn_serial_part_id, main_part_grn_serial_item_id: @iss_main_part_grn_serial_item_id, issued_quantity: @srn_item.quantity, unit_cost: @part_cost_price, returned_quantity: 0)#inv_gin_source

          if @onloan_request
            if @onloan_request_part.ticket_spare_part
              @onloan_request_part.ticket_spare_part.update ticket_spare_part_params(@onloan_request_part.ticket_spare_part)
            else
              @onloan_request_part.ticket.update ticket_params
            end

            @onloan_request_part.update inv_gin_id: gin.id, inv_gin_item_id: gin_item.id, cost_price: @part_cost_price, issued: true , issued_at: DateTime.now, issued_by: current_user.id,received_part_serial_no: @product_serial_no, received_part_ct_no: @product_ct_no

            #Issue store On-Loan Part
            action_id = TaskAction.find_by_action_no(50).id

            @onloan_request_part.update status_action_id: SparePartStatusAction.find_by_code("ISS").id
            @onloan_request_part.ticket_on_loan_spare_part_status_actions.create(status_id: @onloan_request_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

            user_ticket_action = @onloan_request_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: @onloan_request_part.ticket.re_open_count, action_id: action_id)
            user_ticket_action.build_request_on_loan_spare_part(ticket_on_loan_spare_part_id: @onloan_request_part.id)
            user_ticket_action.save

            bpm_variables = view_context.initialize_bpm_variables

            @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

            if @bpm_response[:status].upcase == "SUCCESS"

              email_template = EmailTemplate.find_by_code("PART_ISSUED")

              email_to = @onloan_request_part.engineer.user.email
              if email_template.try(:active)
                view_context.send_email(email_to: email_to, ticket_id: @onloan_request_part.ticket.try(:id), engineer_id: @onloan_request_part.engineer_id, spare_part_id: @onloan_request_part.id, onloan: true, email_code: "PART_ISSUED") if email_to.present?

              end

              flash[:notice] = "Successfully updated."
            else
              flash[:error] = "ticket is updated. but Bpm error"
            end

          else #Store Request (not On-Loan)

            @ticket_spare_part.received_part_serial_no = @product_serial_no if @product_serial_no.present?
            @ticket_spare_part.received_part_ct_no = @product_ct_no if @product_ct_no.present?

            @ticket_spare_part.update ticket_spare_part_params(@ticket_spare_part)


            @ticket_spare_part.ticket_spare_part_store.update inv_gin_id: gin.id, inv_gin_item_id: gin_item.id, cost_price: @part_cost_price, issued: true, issued_at: DateTime.now, issued_by: current_user.id


            #Issue store Spare Part
            action_id = TaskAction.find_by_action_no(48).id

            @ticket_spare_part.update status_action_id: SparePartStatusAction.find_by_code("ISS").id
            @ticket_spare_part.ticket_spare_part_status_actions.create(status_id: @ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

            user_ticket_action = @ticket_spare_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket_spare_part.ticket.re_open_count, action_id: action_id)
            user_ticket_action.build_request_spare_part(ticket_spare_part_id: @ticket_spare_part.id)
            user_ticket_action.save

            bpm_variables = view_context.initialize_bpm_variables

            @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

            if @bpm_response[:status].upcase == "SUCCESS"

              email_template = EmailTemplate.find_by_code("PART_ISSUED")

              email_to = @ticket_spare_part.engineer.user.email
              if email_template.try(:active)
                view_context.send_email(email_to: email_to, ticket_id: @ticket_spare_part.ticket_id, engineer_id: @ticket_spare_part.engineer_id, spare_part_id: @ticket_spare_part.id, email_code: "PART_ISSUED") if email_to.present?

              end

              flash[:notice] = "Successfully updated."
            else
              flash[:error] = "ticket is updated. but Bpm error"
            end
          end

        else
          if @iss_from_inventory_not_updated
            flash[:notice] = "Trying to issue from inventory not updated GRN"
          else
            flash[:notice] = "Stock Remaining Quantity is zero."
          end
        end
      end
    else
      flash[:notice] = "ticket is not updated. Bpm error"
    end
    redirect_to todos_url
  end

  def after_printer
    TaskAction

    case params[:ticket_action]
    when "print_ticket"
      @ticket = Ticket.find(params[:print_object_id])
      @ticket.update_attribute(:ticket_print_count, (@ticket.ticket_print_count+1))
      @ticket.user_ticket_actions.create(action_id: TaskAction.find_by_action_no(68).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
    when "print_fsr"
      @ticket_fsr = TicketFsr.find(params[:print_object_id])
      @ticket_fsr.update_attribute(:print_count, (@ticket_fsr.print_count+1))

      user_ticket_action = @ticket_fsr.ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(70).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket_fsr.ticket.re_open_count)
      user_ticket_action.build_act_fsr(print_fsr: true, fsr_id: @ticket_fsr.id)

      user_ticket_action.save

    when "print_receipt"
      Ticket
      @receipt = TicketPaymentReceived.find(params[:print_object_id])
      @ticket = @receipt.ticket
      @receipt.update_attribute(:receipt_print_count, (@receipt.receipt_print_count+1))
      user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(77).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
      user_ticket_action.build_act_payment_received(ticket_payment_received_id: @receipt.id, invoice_completed: false)
      user_ticket_action.save
 
    when "print_ticket_invoice"
      Invoice
      @invoice = TicketInvoice.find(params[:print_object_id])
      @ticket = @invoice.ticket
      @invoice.update_attribute(:print_count, (@invoice.print_count+1))
      user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(71).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
      user_ticket_action.build_act_print_invoice(invoice_id: @invoice.id)
      user_ticket_action.save

    when "print_ticket_delivery_note" #print_ticket_complete
      @ticket = Ticket.find(params[:print_object_id])
      @ticket.update_attribute(:ticket_complete_print_count, (@ticket.ticket_complete_print_count+1))
      @ticket.user_ticket_actions.create(action_id: TaskAction.find_by_action_no(69).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)

    when "print_customer_quotation"
      Invoice
      @quotation = CustomerQuotation.find(params[:print_object_id])
      @ticket = @quotation.ticket
      @quotation.update_attribute(:print_count, (@quotation.print_count+1))
      user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(82).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
      user_ticket_action.build_act_quotation(customer_quotation_id: @quotation.id)
      user_ticket_action.save

    when "print_bundle"
      TicketSparePart
      @bundle = ReturnPartsBundle.find(params[:print_object_id])
      # @bundle.update_attribute(:print_count, (@bundle.print_count+1))
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
    when "receipt"
      Ticket
      TicketPaymentReceived.find_by_id params[:print_object_id]
    when "ticket_complete"
      Ticket.find(params[:print_object_id])
    when "invoice"
      Invoice
      TicketInvoice.find(params[:print_object_id])
    when "quotation"
      Invoice
      CustomerQuotation.find(params[:print_object_id])
    when "bundle_hp"
      TicketSparePart
      ReturnPartsBundle.find(params[:print_object_id])
    when "ticket_sticker"
      Invoice
      CustomerQuotation.find(params[:print_object_id])

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
    ticket_engineer = TicketEngineer.find(params[:engineer_id]) if params[:engineer_id].present?
 
    if ticket_engineer.present?
      @workflow_processes = ticket_engineer.ticket_workflow_processes.to_a
    else
      @workflow_processes = params[:workflow_process_id].present? ? [HashToObject.new({process_id: params[:workflow_process_id]})] : @ticket.ticket_workflow_processes.to_a
    end
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
    Warranty
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
      # @ticket_terminate_job_payment = @user_ticket_action.act_terminate_job_payments.build
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
      @recieve_unit = @ticket.ticket_deliver_units.where(received: false, collected: true).first
    when "deliver_unit"
      TicketEstimation
      @ticket_deliver_unit = @ticket.ticket_deliver_units.build

      @report_bys = if @ticket.ticket_estimation_externals.present?

        # @report_bys = @ticket.ticket_estimation_externals.select{|ts| ((ts.ticket_estimation.status_id == EstimationStatus.find_by_code("EST").id) or (ts.ticket_estimation.status_id == EstimationStatus.find_by_code("CLS").id) or (ts.ticket_estimation.status_id == EstimationStatus.find_by_code("APP").id)) and ((ts.ticket_estimation.cust_approved) or ( !ts.ticket_estimation.cust_approval_required)) }.map { |ts| [ts.organization.name, ts.organization.id] }
        @ticket.ticket_estimation_externals.select{ |ts| ["EST", "CLS", "APP"].include?(ts.ticket_estimation.estimation_status.code) and (ts.ticket_estimation.cust_approved or !ts.ticket_estimation.cust_approval_required ) }.map { |ts| [ts.organization.name, ts.organization.id] }
      else
        Organization.organization_suppliers.map { |o| [o.name, o.id] }
      end

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
      # @ticket_all =  = Ticket.all.where.not(session[:ticket_id])
      # @ticket_all = Ticket.where("id != ?", session[:ticket_id])
    when "request_on_loan_spare_part"
      session[:store_id] = nil
      session[:inv_product_id] = nil
      session[:mst_store_id] = nil
      session[:mst_inv_product_id] = nil

      @ticket_on_loan_spare_part = @ticket.ticket_on_loan_spare_parts.build
    end
  end

  def call_alert_template

    Inventory
    Warranty
    ContactNumber
    QAndA
    TaskAction
    Inventory

    ticket_id = (params[:ticket_id] or session[:ticket_id])
    @ticket = Ticket.find_by_id ticket_id
    @call_template = params[:call_template]
    if @ticket
      @product = @ticket.products.first
      @estimation = @ticket.ticket_estimations.first
      @spare_part = @ticket.ticket_spare_parts.first
    end
  end

  def hold_unhold
    @ticket = Ticket.find session[:ticket_id]
    @user_ticket_action = @ticket.user_ticket_actions.build
    @call_template = params[:call_template]
    case @call_template
    when "hold"
      @act_hold = @user_ticket_action.build_act_hold
      @call_template = 'tickets/tickets_pack/resolution/'+@call_template
    when "un_hold"
      @call_template = 'tickets/tickets_pack/resolution/'+@call_template
    end
  end

  def call_mf_order_template
    TaskAction
    TicketSparePart
    Warranty
    @call_template = params[:call_template]
    @ticket = Ticket.find session[:ticket_id]
    @product = @ticket.products.first
    @user_ticket_action = @ticket.user_ticket_actions.build
    @spare_part = TicketSparePart.find session[:request_spare_part_id]

    case @call_template
    when "hold"
      @act_hold = @user_ticket_action.build_act_hold
      @call_template = 'tickets/tickets_pack/resolution/'+@call_template
    when "un_hold"
      @call_template = 'tickets/tickets_pack/resolution/'+@call_template
    when "warranty_extend"
      @warranty_extend = @user_ticket_action.build_action_warranty_extend
      @call_template = 'tickets/tickets_pack/order_manufacture_parts/'+@call_template
    when "request_from_store"
      @spare_part.build_ticket_spare_part_store
      @call_template = 'tickets/tickets_pack/order_manufacture_parts/'+@call_template
    else
      @call_template = 'tickets/tickets_pack/order_manufacture_parts/'+@call_template
    end
  end

  def update_order_mfp_part_order
    Ticket
    spt_ticket_spare_part = TicketSparePart.find params[:request_spare_part_id]
    @ticket = spt_ticket_spare_part.ticket
    spt_ticket_spare_part.attributes = ticket_spare_part_params(spt_ticket_spare_part)

    update_without_order = (params[:update_without_order].present? and params[:update_without_order].to_bool)

    if update_without_order

      @continue = true #to call update_bpm_header

      spt_ticket_spare_part.save
      spt_ticket_spare_part.ticket_spare_part_manufacture.update order_pending: 1 
      @flash_message = {notice: "Successfully updated without order"}

    else

      spt_ticket_spare_part.ticket_spare_part_manufacture.update order_pending: nil 

      @continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

      if @continue and (spt_ticket_spare_part.status_action_id != SparePartStatusAction.find_by_code("CLS").id) and spt_ticket_spare_part.save

        spt_ticket_spare_part.update_attributes status_action_id: SparePartStatusAction.find_by_code("ORD").id

        spt_ticket_spare_part.ticket_spare_part_manufacture.update po_required: CompanyConfig.first.sup_mf_parts_po_required

        spt_ticket_spare_part.ticket_spare_part_manufacture.update collect_pending_manufacture: true if spt_ticket_spare_part.ticket_spare_part_manufacture

        spt_ticket_spare_part.ticket_spare_part_status_actions.create(status_id: spt_ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

        # Set Action (31) Order Spare Part from Sup, DB.spt_act_request_spare_part.
        user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(31).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
        user_ticket_action.build_request_spare_part(ticket_spare_part_id: spt_ticket_spare_part.id)
        user_ticket_action.save


        # bpm output variables
        d30_parts_collection_pending = TicketSparePart.any?{|sp| sp.id != spt_ticket_spare_part.id and sp.ticket_spare_part_manufacture.try(:collect_pending_manufacture)} ? "Y" : "N"

        if !CompanyConfig.first.sup_mf_parts_collect_required
          d30_parts_collection_pending = "Y"

          #Collect Part
          spt_ticket_spare_part.ticket_spare_part_manufacture.update collect_pending_manufacture: false, collected_manufacture: true

          spt_ticket_spare_part.update(status_action_id: SparePartStatusAction.find_by_code("CLT").id)
          spt_ticket_spare_part.ticket_spare_part_status_actions.create(status_id: spt_ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

          #Recieve Part
          #spt_ticket_spare_part.ticket_spare_part_manufacture.update_attributes recieved_manufacture: true

          #spt_ticket_spare_part.update(status_action_id: SparePartStatusAction.find_by_code("RCS").id)
          #spt_ticket_spare_part.ticket_spare_part_status_actions.create(status_id: spt_ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)
        end

        bpm_variables = view_context.initialize_bpm_variables.merge(d30_parts_collection_pending: d30_parts_collection_pending)

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

        @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if @bpm_response[:status].upcase == "SUCCESS"
          @flash_message = {notice: "Successfully updated"}
        else
          @flash_message = {alert: "ticket is updated. but Bpm error"}
        end
      else
        @flash_message = {alert: "Unable to update. Bpm error"}
      end
    end
    redirect_to todos_url, @flash_message

  end

  def update_order_mfp_wrrnty_extnd_rqst
    Ticket
    spt_ticket_spare_part = TicketSparePart.find params[:request_spare_part_id]
    @ticket = spt_ticket_spare_part.ticket

    @continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

    if @continue and (spt_ticket_spare_part.status_action_id != SparePartStatusAction.find_by_code("CLS").id)

      # Set Action (32) Request To Warranty Extend, DB.spt_act_warranty_extend.
      user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(32).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
      user_ticket_action.build_action_warranty_extend
      user_ticket_action.save


      # bpm output variables
      bpm_variables = view_context.initialize_bpm_variables.merge(d26_serial_no_change_warranty_extend_requested: "Y", d27_warranty_extend_requested: "Y")

      @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

      @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

      if @bpm_response[:status].upcase == "SUCCESS"
        @flash_message = {notice: "Successfully updated"}
      else
        @flash_message = {error: "ticket is updated. but Bpm error"}
      end
    else
      @flash_message = {error: "Unable to update"}
    end

    redirect_to todos_url, @flash_message

  end

  def update_order_mfp_return_manufacture_part #sRequest From Store
    Ticket
    TicketEstimation
    spt_ticket_spare_part = TicketSparePart.find params[:request_spare_part_id]
    @ticket = spt_ticket_spare_part.ticket
    d29_part_estimate_required_2= ""

    # bpm output variables
    ticket_id = @ticket.id
    request_spare_part_id = spt_ticket_spare_part.id
    supp_engr_user = params[:supp_engr_user]
    priority = @ticket.priority
    requested_quantity = params[:requested_quantity]

    # part_estimation_id = @ticket_estimation.try(:id)

    request_onloan_spare_part_id = "-"
    onloan_request = "N"

    @continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

    if @continue and (spt_ticket_spare_part.status_action_id != SparePartStatusAction.find_by_code("CLS").id) and spt_ticket_spare_part.update(ticket_spare_part_params(spt_ticket_spare_part))

      ticket_estimation_part = TicketEstimationPart.new
      need_estimation = CompanyConfig.first.sup_st_nc_estimayion_required
      if spt_ticket_spare_part.cus_chargeable_part
        need_estimation = true
        d44_store_part_need_approval = CompanyConfig.first.sup_st_parts_ch_need_approval ? "Y" : "N"
      else
        d44_store_part_need_approval = CompanyConfig.first.sup_st_parts_nc_need_approval ? "Y" : "N"
      end

      d29_part_estimate_required_2  = "Y"

      if need_estimation

        #create record spt_ticket_estimation
        @ticket_estimation = @ticket.ticket_estimations.create(requested_at: DateTime.now, requested_by: current_user.id, status_id: SparePartStatusAction.find_by_code("RQT").id, currency_id: @ticket.base_currency_id, request_type: "PT")

        #create record spt_ticket_estimation_part
        ticket_estimation_part = @ticket_estimation.ticket_estimation_parts.create(ticket_id: @ticket.id, ticket_spare_part_id: spt_ticket_spare_part.id)

        @bpm_response1 = view_context.send_request_process_data start_process: true, process_name: "SPPT_PART_ESTIMATE", query: {ticket_id: ticket_id, part_estimation_id: @ticket_estimation.try(:id), supp_engr_user: supp_engr_user, priority: priority}
      else
        spt_ticket_spare_part.update_attributes status_action_id: SparePartStatusAction.find_by_code("STR").id
        spt_ticket_spare_part.ticket_spare_part_status_actions.create(status_id: spt_ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

        @bpm_response1 = view_context.send_request_process_data start_process: true, process_name: "SPPT_STORE_PART_REQUEST", query: {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, request_onloan_spare_part_id: request_onloan_spare_part_id, onloan_request: onloan_request, supp_engr_user: supp_engr_user, priority: priority}
      end

      #update record spt_ticket_spare_part
      spt_ticket_spare_part.update_attributes estimation_required: need_estimation, requiest_approval_required: (d44_store_part_need_approval == "Y" ), requrest_approved: false, request_appoved_at: null, request_approved_by: null

      #create record spt_ticket_spare_part_store
      store_requested = (!need_estimation and d44_store_part_need_approval == "N" )
      spt_ticket_spare_part.ticket_spare_part_store.update(store_id: params[:store_id], inv_product_id: params[:inv_product_id], mst_inv_product_id: params[:mst_inv_product_id], store_requested: store_requested, store_requested_at: ( store_requested ? DateTime.now : nil), store_requested_by: ( store_requested ? current_user.id : nil), requested_quantity: requested_quantity)

      #delete record spt_ticket_spare_part_manufacture
      spt_ticket_spare_part.ticket_spare_part_manufacture.delete


      # Set Action (15) Request Spare Part from Store, DB.spt_act_request_spare_part.
      user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(15).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
      user_ticket_action.build_request_spare_part(ticket_spare_part_id: spt_ticket_spare_part.id)
      user_ticket_action.save

      # bpm output variables
      bpm_variables = view_context.initialize_bpm_variables.merge(d28_request_store_part_2: "Y", d29_part_estimate_required_2: d29_part_estimate_required_2)

      @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

      @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

      if @bpm_response1[:status].try(:upcase) == "SUCCESS"
        @ticket.ticket_workflow_processes.create(process_id: @bpm_response1[:process_id], process_name: @bpm_response1[:process_name], engineer_id: spt_ticket_spare_part.engineer_id, spare_part_id: request_spare_part_id)
        view_context.ticket_bpm_headers @bpm_response1[:process_id], @ticket.id, request_spare_part_id
      else
        @bpm_process_error = true
      end

      if @bpm_response[:status].upcase == "SUCCESS"
        @flash_message = {notice: "Successfully updated."}
      else
        @flash_message = {notice: "ticket is updated. but Bpm error"}
      end

      @flash_message = {error: "#{@flash_message} Unable to start new process."} if @bpm_process_error

    else
      @flash_message = {error: "Unable to update. Bpm error"}
    end

    redirect_to todos_url, @flash_message

  end

  def update_order_mfp_termnt_prt_order

    Ticket
    spt_ticket_spare_part = TicketSparePart.find params[:request_spare_part_id]
    @ticket = spt_ticket_spare_part.ticket

    @continue = view_context.bpm_check(params[:task_id], params[:process_id], params[:owner])

    if @continue

      if (spt_ticket_spare_part.status_action_id != SparePartStatusAction.find_by_code("CLS").id) and spt_ticket_spare_part.update(ticket_spare_part_params(spt_ticket_spare_part))

        spt_ticket_spare_part.update_attributes status_action_id: SparePartStatusAction.find_by_code("CLS").id

        spt_ticket_spare_part.ticket_spare_part_status_actions.create(status_id: spt_ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

        # Set Action (34) Terminate Spare Part Order, DB.spt_act_request_spare_part.
        user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(34).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count)
        user_ticket_action.build_request_spare_part(ticket_spare_part_id: spt_ticket_spare_part.id, part_terminate_reason_id: spt_ticket_spare_part.part_terminated_reason_id)
        user_ticket_action.save

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

        if (spt_ticket_spare_part.ticket_spare_part_manufacture)
          spt_ticket_spare_part.ticket_spare_part_manufacture.update po_required: false
        end

      end

      # bpm output variables
      bpm_variables = view_context.initialize_bpm_variables.merge(d25_terminate_order_part: "Y")
      @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

      if @bpm_response[:status].upcase == "SUCCESS"

        email_template = EmailTemplate.find_by_code("PART_TERMINATED")

        email_to = spt_ticket_spare_part.engineer.user.email
        if email_template.try(:active)
          view_context.send_email(email_to: email_to, ticket_id: @ticket.id, engineer_id: spt_ticket_spare_part.engineer.id, spare_part_id: spt_ticket_spare_part.id, email_code: "PART_TERMINATED") if email_to.present?
        end

        @flash_message = {notice: "Successfully updated"}
      else
        @flash_message = {error: "ticket is updated. but Bpm error"}
      end
    else
      @flash_message = {error: "ticket is not updated. Bpm error"}
    end
    redirect_to todos_url, @flash_message

  end

  def update_start_action

    TaskAction
    @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]
    engineer_id = params[:engineer_id]

    if @continue
      if !@ticket.job_started_at.present?

        if @ticket.update(ticket_params)
          @ticket.update job_started_at: DateTime.now
          @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(5).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count, action_engineer_id: engineer_id)

          @ticket.ticket_status_resolve = TicketStatusResolve.find_by_code("NAP")
          @ticket.ticket_status = TicketStatus.find_by_code("RSL")

          @ticket.save

          @ticket_engineer = TicketEngineer.find params[:engineer_id]
          @ticket_engineer.update job_started_at: DateTime.now if !@ticket_engineer.job_started_at.present?

          # bpm output variables

          bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id)

          @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

          if @bpm_response[:status].upcase == "SUCCESS"
            @flash_message = "Successfully updated."
          else
            @flash_message = "ticket is updated. but Bpm error"
          end

          redirect_to @ticket, notice: @flash_message
        else
          redirect_to @ticket, error: "start action failed to updated."
        end
      else
        redirect_to todos_url, error: "ticket is not updated. Start Action already done."
      end
    else
      redirect_to todos_url, error: "ticket is not updated. BPM Error."
    end
  end

  def update_change_ticket_cus_warranty
    Warranty
    TaskAction
    warranty_constraint = true
    warranty_id = ticket_params[:warranty_type_id].to_i
    engineer_id = params[:engineer_id]

    if [1, 2].include?(warranty_id)
      warranty_constraint = @ticket.products.first.warranties.select{|w| w.warranty_type_id == warranty_id and (w.start_at.to_date..w.end_at.to_date).include?(Date.today)}.present?
    end

    if warranty_constraint
      if @ticket.update ticket_params
        user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(72).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count, action_engineer_id: engineer_id)
        user_ticket_action.build_action_warranty_repair_type(ticket_warranty_type_id: @ticket.warranty_type_id, cus_chargeable: @ticket.cus_chargeable)

        @ticket.save

        @ticket_engineer = TicketEngineer.find params[:engineer_id]
        @ticket_engineer.update job_started_at: DateTime.now if !@ticket_engineer.job_started_at.present?

        redirect_to todos_url, notice: "Ticket Warranty Type and Customer Chargeable Updated."
      else
        redirect_to todos_url, notice: "Ticket Warranty Type and Customer Chargeable faild to Updated."
      end
    else
      redirect_to todos_url, alert: "Selected warranty is not presently applicable to ticket."
    end

  end

  def update_change_ticket_repair_type
    engineer_id = params[:engineer_id]
    if @ticket.update ticket_params
      user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(73).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count, action_engineer_id: engineer_id)
      user_ticket_action.build_action_warranty_repair_type(ticket_repair_type_id: @ticket.repair_type_id)

      redirect_to ticket_url(@ticket), notice: "ticket repair type is updated." if @ticket.save
    else
      redirect_to ticket_url(@ticket), notice: "ticket repair type is faild to updated."
    end
  end

  def update_re_assign
    @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if @continue
      if @ticket.update ticket_params
        @ticket_engineer = TicketEngineer.find params[:engineer_id]
        @ticket_engineer.update status: 3, re_assignment_requested: true, job_completed_at: DateTime.now, job_closed_at: DateTime.now
        @ticket_engineer.update job_started_at: DateTime.now if !@ticket_engineer.job_started_at.present?

        # bpm output variables

        bpm_variables = view_context.initialize_bpm_variables.merge(d4_job_complete: "Y", d5_re_assigned: "Y")

        @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if @bpm_response[:status].upcase == "SUCCESS"
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
 
    if !@ticket.status_hold and @ticket.update ticket_params

      act_hold = @ticket.user_ticket_actions.last.act_hold

      @ticket.hold_reason_id = act_hold.reason_id
      @ticket.last_hold_action_id = act_hold.user_ticket_action.id

      @ticket.save
      act_hold.update_attribute(:sla_pause, act_hold.reason.sla_pause)
      if params[:engineer_id].present?
        @ticket_engineer = TicketEngineer.find params[:engineer_id]
        @ticket_engineer.update job_started_at: DateTime.now if !@ticket_engineer.job_started_at.present?
      end

      # view_context.ticket_bpm_headers process_id, ticket_id, ""
      # Rails.cache.delete([:workflow_header, process_id])

      WebsocketRails[:posts].trigger 'new', {task_name: "Hold for ticket", task_id: @ticket.id, task_verb: "updated.", by: current_user.email, at: Time.now.strftime('%d/%m/%Y at %H:%M:%S')}
      redirect_to @ticket, notice: "Ticket is successfully updated."

    else
      redirect_to @ticket, alert: "Ticket is failed to update."
    end
  end

  def update_un_hold

    if @ticket.status_hold and @ticket.update ticket_params

      user_ticket_action = @ticket.user_ticket_actions.find_by_id(@ticket.last_hold_action_id)

      user_ticket_action.act_hold.update(un_hold_action_id: @ticket.user_ticket_actions.last.id)
      if params[:engineer_id].present?
        @ticket_engineer = TicketEngineer.find params[:engineer_id]
        @ticket_engineer.update job_started_at: DateTime.now if !@ticket_engineer.job_started_at.present?
      end
      # view_context.ticket_bpm_headers process_id, ticket_id, ""
      # Rails.cache.delete([:workflow_header, process_id])

      WebsocketRails[:posts].trigger 'new', {task_name: "Un hold for ticket", task_id: @ticket.id, task_verb: "updated.", by: current_user.email, at: Time.now.strftime('%d/%m/%Y at %H:%M:%S')}

      redirect_to @ticket, notice: "Ticket is successfully updated."
    else
      redirect_to @ticket, alert: "Ticket is failed to update."
    end
  end

  def update_create_fsr
    TicketSparePart
    engineer_id = params[:engineer_id]

    @ticket_engineer = TicketEngineer.find params[:engineer_id]
    @ticket_engineer.update job_started_at: DateTime.now if !@ticket_engineer.job_started_at.present?

    @ticket.attributes = ticket_params
    user_ticket_action = @ticket.user_ticket_actions.last
    # @ticket.user_ticket_actions.reload
    ticket_fsr = @ticket.ticket_fsrs.last
    ticket_fsr.ticket_fsr_no =  CompanyConfig.first.increase_sup_last_fsr_no

    @ticket_engineer.ticket_support_engineers.each do |sup_eng|
      ticket_fsr.ticket_fsr_support_engineers.build engineer_support_id: sup_eng.id
    end

    ticket_fsr.save
    last_ticket_fsr = @ticket.ticket_fsrs.last
    act_fsr = user_ticket_action.act_fsr
    act_fsr.fsr_id = ticket_fsr.id

    user_ticket_action.save
    print_fsr = false

    if act_fsr and act_fsr.print_fsr
      user_ticket_action1 = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(70).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count, action_engineer_id: engineer_id)
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
    engineer_id = session[:engineer_id]
    t_params = ticket_fsr_params
    @ticket_fsr = @ticket.ticket_fsrs.find_by_id params[:ticket_fsr_id]
    t_params["resolution"] = t_params["resolution"].present? ? "#{t_params['resolution']} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@ticket_fsr.resolution}" : @ticket_fsr.resolution

    @ticket_engineer = TicketEngineer.find engineer_id
    @ticket_engineer.update job_started_at: DateTime.now if !@ticket_engineer.job_started_at.present?

    if @ticket_fsr.update t_params
      user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(12).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count, action_engineer_id: engineer_id)
      user_ticket_action.build_act_fsr(print_fsr: false, fsr_id: @ticket_fsr.id)

      user_ticket_action.save

      redirect_to @ticket, notice: "Successfully updated."
    else
      redirect_to @ticket, alert: "Unable to update. Please try again with fields validation."
    end
  end

  def update_terminate_job
    TaskAction
    @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]
    request_to_close = params[:request_to_close].present?

    if @continue
      if @ticket.update ticket_params

        @ticket.job_finished = true
        @ticket.job_finished_at = DateTime.now
        @ticket.cus_payment_required = true
        @ticket.ticket_terminated = true
        @ticket.ticket_close_approval_required = (@ticket.ticket_spare_parts.any? or @ticket.ticket_fsrs.any? or @ticket.ticket_on_loan_spare_parts.any?)

        if not @ticket.ticket_close_approval_required
          @ticket.ticket_close_approval_requested = true
        else
          @ticket.ticket_close_approval_requested = request_to_close
        end

        @ticket.ticket_status_resolve = TicketStatusResolve.find_by_code("TER")
        if @ticket.ticket_type.code == "IH"
          @ticket.ticket_status = TicketStatus.find_by_code("QCT")

        elsif (@ticket.cus_chargeable or @ticket.cus_payment_required)
          @ticket.ticket_status = TicketStatus.find_by_code("PMT")

        else
          @ticket.ticket_status = TicketStatus.find_by_code("CFB")

        end

        @ticket.save

        @ticket_engineer = TicketEngineer.find params[:engineer_id]
        @ticket_engineer.update job_started_at: DateTime.now if !@ticket_engineer.job_started_at.present?
        @ticket_engineer.update status: 3, job_terminated: true, job_completed_at: DateTime.now, job_closed_at: DateTime.now

        bpm_variables = view_context.initialize_bpm_variables.merge(d4_job_complete: "Y", d8_job_finished: "Y", d11_terminate_job:  "Y", d9_qc_required:(@ticket.ticket_type.code == "IH" ? "Y" : "N"), d10_job_estimate_required_final: ((@ticket.cus_chargeable or @ticket.cus_payment_required) ? "Y" : "N"), d12_need_to_invoice: ((@ticket.cus_chargeable or @ticket.cus_payment_required) ? "Y" : "N"), d6_close_approval_required: ((@ticket.ticket_fsrs.any? or @ticket.ticket_spare_parts.any?) ? "Y" : "N"), d7_close_approval_requested: (@ticket.ticket_close_approval_requested ? "Y" : "N"))

        @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if @bpm_response[:status].upcase == "SUCCESS"
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
    @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]
    engineer_id = params[:engineer_id]

    if @continue
      if @ticket.update ticket_params

        @ticket_engineer = TicketEngineer.find params[:engineer_id]
        @ticket_engineer.update job_started_at: DateTime.now if !@ticket_engineer.job_started_at.present?

        close_approval_requested = params[:job_close_approval_requested] # getting from the form

        if close_approval_requested
          @ticket.ticket_close_approval_required = (@ticket.ticket_fsrs.any? or @ticket.ticket_spare_parts.any? or @ticket.ticket_on_loan_spare_parts.any?)
          @ticket.ticket_close_approval_requested = true
          @ticket.ticket_close_approved = true

          if @ticket.ticket_close_approval_required
            @ticket.ticket_engineers.each do |eng|
              if eng.job_close_approval_required
                @ticket.ticket_close_approval_requested = false if not eng.job_close_approval_requested
                @ticket.ticket_close_approved = false if not eng.job_close_approved
              end
            end
          end
          @ticket.save
        end

        # bpm output variables

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id, d7_close_approval_requested: (close_approval_requested ? "Y" : "N") )

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

        @ticket.user_ticket_actions.create(action_id: TaskAction.find_by_action_no(55).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count, action_engineer_id: engineer_id) if close_approval_requested

        @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if @bpm_response[:status].upcase == "SUCCESS"
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
    @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]
    engineer_id = params[:engineer_id]

    if @continue
      if @ticket.update ticket_params
        close_approval_requested = (params[:job_close_approval_requested].present? and params[:job_close_approval_requested].to_bool) # getting from the form(params[:job_close_approval_requested].present? and params[:job_close_approval_requested].to_bool)

        @ticket_engineer = TicketEngineer.find engineer_id
        @ticket_engineer.update job_started_at: DateTime.now if !@ticket_engineer.job_started_at.present?

        ticket_workfows = @ticket.ticket_workflow_processes.where process_id: params[:process_id]
        ticket_engineers = @ticket.ticket_engineers.where(workflow_process_id: ticket_workfows.first.try(:id))

        engineer_close_approval_required = (@ticket.ticket_fsrs.any?{|fsr| ticket_engineers.ids.include?(fsr.engineer_id) } or @ticket.ticket_spare_parts.any?{|part| ticket_engineers.ids.include?(part.engineer_id) } or @ticket.ticket_on_loan_spare_parts.any?{|onloanpart| ticket_engineers.ids.include?(onloanpart.engineer_id) })

        close_approval_requested = false if not engineer_close_approval_required

        @ticket_engineer.update status: (engineer_close_approval_required ? 2 : 3) , job_completed_at: DateTime.now, job_close_approval_required: engineer_close_approval_required, job_close_approval_requested: close_approval_requested, job_closed_at: (engineer_close_approval_required ? nil : DateTime.now)

        @ticket.ticket_close_approval_required = (@ticket.ticket_fsrs.any? or @ticket.ticket_spare_parts.any? or @ticket.ticket_on_loan_spare_parts.any?)
        @ticket.ticket_close_approval_requested = true
        @ticket.ticket_close_approved = true

        final_resolution =  @ticket.ticket_engineers.none?{|eng| eng.status.to_i < 2 }
        if final_resolution
          @ticket.ticket_status_resolve = TicketStatusResolve.find_by_code("RSV")
          @ticket.job_finished = true
          @ticket.job_finished_at = DateTime.now

          if not @ticket.ticket_close_approval_required
            @ticket.job_closed = true
            @ticket.job_closed_at = DateTime.now
          end
        end

        if @ticket.ticket_close_approval_required
          @ticket.ticket_engineers.each do |eng|
            if eng.job_close_approval_required
              @ticket.ticket_close_approval_requested = false if eng.job_close_approval_required and not eng.job_close_approval_requested
              @ticket.ticket_close_approved = false if eng.job_close_approval_required and not eng.job_close_approved
            end
          end
        else
          @ticket.ticket_close_approval_requested = false
          @ticket.ticket_close_approved = false
        end

        if (@ticket.cus_chargeable or @ticket.cus_payment_required) and !(@ticket.ticket_estimations.any?)
          @ticket.cus_chargeable = false
          @ticket.cus_payment_required = false
        end

        d9_qc_required = (@ticket.ticket_type.code == "IH" and CompanyConfig.first.sup_qc_required) ? "Y" : "N"
        supp_engr_user = current_user.id
        d4_job_complete = "Y"
        d6_close_approval_required = @ticket_engineer.job_close_approval_required ? "Y" : "N"
        d7_close_approval_requested = @ticket_engineer.job_close_approval_requested ? "Y" : "N"
        d8_job_finished = final_resolution ? "Y" : "N"
        d10_job_estimate_required_final = (@ticket.cus_chargeable or @ticket.cus_payment_required) ? "Y" : "N"
        d11_terminate_job = @ticket.ticket_terminated ? "Y" : "N"
        d12_need_to_invoice = (@ticket.cus_chargeable or @ticket.cus_payment_required) ? "Y" : "N"

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: supp_engr_user, d4_job_complete: d4_job_complete, d6_close_approval_required: d6_close_approval_required, d7_close_approval_requested: d7_close_approval_requested, d8_job_finished: d8_job_finished, d9_qc_required: d9_qc_required, d10_job_estimate_required_final: d10_job_estimate_required_final, d11_terminate_job: d11_terminate_job, d12_need_to_invoice: d12_need_to_invoice)

        if final_resolution
          if d9_qc_required == "Y"
            @ticket.ticket_status = TicketStatus.find_by_code("QCT")
          elsif (@ticket.cus_chargeable or @ticket.cus_payment_required)
            @ticket.ticket_status = TicketStatus.find_by_code("PMT")
          else
            @ticket.ticket_status = TicketStatus.find_by_code("CFB")
          end
        end

        @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(55).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count, action_engineer_id: engineer_id) if @ticket_engineer.job_close_approval_requested

        if final_resolution
          #Action 88 - Finish Job
          user_ticket_action = @ticket.user_ticket_actions.build(action_id: TaskAction.find_by_action_no(88).id, action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket.re_open_count, action_engineer_id: engineer_id)
          user_ticket_action.build_ticket_finish_job(resolution: "")

          @ticket.owner_engineer_id = engineer_id if !@ticket.ticket_close_approval_required
        end

        @ticket.save

        #Calculate Total Costs and Time
        @ticket.calculate_ticket_total_cost

        @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        # File.open(Rails.root.join("bug_file.txt"), "w+"){|file| file.write("bpm_variables: #{bpm_variables}\nbpm_response: #{@bpm_response}\n"); file.close}
        # @bpm_response = view_context.send_request complete_task: true, task_id: params[:task_id], query: bpm_variables

        if @bpm_response[:status].upcase == "SUCCESS"

          all_success = true
          error_engs = []
          if not final_resolution
            next_engineer = @ticket.ticket_engineers.where(parent_engineer_id: @ticket_engineer.id).first
            if  next_engineer.present?

              # bpm output variables
              ticket_id = @ticket.id
              di_pop_approval_pending = "N"
              priority = @ticket.priority
              d42_assignment_required = "N"

              supp_engr_user = next_engineer.user_id
              engineer_id = next_engineer.id
              supp_hd_user = @ticket.created_by

              @bpm_response1 = view_context.send_request_process_data start_process: true, process_name: "SPPT", query: {ticket_id: ticket_id, d1_pop_approval_pending: di_pop_approval_pending, priority: priority, d42_assignment_required: d42_assignment_required, engineer_id: engineer_id , supp_engr_user: supp_engr_user, supp_hd_user: supp_hd_user}

              if @bpm_response1[:status].try(:upcase) == "SUCCESS"
                workflow_process = @ticket.ticket_workflow_processes.create(process_id: @bpm_response1[:process_id], process_name: @bpm_response1[:process_name], engineer_id: engineer_id)

                view_context.ticket_bpm_headers @bpm_response1[:process_id], @ticket.id

                next_engineer.update status: 1, job_assigned_at: DateTime.now, workflow_process_id: workflow_process.id

                email_template = EmailTemplate.find_by_code("ASSIGN_JOB")

                email_to = next_engineer.user.email
                if email_template.try(:active)
                  view_context.send_email(email_to: email_to, ticket_id: ticket_id, engineer_id: next_engineer.id, email_code: "ASSIGN_JOB") if email_to.present?

                  
                  next_engineer.ticket_support_engineers.each do |support_engineer|
                    email_to = support_engineer.user.email
                    view_context.send_email(email_to: email_to, ticket_id: ticket_id, engineer_id: next_engineer.id, email_code: "ASSIGN_JOB") if email_to.present?

                  end

                end

              else
                all_success = false
                @bpm_process_error = true
                error_engs << engineer_id
              end

            end
          else # Final Resolution
            if (@ticket.try(:ticket_type_code) != "OS") and (@ticket.ticket_status.code == 'CFB')  #Customer Feedback
              email_to = @ticket.send("contact_person#{@ticket.inform_cp}").contact_person_contact_types.find_by_contact_type_id(ContactType.find_by_name("E-mail").id).try(:value)

              if email_to.present?
                view_context.send_email(email_to: email_to, ticket_id: @ticket.id, email_code: "COMPLETE_JOB")
              end
            end
          end

          if all_success
            flash[:notice] = "Successfully updated."
          else
            flash[:error] = "ticket is updated. Engineer assignment error. (#{error_engs.join(', ')})"
          end

        else
          flash[:error] = "ticket is updated. but Bpm error"
        end
      else
        flash[:error] = "ticket is failed to updated."
      end
    else
      flash[:error] = "BPM Error."
    end
    redirect_to @ticket
  end

  def update_hp_case_id

    TaskAction
    @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if @continue
      if @ticket.update ticket_params

        @ticket_engineer = TicketEngineer.find params[:engineer_id]
        @ticket_engineer.update job_started_at: DateTime.now if !@ticket_engineer.job_started_at.present?

        # bpm output variables

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id)

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

        @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if @bpm_response[:status].upcase == "SUCCESS"
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
    @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if @continue
      if @ticket.update ticket_params

        @ticket_engineer = TicketEngineer.find params[:engineer_id]
        @ticket_engineer.update job_started_at: DateTime.now if !@ticket_engineer.job_started_at.present?

        # bpm output variables

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id, d21_edit_serial_no: "Y")

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

        @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if @bpm_response[:status].upcase == "SUCCESS"
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
    TicketSparePart
    @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]

    if @continue

      t_params = ticket_params
      @ticket.attributes = t_params
      ticket_deliver_unit = @ticket.ticket_deliver_units.last

      ticket_deliver_unit.note = "#{ticket_deliver_unit.note} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{ticket_deliver_unit.note_was}" if ticket_deliver_unit and ticket_deliver_unit.note.present?

      if @ticket.save
        ticket_deliver_unit = @ticket.ticket_deliver_units.last
        user_ticket_action = @ticket.user_ticket_actions.last
        user_ticket_action.build_deliver_unit(ticket_deliver_unit_id: ticket_deliver_unit.id)
        user_ticket_action.save

        @ticket_engineer = TicketEngineer.find params[:engineer_id]
        @ticket_engineer.update job_started_at: DateTime.now if !@ticket_engineer.job_started_at.present?

        # bpm output variables

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id, d22_deliver_unit: "Y", deliver_unit_id: ticket_deliver_unit.id, d23_delivery_items_pending: "N")

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

        @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        # view_context.ticket_bpm_headers params[:process_id], @ticket.id, ""

        if @bpm_response[:status].upcase == "SUCCESS"
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
    @ticket.attributes = t_params
    ticket_deliver_unit = @ticket.ticket_deliver_units.find_by_id ticket_delivery_unit_id

    ticket_deliver_unit.note = "#{ticket_deliver_unit.note} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{ticket_deliver_unit.note_was}" if ticket_deliver_unit and ticket_deliver_unit.note.present?

    if @ticket.save
      user_ticket_action = @ticket.user_ticket_actions.last
      user_ticket_action.build_deliver_unit(ticket_deliver_unit_id: ticket_deliver_unit.id)
      user_ticket_action.save

      @ticket_engineer = TicketEngineer.find params[:engineer_id]
      @ticket_engineer.update job_started_at: DateTime.now if !@ticket_engineer.job_started_at.present?

      @flash_message = "Successfully updated."
    else
      @flash_message = "Un successfully updated."
    end
    redirect_to @ticket, notice: @flash_message
  end

  def update_job_estimation_request #External Job
    TaskAction
    @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]
    engineer_id = params[:engineer_id]

    if @continue

      if @ticket.update ticket_params

        @ticket_engineer = TicketEngineer.find params[:engineer_id]
        @ticket_engineer.update job_started_at: DateTime.now if !@ticket_engineer.job_started_at.present?

        user_ticket_action = @ticket.user_ticket_actions.last
        job_estimate = user_ticket_action.job_estimation
        ticket_estimation = @ticket.ticket_estimations.last

        job_estimate.note = ticket_estimation.note
        job_estimate.save

        ticket_estimation.ticket_estimation_externals.build(ticket_id: @ticket.id, repair_by_id: job_estimate.supplier_id, description: params[:description])
        ticket_estimation.engineer_id = engineer_id
        ticket_estimation.request_type = "EX"
        ticket_estimation.save

        # bpm output variables

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id, d13_job_estimate_requested_external: "Y")

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"
        @ticket.update_attribute(:status_resolve_id, TicketStatusResolve.find_by_code("ERQ").id)

        @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if @bpm_response[:status].upcase == "SUCCESS"
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
    @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]
    engineer_id = params[:engineer_id]
    requested_quantity = params[:requested_quantity]
    query = {}

    # bpm output variables
    ticket_id = @ticket.id
    supp_engr_user = current_user.id
    priority = @ticket.priority
    request_onloan_spare_part_id = "-"
    onloan_request = "N"
    process_name = ""
    estimation_required = CompanyConfig.first.sup_nc_estimation_required

    if @continue
      @ticket_spare_part = TicketSparePart.new
      f_ticket_spare_part_params = ticket_spare_part_params(@ticket_spare_part)

      @ticket_spare_part = TicketSparePart.new f_ticket_spare_part_params
      @ticket_spare_part.requested_at = DateTime.now
      @ticket_spare_part.requested_by = current_user.id
      @ticket_spare_part.engineer_id = engineer_id
      @ticket_spare_part.request_approval_required = false

      if @ticket_spare_part.save

        if @ticket_spare_part.cus_chargeable_part
          estimation_required = true
          d44_store_part_need_approval = CompanyConfig.first.sup_st_parts_ch_need_approval ? "Y" : "N"
          d45_manufacture_part_need_approval = CompanyConfig.first.sup_mf_parts_ch_need_approval ? "Y" : "N"
        else
          d44_store_part_need_approval = CompanyConfig.first.sup_st_parts_nc_need_approval ? "Y" : "N"
          d45_manufacture_part_need_approval = CompanyConfig.first.sup_mf_parts_nc_need_approval ? "Y" : "N"
        end

        d18_approve_request_store_part =  (d44_store_part_need_approval == "N") ? "Y" : "N"

        @ticket_engineer = TicketEngineer.find params[:engineer_id]
        @ticket_engineer.update job_started_at: DateTime.now if !@ticket_engineer.job_started_at.present?

        SparePartDescription.find_or_create_by(description: @ticket_spare_part.spare_part_description)
        request_spare_part_id = @ticket_spare_part.id

        if @ticket_spare_part.request_from == "M"
          @ticket_spare_part.update request_approval_required: true if d45_manufacture_part_need_approval == "Y"

          @ticket_spare_part.update_attribute :status_action_id, SparePartStatusAction.find_by_code("MPR").id unless estimation_required #@ticket_spare_part.cus_chargeable_part
          action_id = TaskAction.find_by_action_no(14).id
          @ticket_spare_part.create_ticket_spare_part_manufacture(payment_expected_manufacture: 0, manufacture_currency_id: @ticket_spare_part.ticket.manufacture_currency_id, requested_quantity: requested_quantity, po_required: CompanyConfig.first.sup_mf_parts_po_required)

          process_name = "SPPT_MFR_PART_REQUEST"
          query = {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, supp_engr_user: supp_engr_user, priority: priority, d45_manufacture_part_need_approval: d45_manufacture_part_need_approval, d46_manufacture_part_approved: "Y"}

        elsif @ticket_spare_part.request_from == "S"
          @ticket_spare_part.update request_approval_required: true if d44_store_part_need_approval == "Y"

          @ticket_spare_part.update_attribute :status_action_id, SparePartStatusAction.find_by_code("STR").id unless estimation_required #@ticket_spare_part.cus_chargeable_part
          action_id = TaskAction.find_by_action_no(15).id

          @ticket_spare_part_store = @ticket_spare_part.create_ticket_spare_part_store(store_id: params[:store_id], inv_product_id: params[:inv_product_id], mst_inv_product_id: params[:mst_inv_product_id], part_of_main_product: (params[:part_of_main_product] || 0), store_requested: !@ticket_spare_part.cus_chargeable_part, store_requested_at: ( !@ticket_spare_part.cus_chargeable_part ? DateTime.now : nil), store_requested_by: ( !@ticket_spare_part.cus_chargeable_part ? current_user.id : nil), requested_quantity: requested_quantity)

          process_name = "SPPT_STORE_PART_REQUEST"
          query = {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, request_onloan_spare_part_id: request_onloan_spare_part_id, onloan_request: onloan_request, supp_engr_user: supp_engr_user, priority: priority, d44_store_part_need_approval: d44_store_part_need_approval, d18_approve_request_store_part: d18_approve_request_store_part}

        elsif @ticket_spare_part.request_from == "NS"
          #@ticket_spare_part.update_attribute :status_action_id, SparePartStatusAction.find_by_code("RQT").id
          action_id = TaskAction.find_by_action_no(78).id

          @ticket_spare_part_non_stock = @ticket_spare_part.create_ticket_spare_part_non_stock(inv_product_id: params[:inv_product_id], requested_quantity: requested_quantity)
        end

        @ticket_spare_part.ticket_spare_part_status_actions.create(status_id: @ticket_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

        @ticket_spare_part.ticket.update_attribute :status_resolve_id, TicketStatusResolve.find_by_code("POD").id

        user_ticket_action = @ticket_spare_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket_spare_part.ticket.re_open_count, action_id: action_id, action_engineer_id: engineer_id)
        user_ticket_action.build_request_spare_part(ticket_spare_part_id: @ticket_spare_part.id)
        user_ticket_action.save

        if estimation_required # Create Estimate

          action_id = TaskAction.find_by_action_no(33).id
          user_ticket_action = @ticket_spare_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket_spare_part.ticket.re_open_count, action_id: action_id, action_engineer_id: engineer_id)
          user_ticket_action.build_request_spare_part(ticket_spare_part_id: @ticket_spare_part.id)

          @ticket_estimation = @ticket_spare_part.ticket.ticket_estimations.build requested_at: DateTime.now, requested_by: current_user.id, approval_required: true, status_id: EstimationStatus.find_by_code("RQS").id, currency_id: @ticket_spare_part.ticket.base_currency_id, engineer_id: engineer_id, request_type: "PT"
          ticket_estimation_part = @ticket_estimation.ticket_estimation_parts.build ticket_id: @ticket_spare_part.ticket.id, ticket_spare_part_id: @ticket_spare_part.id

          user_ticket_action.save
          @ticket_estimation.save

          part_estimation_id = @ticket_estimation.id

          process_name = "SPPT_PART_ESTIMATE"
          query = {ticket_id: ticket_id, part_estimation_id: part_estimation_id, supp_engr_user: supp_engr_user, priority: priority}

          @ticket_spare_part.update_attribute :estimation_required, true

        else
          if d44_store_part_need_approval == "N" and @ticket_spare_part.request_from == "S"
            #Create SRN
            @ticket_spare_part.ticket_spare_part_store.create_support_srn(current_user.id, @ticket_spare_part.ticket_spare_part_store.store_id, @ticket_spare_part.ticket_spare_part_store.inv_product_id, @ticket_spare_part.ticket_spare_part_store.requested_quantity, @ticket_spare_part.ticket_spare_part_store.mst_inv_product_id )

          end
        end

        # bpm output variables

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id, request_spare_part_id: @ticket_spare_part.id, onloan_request: "N", d15_part_estimate_required:  (estimation_required ? "Y" : "N"), part_estimation_id: (estimation_required ? part_estimation_id : "-"), d16_request_manufacture_part: ((@ticket_spare_part.request_from == "M" and !estimation_required) ? "Y" : "N"), d17_request_store_part: ((@ticket_spare_part.request_from == "S" and !estimation_required) ? "Y" : "N"))

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

        @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        if process_name.present?
          @bpm_response1 = view_context.send_request_process_data start_process: true, process_name: process_name, query: query

          if @bpm_response1[:status].try(:upcase) == "SUCCESS"
            est_id = estimation_required ? part_estimation_id : nil
            @ticket.ticket_workflow_processes.create(process_id: @bpm_response1[:process_id], process_name: @bpm_response1[:process_name], engineer_id: @ticket_spare_part.engineer_id, spare_part_id: request_spare_part_id, estimation_id: est_id)
            view_context.ticket_bpm_headers @bpm_response1[:process_id], @ticket.id, request_spare_part_id
          else
            @bpm_process_error = true
          end
        end

        if @bpm_response[:status].upcase == "SUCCESS"
          @flash_message = {notice: "Successfully updated."}
        else
          @flash_message = {alert: "ticket is updated. but Bpm error"}
        end

        @flash_message = {alert: "#{@flash_message} Unable to start new process."} if @bpm_process_error

      else
        @flash_message = {alert: "Errors in updating. Please re-try."}
      end
    else
      @flash_message = {alert: "Unable to continue with BPM. Please rectify BPM"}
    end
    redirect_to todos_url, @flash_message
  end

  def suggesstion_data
    TicketSparePart
    respond_to do |format|
      format.json {render json: SparePartDescription.active_spare_part_descriptions.map { |s| s.description }} # ["DESC1", "desc2"]
    end
  end

  def update_request_on_loan_spare_part
    
    TaskAction
    WorkflowMapping
    @continue = view_context.bpm_check params[:task_id], params[:process_id], params[:owner]
    engineer_id = params[:engineer_id]
    requested_quantity = params[:requested_quantity]

    if @continue
      f_ticket_on_loan_spare_part_params = ticket_on_loan_spare_part_params
      # f_ticket_on_loan_spare_part_params[:ticket_attributes][:remarks] = f_ticket_on_loan_spare_part_params[:ticket_attributes][:remarks].present? ? "#{f_ticket_on_loan_spare_part_params[:ticket_attributes][:remarks]} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@ticket.remarks}" : @ticket.remarks
      @ticket_on_loan_spare_part = TicketOnLoanSparePart.new f_ticket_on_loan_spare_part_params
      @ticket_on_loan_spare_part.note = "#{@ticket_on_loan_spare_part.note} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span>"

      @ticket_on_loan_spare_part.requested_at = DateTime.now
      @ticket_on_loan_spare_part.requested_by = current_user.id
      @ticket_on_loan_spare_part.engineer_id = engineer_id
      @ticket_on_loan_spare_part.requested_quantity = requested_quantity

      if @ticket_on_loan_spare_part.save

        @ticket_engineer = TicketEngineer.find params[:engineer_id]
        @ticket_engineer.update job_started_at: DateTime.now if !@ticket_engineer.job_started_at.present?

        action_id = TaskAction.find_by_action_no(18).id


        @ticket_on_loan_spare_part.ticket_on_loan_spare_part_status_actions.create(status_id: @ticket_on_loan_spare_part.status_action_id, done_by: current_user.id, done_at: DateTime.now)

        @ticket_on_loan_spare_part.ticket.update_attribute :status_resolve_id, TicketStatusResolve.find_by_code("POD").id

        user_ticket_action = @ticket_on_loan_spare_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: @ticket_on_loan_spare_part.ticket.re_open_count, action_id: action_id, action_engineer_id: engineer_id)
        user_ticket_action.build_request_on_loan_spare_part(ticket_on_loan_spare_part_id: @ticket_on_loan_spare_part.id)
        user_ticket_action.save


        # bpm output variables

        bpm_variables = view_context.initialize_bpm_variables.merge(supp_engr_user: current_user.id, request_onloan_spare_part_id: @ticket_on_loan_spare_part.id, onloan_request: "Y", d17_request_store_part: "Y")

        @ticket.update_attribute(:status_id, TicketStatus.find_by_code("RSL").id) if @ticket.ticket_status.code == "ASN"

        @bpm_response = view_context.send_request_process_data complete_task: true, task_id: params[:task_id], query: bpm_variables

        # bpm output variables
        ticket_id = @ticket.id
        request_spare_part_id = "-"
        supp_engr_user = current_user.id
        priority = @ticket.priority

        part_estimation_id = "-"

        request_onloan_spare_part_id = @ticket_on_loan_spare_part.id
        onloan_request = "Y"

        d44_store_part_need_approval = CompanyConfig.first.sup_st_parts_ch_need_approval ? "Y" : "N"
        d18_approve_request_store_part =  (d44_store_part_need_approval == "N") ? "Y" : "N"

        # Create Process "SPPT_STORE_PART_REQUEST"

        bpm_response1 = view_context.send_request_process_data start_process: true, process_name: "SPPT_STORE_PART_REQUEST", query: {ticket_id: ticket_id, request_spare_part_id: request_spare_part_id, request_onloan_spare_part_id: request_onloan_spare_part_id, onloan_request: onloan_request, supp_engr_user: supp_engr_user, priority: priority, d44_store_part_need_approval: d44_store_part_need_approval, d18_approve_request_store_part: d18_approve_request_store_part}


        if bpm_response1[:status].try(:upcase) == "SUCCESS"
          @ticket.ticket_workflow_processes.create(process_id: bpm_response1[:process_id], process_name: bpm_response1[:process_name], engineer_id: engineer_id, on_loan_spare_part_id: request_onloan_spare_part_id)

          view_context.ticket_bpm_headers bpm_response1[:process_id], @ticket.id, "", request_onloan_spare_part_id
        else
          @bpm_process_error = true
        end

        if @bpm_response[:status].upcase == "SUCCESS"
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

  def hp_po
    Inventory
    TicketSparePart
    Product
    Currency
    authorize! :hp_po, SoPo

    @po = SoPo.new
    if params[:product_brand_id].present?
      @product_brand = ProductBrand.find params[:product_brand_id]
      @products = @product_brand.products
    else
    end
    respond_to do |format|
      format.json
      format.html
    end
  end

  def view_po
    TicketSparePart
    Product
    Currency

    authorize! :view_po, SoPo

    refined_query = ""
    if params[:search].present?
      support_ticket_no = "so_po_items.ticket_spare_part.ticket.support_ticket_no:#{params[:support_ticket_no]}" if params[:support_ticket_no].present?
      po_no_format = "po_no_format:#{params[:po_no_format]}" if params[:po_no_format].present?
      product_brand_id = "product_brand_id:#{params[:product_brand_id]}" if params[:product_brand_id].present?

      refined_query = [support_ticket_no, po_no_format, product_brand_id].compact.join(" AND ")

    end
    params[:query] = refined_query
    @po = SoPo.search(params)
    # render "tickets/view_po"

    case params[:po_callback]
    when "select_po"
      @po = SoPo.find_by_id params[:po_id]
      if SoPo.find_by_id params[:po_id]
        render "tickets/view_selected_po"
      end
    else
      render "tickets/view_po"
    end
  end

  def view_delivered_bundle
    authorize! :view_delivered_bundle, ReturnPartsBundle
    TicketSparePart
    ReturnPartsBundle
    Product
    User
    @delivered_bundles = ReturnPartsBundle.where(delivered: true)
  end

  def create_po
    TicketSparePart
    Organization
    Inventory
    User
    TaskAction
    Ticket

    authorize! :create_po, SoPo

    @po = SoPo.new po_params

    if @po.save
      @po.so_po_items.each do |item|
        ticket_spare_part = item.ticket_spare_part

        ticket_spare_part.ticket_spare_part_manufacture.update po_completed: true

        # Action #86 PO Added
        user_ticket_action = ticket_spare_part.ticket.user_ticket_actions.build(action_at: DateTime.now, action_by: current_user.id, re_open_index: ticket_spare_part.ticket.re_open_count, action_id: 86)
        user_ticket_action.build_request_spare_part(ticket_spare_part_id: ticket_spare_part.id)
        user_ticket_action.save

        ticket_spare_part.ticket.set_ticket_close(current_user.id)
      end


      # @prn.inventory_prn_items.each do |prn_item|
      #   prn_item.update closed: true if prn_item.quantity <= prn_item.inventory_po_items.sum(:quantity)
      # end
      # @prn.update closed: true if @prn.inventory_prn_items.all?{ |e| e.closed }
      # if params[:spare_part].present?
      #   @spare_part_id = TicketSparePart.find params[:spare_part]
      # end
      flash[:notice] = "Successfully saved"
      respond_to do |format|
        format.html{ redirect_to hp_po_tickets_path }
      end
      
    else
      flash[:alert] = "Unable to save. Please review."
      respond_to do |format|
        format.html{ redirect_to hp_po_tickets_path }
      end
      # format.html{ render "admins/inventories/po/form"}
    end
  end

  def load_serialparts
    @brand = ProductBrand.find params[:brand_id]
    # @rpermissions = Rpermission.all.map { |rpermission| {resource: rpermission.controller_resource, name: rpermission.name, id: rpermission.id, checked: "#{'checked' if @role.rpermissions.include?(rpermission)}"} }
    # @rserialparts = Rpermission.all.group_by{|g| g.controller_resource}.map{|k, v| {resource: k, value: v.map{|rpermission| {resource: rpermission.controller_resource, name: rpermission.name, id: rpermission.id, checked: "#{'checked' if @role.rpermissions.include?(rpermission)}"}}}}
    respond_to do |format|
      format.json
      format.html
    end
  end



  private

    def update_bpm_header
      if @continue
        process_id = ((@bpm_response and @bpm_response[:process_id]) || params[:process_id])
        ticket_id = ( @ticket.try(:id) || params[:ticket_id] )
        ticket_spare_part_id = (@ticket_spare_part.try(:id) || params[:request_spare_part_id])
        ticket_onloan_spare_part_id = (@onloan_request_part.try(:id) || params[:request_onloan_spare_part_id])

        view_context.ticket_bpm_headers process_id, ticket_id, ticket_spare_part_id, ticket_onloan_spare_part_id
        Rails.cache.delete([:workflow_header, process_id])
      end
      @ticket.current_user_id = current_user.id if @ticket.present? and @ticket.is_a?(Ticket) and @ticket.persisted?

    end

    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    def set_product_in_new_ticket
      @ticket_time_now = params[:ticket_time_now]
      @product = Product.find params[:product_id]
    end

    def set_organization_for_ticket
      @organization = Organization.owner
    end

    def ticket_params
      ticket_params = params.require(:ticket).permit(:onsite_type_id, :owner_engineer_id, :logged_at, :ticket_no, :ticket_close_approved, :note, :current_user_id, :sla_id, :serial_no, :status_hold, :repair_type_id, :base_currency_id, :ticket_close_approval_required, :ticket_close_approval_requested, :regional_support_job, :job_started_action_id, :job_start_note, :job_started_at, :contact_type_id, :cus_chargeable, :informed_method_id, :job_type_id, :other_accessories, :priority, :problem_category_id, :problem_description, :remarks, :inform_cp, :resolution_summary, :status_id, :ticket_type_id, :warranty_type_id, :status_resolve_id, :contract_id, :owner_organization_id, ticket_deliver_units_attributes: [:deliver_to_id, :note, :created_at, :created_by, :received, :id, :received_at, :received_by, :current_user_id], ticket_accessories_attributes: [:id, :accessory_id, :note, :_destroy], q_and_answers_attributes: [:problematic_question_id, :answer, :ticket_action_id, :id], joint_tickets_attributes: [:joint_ticket_id, :id, :_destroy], ge_q_and_answers_attributes: [:id, :general_question_id, :answer, :ticket_action_id], ticket_estimations_attributes: [:note, :currency_id, :status_id, :requested_at, :requested_by, :request_type], user_ticket_actions_attributes: [:id, :action_engineer_id, :_destroy, :action_at, :action_by, :action_id, :re_open_index, user_assign_ticket_action_attributes: [:sbu_id, :_destroy, :assign_to, :recorrection], assign_regional_support_centers_attributes: [:regional_support_center_id, :_destroy], ticket_re_assign_request_attributes: [:reason_id, :_destroy], ticket_action_taken_attributes: [:action, :_destroy], ticket_terminate_job_attributes: [:id, :reason_id, :foc_requested, :_destroy], act_hold_attributes: [:id, :reason_id, :_destroy, :un_hold_action_id], hp_case_attributes: [:id, :case_id, :case_note], ticket_finish_job_attributes: [:resolution, :_destroy], act_terminate_job_payments_attributes: [:id, :amount, :payment_item_id, :_destroy, :ticket_id, :currency_id], act_fsr_attributes: [:print_fsr], serial_request_attributes: [:reason], job_estimation_attributes: [:supplier_id]], ticket_extra_remarks_attributes: [:id, :note, :created_by, :extra_remark_id, :_destroy], products_attributes: [:id, :sold_country_id, :pop_note, :pop_doc_url, :pop_status_id], ticket_fsrs_attributes: [:id, :form_no, :engineer_id, :work_started_at, :work_finished_at, :hours_worked, :down_time, :travel_hours, :engineer_time_travel, :other_mileage, :other_repairs, :engineer_time_on_site, :resolution, :completion_level, :created_by, :remarks, :approved, :current_user_id], ticket_on_loan_spare_parts_attributes: [:id, :approved_inv_product_id, :approved_store_id, :approved_main_inv_product_id, :approved, :return_part_damage, :return_part_damage_reason_id])
      ticket_params[:current_user_id] = current_user.id
      ticket_params
    end

    def product_brand_params
      params.require(:product_brand).permit(:sla_id, :name, :parts_return_days, :warenty_date_format, :currency_id, :organization_id)
    end

    def product_params
      params.require(:product).permit(:serial_no, :name,:pop_doc_url, :product_brand_id, :sold_country_id, :product_category_id, :model_no, :product_no, :pop_status_id, :coparate_product, :sla_id, :pop_note, ticket_product_serials_attributes: [:id, :ref_product_serial_id])
    end

    def category_params
      params.require(:product_category).permit(:name, :product_brand_id, :sla_id)
    end

    def customer_params
      params.require(:customer).permit(:name, :organization_id, :title_id, :address1, :address2, :address3, :address4,:district_id, contact_type_values_attributes: [:id, :contact_type_id, :value, :_destroy])
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
      ticket_fsr_params = params.require(:ticket_fsr).permit(:form_no, :travel_hours, :work_started_at, :work_finished_at, :office_out_at, :office_in_at, :hours_worked, :down_time, :engineer_time_travel, :other_mileage, :other_repairs, :engineer_time_on_site, :resolution, :completion_level, :remarks, :ticket_id, ticket_attributes: [:remarks, :id], ticket_fsr_support_engineers_attributes: [:id ,:engineer_support_id, :hours_worked])
      ticket_fsr_params[:current_user_id] = current_user.id
      ticket_fsr_params[:work_started_at] = Time.strptime(ticket_fsr_params[:work_started_at],'%m/%d/%Y %I:%M %p') if ticket_fsr_params[:work_started_at].present?
      ticket_fsr_params[:work_finished_at] = Time.strptime(ticket_fsr_params[:work_finished_at],'%m/%d/%Y %I:%M %p') if ticket_fsr_params[:work_finished_at].present?
      ticket_fsr_params[:office_out_at] = Time.strptime(ticket_fsr_params[:office_out_at],'%m/%d/%Y %I:%M %p') if ticket_fsr_params[:office_out_at].present?
      ticket_fsr_params[:office_in_at] = Time.strptime(ticket_fsr_params[:office_in_at],'%m/%d/%Y %I:%M %p') if ticket_fsr_params[:office_in_at].present?
      ticket_fsr_params
    end

    def ticket_spare_part_params(spt_ticket_spare_part)
      tspt_params = params.require(:ticket_spare_part).permit(:approved_store_id, :approved_inv_product_id, :approved_main_inv_product_id, :spare_part_no, :spare_part_description, :ticket_id, :fsr_id, :cus_chargeable_part, :request_from, :faulty_serial_no, :received_part_serial_no, :received_part_ct_no, :repare_start, :repare_end, :faulty_ct_no, :note, :status_action_id, :status_use_id, :part_terminated, :part_terminated_reason_id, :returned_part_accepted, :request_approved, ticket_attributes: [:remarks, :id], ticket_spare_part_manufacture_attributes: [:id, :event_no, :order_no, :id, :event_closed, :ready_to_bundle, :payment_expected_manufacture, :po_required], ticket_spare_part_store_attributes: [:part_of_main_product, :id, :approved_store_id, :approved_inv_product_id, :approved_main_inv_product_id, :return_part_damage, :return_part_damage_reason_id], request_spare_parts_attributes: [:reject_return_part_reason_id], ticket_on_loan_spare_parts_attributes: [:id, :approved_store_id, :approved_inv_product_id, :approved_main_inv_product_id, :approved, :ticket_id, :return_part_damage, :return_part_damage_reason_id] )

      tspt_params[:repare_start] = Time.strptime(tspt_params[:repare_start],'%m/%d/%Y %I:%M %p') if tspt_params[:repare_start].present?
      tspt_params[:repare_end] = Time.strptime(tspt_params[:repare_end],'%m/%d/%Y %I:%M %p') if tspt_params[:repare_end].present?

      # tspt_params[:note] = tspt_params[:note].present? ? "#{tspt_params[:note]} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{spt_ticket_spare_part.note}" : spt_ticket_spare_part.note
      spt_ticket_spare_part.current_user_id = current_user.id
      tspt_params
    end

    def ticket_on_loan_spare_part_params
      params.require(:ticket_on_loan_spare_part).permit(:approved, :approved_store_id, :approved_inv_product_id, :approved_main_inv_product_id, :ref_spare_part_id, :note, :ticket_id, :status_action_id, :status_use_id, :store_id, :inv_product_id, :main_inv_product_id, :part_of_main_product, :return_part_damage, :return_part_damage_reason_id, ticket_attributes: [:remarks, :id])
    end

    def act_warranty_extend_params
      params.require(:action_warranty_extend).permit(:reject_reason_id, :reject_note, :extended)
    end

    def return_bundle_params
      params.require(:return_parts_bundle).permit(:id, :bundle_no, :note)
    end

    def po_params
      tspt_params = params.require(:so_po).permit(:id, :created_at, :created_by, :so_no, :po_no, :po_date, :amount, :invoiced, :currency_id, :product_brand_id, :note, so_po_items_attributes: [ :id, :_destroy, :spt_so_po_id, :item_no, :amount, :ticket_spare_part_id])
      tspt_params
    end

    def add_edit_contract_params
      params.require(:ticket_contract).permit(:id, :customer_id, :contract_no, :contract_b2b, :sla_id, :created_at, :created_by)
    end

    def invoice_so_params
      params.require(:invoice).permit(:id, :created_at, :created_by, :invoice_no, :total_amount, :note, :currency_id, :print_count, invoice_items_attributes: [ :id, :_destroy, :invoice_id, :item_no, :description, :amount])
    end
end
