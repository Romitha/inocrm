class ContractsController < ApplicationController


  def index
    Ticket
    Organization
    IndustryType
    Product
    ContactNumber

    # if params[:search].present?
    #   refined_contract = params[:contract].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
    #   params[:query] = refined_contract
    #   @contracts = TicketContract.search(params)
    # end

    if params[:search].present?
      refined_customer = params[:organization_customers].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
      params[:query] = ["accounts_dealer_types.dealer_code:CUS", refined_customer].map { |v| v if v.present? }.compact.join(" AND ")
      @organizations = Organization.search(params)

    end

    if params[:search_contract_details].present?
      refined_contract = params[:search_contracts].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
      refined_search = [refined_contract, refined_search].map{|v| v if v.present? }.compact.join(" AND ")
      
      params[:query] = refined_contract
      @contracts = TicketContract.search(params)

    end

    if params[:search_cus_product].present?
      refined_customer = params[:organization_customers].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
      params[:query] = ["accounts_dealer_types.dealer_code:CUS", refined_customer].map { |v| v if v.present? }.compact.join(" AND ")
      @organizations = Organization.search(params)

    end

    if params[:select]
      if params[:organization_id]
        @organization = Organization.find params[:organization_id]
        @contracts = @organization.ticket_contracts.page params[:page]
      end
    end

    if params[:select_ticket]
      if params[:organization_id]
        @organization = Organization.find params[:organization_id]
        # @ticket_contracts = @organization.ticket_contracts.page params[:page]
        @contract_products = @organization.contract_products
      end
    end

    if params[:select_product]
      if params[:organization_id]
        @organization = Organization.find params[:organization_id]
        @organization.products.build if @organization.products.blank?
        # @ticket_contracts = @organization.ticket_contracts.page params[:page]
        # @contract_products = @organization.contract_products
      end
    end

    if params[:select_product_ticket]
      if params[:organization_id]
        @organization = Organization.find params[:organization_id]
        @organization.products.build if @organization.products.blank?
        # @ticket_contracts = @organization.ticket_contracts.page params[:page]
        # @contract_products = @organization.contract_products
      end
    end

    if params[:edit_create]
      Rails.cache.delete([:contract_products, request.remote_ip])

      @organization = Organization.find params[:customer_id]
      # @product = Product.find params[:product_serial_id]

      @contract = if params[:contract_id].present?
        @edit_action = "true"
        @organization.ticket_contracts.find params[:contract_id]
      else
        @organization.ticket_contracts.build
      end
    end

    if params[:edit_create_contract]
      Rails.cache.delete([:contract_products, request.remote_ip])

      @organization = Organization.find params[:customer_id]
      # @product = Product.find params[:product_serial_id]
      @contract_products = @organization.contract_products.where(contract_id: params[:contract_id])
      @contract = if params[:contract_id].present?
        @edit_action = "true"
        @organization.ticket_contracts.find params[:contract_id]
      else
        @organization.ticket_contracts.build
      end
    end

    if params[:view_contract]
      Invoice
      Rails.cache.delete([:contract_products, request.remote_ip])

      @organization = Organization.find params[:customer_id]
      @products = ContractProduct.all

      @contract_products = @organization.contract_products.where(contract_id: params[:contract_id])


      @contract_payment = ContractPaymentReceived.where(contract_id: params[:contract_id])
      # @product = Product.find params[:product_serial_id]

      @contract = if params[:contract_id].present?
        @organization.ticket_contracts.find params[:contract_id]
      else
        @organization.ticket_contracts.build
      end

      @contract_payment_received = ContractPaymentReceived.new contract_id: params[:contract_id]

      render "contracts/view_contract"
    end

   if params[:view_product]
      # Rails.cache.delete([:contract_products, request.remote_ip])
      @product = Product.find params[:product_id]
      if params[:serial_product]
      else
        if !params[:view_serial_product]
          @contract_product = ContractProduct.find params[:contract_id]
        else
          @contract_product = TicketContract.find params[:contract_id]
        end
      end
      render "contracts/view_product"
    end
    
    if params[:select_contract]
      @organization = Organization.find params[:customer_id]

      if params[:contract_id]
        @contract = TicketContract.find params[:contract_id]
        @products = @contract.products
      end
    end

    if params[:save].present?
      if params[:contract_id].present?
        @contract = TicketContract.find params[:contract_id]
        @contract.attributes = contract_params
      else
        @contract = @organization.ticket_contracts.build contract_params
      end

      @contract.save

      @contract.products.each do |product|
        product.create_product_owner_history(@organization.id, current_user.id, "Added in contract")

      end

    end

    if params[:save_product].present?
      if params[:owner_customer_id].present?

        @cus_product = Product.find params[:owner_customer_id]
        @cus_product.attributes = customer_product_params
      else

        @cus_product = @organization.products.build customer_product_params
      end

      @cus_product.save

      @cus_product.products.each do |product|
        product.create_product_owner_history(@organization.id, current_user.id, "Added in contract")

      end
    end
  end

  def search_product
    if params[:search_product]
      @products = Product.search(params)
    end
  end

  def search_product_contract
    if params[:search_product]
      # @products = Product.where(owner_customer_id: params[:customer_id])
      if params[:product_brand].present?
        fined_query = ["owner_customer_id:#{params[:customer_id]}", "product_brand_id:#{params[:product_brand]}", "product_category_id:#{params[:product_category]}", params[:query]].map { |e| e if e.present? }.compact.join(" AND ")
        if params[:contract_id].present?
          @contract_id = TicketContract.find params[:contract_id]
          @products = Product.search(query: fined_query).select{|p| !@contract_id.product_ids.map(&:to_s).include? p.id }
        else
          @products = Product.search(query: fined_query)
        end

        @organization1 = Organization.find params[:customer_id]
      end
    end
  end

  def edit_contract
    @contract_detail = TicketContract.find params[:contract_id]
    respond_to do |format|
      if @contract_detail.update contract_params
        format.json { render json: @contract_detail }
      else
        format.json { render json: @contract_detail.errors }
      end
    end
  end

  def submit_selected_products
    Address
    if params[:done].present?
      if params[:serial_products_ids].present?
        serial_products = Product.where(id: params[:serial_products_ids])
        @before_count = Rails.cache.fetch([:contract_products, request.remote_ip]).to_a.count
        Rails.cache.delete([:contract_products, request.remote_ip])
        @organization_for_location = Organization.find params[:organization_id]
        if params[:contract_id].present?
          @contract_id = TicketContract.find params[:contract_id]
        end
        @cached_products = Rails.cache.fetch([:contract_products, request.remote_ip]){ serial_products.to_a }
      else
        @before_count = Rails.cache.fetch([:contract_products, request.remote_ip]).to_a.count
        Rails.cache.delete([:contract_products, request.remote_ip])
      end
    end

    if params[:remove].present?
      a = Rails.cache.fetch([:contract_products, request.remote_ip])
      @organization_for_location = Organization.find params[:organization_id]
      if params[:contract_id].present?
        @contract_id = TicketContract.find params[:contract_id]
      end
      a.delete_if{|e| e.id.to_f == params[:selected_product].to_f }
      Rails.cache.delete([:contract_products, request.remote_ip])

      @cached_products = Rails.cache.fetch([:contract_products, request.remote_ip]){ a }
    end

    if params[:done_cus_product].present?
      if params[:serial_products_ids].present?
        serial_products = Product.where(id: params[:serial_products_ids])
        puts serial_products.count
        Rails.cache.delete([:products, request.remote_ip])

        @cached_products = Rails.cache.fetch([:products, request.remote_ip]){ serial_products.to_a }
      end
    end

    if params[:remove_cus_product].present?
      a = Rails.cache.fetch([:products, request.remote_ip])

      a.delete_if{|e| e.id.to_f == params[:selected_product].to_f }
      Rails.cache.delete([:products, request.remote_ip])

      @cached_products = Rails.cache.fetch([:products, request.remote_ip]){ a }
    end
  end

  def create
    Ticket

    if params[:ajax_upload].present?
      if params[:contract_id].present?
        @contract = TicketContract.find params[:contract_id]
        @contract.attributes = contract_params
        @contract.save
      else
        @contract = TicketContract.new contract_params
      end

      Rails.cache.write([:new_product_with_pop_doc_url1, request.remote_ip], @contract)

    else
      if params[:save].present?
        cached_contract = Rails.cache.fetch([:new_product_with_pop_doc_url1, request.remote_ip])
        if params[:contract_id].present?
          @contract = TicketContract.find params[:contract_id]
          
          @contract.attributes = contract_params

        else
          @contract = (cached_contract or TicketContract.new)
          @contract.attributes = contract_params
        end
        Rails.cache.delete([:new_product_with_pop_doc_url1, request.remote_ip])
        @contract.save

        # contract_document_path = File.join(Dir.home, INOCRM_CONFIG["upload_url"], "/contract_documents/#{@contract.id}/")
        # contract_document_dir = Dir.exist?(contract_document_path)

        # if not contract_document_dir
        #   Dir.mkdir(contract_document_path, 0775)
        # end

        if params[:contract_document].present?
          params[:contract_document]['annexture_id'].each do |annexture_id|
            annexture = Documents::Annexture.find annexture_id

            # annexture_exists = File.exist?( File.join( contract_document_path, [@contract.product_brand.name.downcase.gsub(/\W/, ""), "-", annexture.template_name.downcase.gsub(/\W/,""), File.extname(annexture.document_url.file.path)].join("") ) )

            # if annexture.document_url.present? and !annexture_exists
            #   FileUtils.cp annexture.document_url.file.path, contract_document_path
            #   File.rename File.join(contract_document_path, File.basename(annexture.document_url.file.path)), [contract_document_path, @contract.product_brand.name.downcase.gsub(/\W/, ""), "-", annexture.template_name.downcase.gsub(/\W/,""), File.extname(annexture.document_url.file.path)].join("")

            # end

            if annexture.document_url.present?
              name = "#{@contract.product_brand.try(:name)}_#{@contract.id}_#{annexture.template_name}"

              contract_document = @contract.contract_documents.find_or_initialize_by name: name

              unless contract_document.document_url.present?
                contract_document.document_url = annexture.document_url.file
                contract_document.save!
              end

            end

          end
        end

        # @contract.contract_attachments.each do |contract_attachment|
        #   FileUtils.cp contract_attachment.attachment_url.file.path, contract_document_path

        # end

        Rails.cache.fetch([:contract_products, request.remote_ip]).to_a.each do |product|
          unless @contract.product_ids.include?(product.id)
            c_product = @contract.contract_products.create(product_serial_id: product.id, sla_id: product.product_brand.sla_id)

            if params['contract_product_additional_params'].present?

              if params['contract_product_additional_params'][c_product.product_serial_id.to_s].present?
                c_product_attr = params['contract_product_additional_params'].require(c_product.product_serial_id.to_s).permit('amount', 'discount_amount', 'installed_location_id' )
                c_product.update c_product_attr
                c_product.ticket_contract.update_index
              end
            end

          end

        end

        Rails.cache.delete([:contract_products, request.remote_ip])

      end
      @organization = @contract.organization
      @ticket_contracts = @organization.ticket_contracts
    end


    render :index
  end

  def generate_contract_document
    Ticket
    @contract = TicketContract.find(params[:contract_id])
    # contract_document_path = File.join(Dir.home, INOCRM_CONFIG["upload_url"], "/contract_brand_documents/#{@contract.id}/")
    # contract_document_dir = Dir.exist?(contract_document_path)

    # if not contract_document_dir
    #   Dir.mkdir(contract_document_path, 0775)
    # end
    generated = false
    @contract.product_brand.brand_documents.each do |brand_document|
      if brand_document.document_file_name.present?

        doc_name = "brand_doc_#{brand_document.id}_brand_#{@contract.product_brand.name}"
        doc = if Rails.env == 'develpment'
          DocxReplace::Doc.new(brand_document.document_file_name.file.path, "#{Rails.root}/tmp")
        else
          DocxReplace::Doc.new(File.join(brand_document.document_file_name.file.path), "#{Rails.root}/tmp")
        end

        @contract.doc_varibles.each do |k, v|
          doc.replace "##{k}", v
        end

        contract_document = @contract.contract_documents.find_or_initialize_by name: doc_name
        # contract_document_dir = File.join(contract_document.document_url.root, contract_document.document_url.store_dir)

        write_doc = Tempfile.new(doc_name, "#{Rails.root}/tmp")
        doc.commit(write_doc.path)
        File.rename write_doc.path, "#{Rails.root}/tmp/#{doc_name}.docx"

        contract_document_path = File.join(Rails.root, 'tmp', "contract_#{@contract.id}")


        contract_tmp_dir = Dir.exist?(contract_document_path)

        if not contract_tmp_dir
          Dir.mkdir(contract_document_path, 0775)
        end

        File.open("#{Rails.root}/tmp/#{doc_name}.docx"){|f| contract_document.document_url = f}

        contract_document.save!

        generated = true

      end

    end

    if generated
      cost_table = "contract_#{@contract.id}_brand_#{@contract.product_brand.name}_cost_table"

      cost_table_document = @contract.contract_documents.find_or_initialize_by name: cost_table

      contract_elements = []
      table_header = ["ELEMENT OR OPTION", "SERIAL NO", "DESCRIPTION", "AMOUNT"]

      contract_elements << table_header

      @contract.contract_products.each do |contract_product|
        contract_elements << ['', contract_product.product.serial_no, contract_product.product.description, contract_product.amount]
      end

      contract_elements.concat [['', '', 'Sub Total', @contract.contract_products.sum(:amount)], ['', '', 'Special Total', @contract.contract_products.sum(:discount_amount)], ['', '', 'Total Amount', (@contract.contract_products.sum(:amount) - @contract.contract_products.sum(:discount_amount))]]

      Caracal::Document.save "tmp/contract_#{@contract.id}/generated_table.docx" do |docx|
        docx.table contract_elements, border_size: 4 do
          cell_style rows[0], bold: true
        end
      end

      File.open("#{Rails.root}/tmp/contract_#{@contract.id}/generated_table.docx"){|f| cost_table_document.document_url = f}

      cost_table_document.save!

      @contract.update last_doc_generated_at: DateTime.now, last_doc_generated_by: current_user.id
      @contract.increment! :document_generated_count, 1

      flash[:notice] = "Successfully generated."
    else
      flash[:error] = "Please attach document(s) to related brand."

    end

    redirect_to contracts_url

  end

  def upload_generated_document
    @contract_document = Documents::ContractDocument.find params[:contract_document_id]

    @contract_document.document_url = params[:generated_document]

    @contract_document.save!

  end

  def remove_generated_document
    @contract_document = Documents::ContractDocument.find params[:contract_document_id]
    @contract_document.destroy
  end

  def contract_update
    @contract = TicketContract.find params[:contract_id]

    if @contract.update contract_params
      render json: @contract
    else
      render json: @contract.errors
    end
  end

  def save_cus_products
    if params[:save_product].present?
      if params[:owner_customer_id].present?
        @cus_product = Organization.find params[:owner_customer_id]
        @cus_product.attributes = customer_product_params
        if @cus_product.save
          Rails.cache.fetch([:products, request.remote_ip]).to_a.each do |product|
            product.update owner_customer_id: params[:owner_customer_id]
            # unless @cus_product.product_ids.include?(product.id)
            #   @cus_product.products.create(owner_customer_id: )
            # end
          end
          Rails.cache.delete([:products, request.remote_ip])

          @cus_product.products.each do |product|
            product.create_product_owner_history(@cus_product.id, current_user.id, "Added in Product")
          end
        end
      end
    end
    render :index
  end

  def payments_save
    Invoice
    Ticket
    payment_completed = (params[:payment_completed].present? and params[:payment_completed].to_bool)
    contract_payment_received = ContractPaymentReceived.new payment_params
    
    @contract = TicketContract.find params[:contract_id]
    @contract.update_attributes(payment_completed: payment_completed)
    
    respond_to do |format|
      contract_payment_received.created_by = current_user.id
      if contract_payment_received.save
        format.html {redirect_to contracts_path, notice: "Payments Successfully Saved"}
      else
        flash[:notice] = "Payment Unsuccessful"
        format.html {redirect_to contracts_path}
      end
    end
  end

  def update_payments
    Invoice
    contract_payment_received = ContractPaymentReceived.find params[:payment_id]
    respond_to do |format|
      if contract_payment_received.update payment_params
        format.json { render json: contract_payment_received }
      else
        format.json { render json: contract_payment_received.errors }
      end
    end
  end
  
  def update_contract_product
    Ticket
    contract_product = ContractProduct.find params[:contract_product_id]
    respond_to do |format|
      if contract_product.update contract_product_params
        contract_product.ticket_contract.update_index
        format.json { render json: contract_product }
      else
        format.json { render json: contract_product.errors }
      end
    end
  end

  def customer_search
    Ticket
    Organization
    IndustryType
    Product

    render "customer_product/customer_search"
  end

  private
    def contract_params
      params.require(:ticket_contract).permit(:id, :created_at, :created_by, :customer_id, :sla_id, :contract_no, :contract_type_id, :hold, :contract_b2b, :remind_required, :currency_id, :amount, :contract_start_at, :contract_end_at, :remarks, :owner_organization_id, :process_at, :legacy_contract_no, :organization_bill_id, :bill_address_id, :organization_contact_id, :product_brand_id, :product_category_id, :contact_person_id, :additional_charges, :season, :contact_address_id, :accepted_at, :payment_type_id, :documnet_received, contract_products_attributes: [ :id, :_destroy, :invoice_id, :item_no, :description, :amount, :sla_id, :remarks, product_attributes: [:id, :_destroy, :serial_no, :product_brand_id, :product_category_id, :model_no, :product_no, :pop_status_id, :sold_country_id, :pop_note, :pop_doc_url, :corporate_product, :sold_at, :sold_by, :remarks]], contract_attachments_attributes: [:id, :_destroy, :attachment_url])
    end

    def payment_params
      params.require(:contract_payment_received).permit(:id, :contract_id, :payment_installment, :payment_received_at, :amount, :created_at, :created_by, :invoice_no, :remarks)
    end

    def customer_product_params
      params.require(:organization).permit(:id, products_attributes: [:id, :serial_no, :product_brand_id, :product_category_id, :model_no, :product_no, :pop_status_id, :sold_country_id, :pop_note, :pop_doc_url, :corporate_product, :sold_at, :sold_by, :remarks, :description, :name, :date_installation, :note, :_destroy])
    end

    def contract_product_params
      params.require(:contract_product).permit(:id, :amount, :discount_amount, :installed_location_id)
    end

end