class ContractsController < ApplicationController

  def index
    Ticket
    Organization
    IndustryType

    # if params[:search].present?
    #   refined_contract = params[:contract].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
    #   params[:query] = refined_contract
    #   @contracts = TicketContract.search(params)
    # end

    if params[:search].present?
      refined_customer = params[:organization_customers].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
      params[:query] = ["accounts_dealer_types.dealer_code:CUS", refined_customer].map { |v| v if v.present? }.compact.join(" AND ")
      @organizations = Organization.search(params)

      total_customers = @organizations.total

      @print_object = {
        totalCustomers: total_customers,
      }

    end

    if params[:select]
      if params[:organization_id]
        @organization = Organization.find params[:organization_id]
        @ticket_contracts = @organization.ticket_contracts.page params[:page]
      end
    end

    if params[:edit_create]
      @organization = Organization.find params[:customer_id]

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

    if params[:save]
      if params[:contract_id]
        @contract = TicketContract.find params[:contract_id]
        @contract.attributes = contract_params
      else
        @contract = @organization.ticket_contracts.build contract_params
      end
      @contract.save
    end
  end

  def search_product
    if params[:search_product]
      puts "*************************"
      @products = Product.search(params)
      puts "*************************"
    end
  end

  def create
    Ticket

    if params[:ajax_upload].present?
      puts "*************************"
      puts params[:ajax_upload]
      puts "*************************"
      if params[:contract_id].present?
        @contract = TicketContract.find params[:contract_id]
        @contract.attributes = contract_params
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
          if cached_contract.try(:id) == @contract.id
            puts "****************************"
            puts "On the way to assign"
            puts "****************************"
            cached_contract.save

            # @contract.attributes = cached_contract.attributes
            @contract.attributes = contract_params

          end
        else
          @contract = (cached_contract or TicketContract.new)
          @contract.attributes = contract_params

        end

        Rails.cache.delete([:new_product_with_pop_doc_url1, request.remote_ip])

        @contract.save


      end
    end

    @organization = @contract.organization
    @ticket_contracts = @organization.ticket_contracts.page params[:page]

    render :index
  end

  private
    def contract_params
      params.require(:ticket_contract).permit(:id, :created_at, :created_by, :customer_id, :sla_id, :contract_no, :contract_type_id, :hold, :contract_b2b, :remind_required, :currency_id, :amount, :contract_start_at, :contract_end_at, :remarks, :attachment_url, :owner_organization_id, contract_products_attributes: [ :id, :_destroy, :invoice_id, :item_no, :description, :amount, :sla_id, :remarks, product_attributes:[:id, :_destroy, :serial_no, :product_brand_id, :product_category_id, :model_no, :product_no, :pop_status_id, :sold_country_id, :pop_note, :pop_doc_url, :corporate_product, :sold_at, :sold_by, :remarks]])
    end

end