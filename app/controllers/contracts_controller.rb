class ContractsController < ApplicationController

  def index
    Ticket
    Organization
    IndustryType
    Product

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
        @organization.ticket_contracts.find params[:contract_id]
      else
        @organization.ticket_contracts.build
      end
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

  def submit_selected_products
    if params[:done].present?
      if params[:serial_products_ids].present?
        serial_products = Product.where(id: params[:serial_products_ids])
        puts serial_products.count
        Rails.cache.delete([:contract_products, request.remote_ip])

        @cached_products = Rails.cache.fetch([:contract_products, request.remote_ip]){ serial_products.to_a }
      end
    end

    if params[:remove].present?
      a = Rails.cache.fetch([:contract_products, request.remote_ip])

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
      # @contract = (Rails.cache.read([:new_product_with_pop_doc_url, request.remote_ip]) or Product.new)
      # @new_product.attributes = product_params
      if params[:save].present?
        cached_contract = Rails.cache.fetch([:new_product_with_pop_doc_url1, request.remote_ip])

        if params[:contract_id].present?
          @contract = TicketContract.find params[:contract_id]
          # if cached_contract.try(:id) == @contract.id
          #   puts "****************************"
          #   puts "On the way to assign"
          #   puts "****************************"
          #   cached_contract.save

          #   # @contract.attributes = cached_contract.attributes

          # end
          @contract.attributes = contract_params

        else
          @contract = (cached_contract or TicketContract.new)
          @contract.attributes = contract_params

        end

        Rails.cache.delete([:new_product_with_pop_doc_url1, request.remote_ip])

        @contract.save

        Rails.cache.fetch([:contract_products, request.remote_ip]).to_a.each do |product|
          unless @contract.product_ids.include?(product.id)
            @contract.contract_products.create(product_serial_id: product.id, sla_id: product.product_brand.sla_id)
          end

        end

        Rails.cache.delete([:contract_products, request.remote_ip])

      end
      @organization = @contract.organization
      @ticket_contracts = @organization.ticket_contracts
    end


    render :index
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

  def customer_search
    Ticket
    Organization
    IndustryType
    Product

    render "customer_product/customer_search"
  end

  private
    def contract_params
      params.require(:ticket_contract).permit(:id, :created_at, :created_by, :customer_id, :sla_id, :contract_no, :contract_type_id, :hold, :contract_b2b, :remind_required, :currency_id, :amount, :contract_start_at, :contract_end_at, :remarks, :owner_organization_id, :process_at, contract_products_attributes: [ :id, :_destroy, :invoice_id, :item_no, :description, :amount, :sla_id, :remarks, product_attributes:[:id, :_destroy, :serial_no, :product_brand_id, :product_category_id, :model_no, :product_no, :pop_status_id, :sold_country_id, :pop_note, :pop_doc_url, :corporate_product, :sold_at, :sold_by, :remarks]])
    end

    def customer_product_params
      params.require(:organization).permit(:id, products_attributes: [:id, :serial_no, :product_brand_id, :product_category_id, :model_no, :product_no, :pop_status_id, :sold_country_id, :pop_note, :pop_doc_url, :corporate_product, :sold_at, :sold_by, :remarks, :description, :name, :date_installation, :note, :_destroy])
    end

end