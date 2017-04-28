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
  def create
    Ticket

    if params[:save].present?
      if params[:contract_id].present?
        @contract = TicketContract.find params[:contract_id]
        @contract.attributes = contract_params
      else
        @contract = TicketContract.new contract_params
      end

      @organization = @contract.organization
      @ticket_contracts = @organization.ticket_contracts.page params[:page]


      @contract.save

    end
    render :index
  end

  private
    def contract_params
      params.require(:ticket_contract).permit(:id, :created_at, :created_by, :customer_id, :sla_id, :contract_no, :contract_type_id, :hold, :contract_b2b, :remind_required, :currency_id, :amount, :contract_start_at, :contract_end_at, :remarks, :attachment_url, contract_products_attributes: [ :id, :_destroy, :invoice_id, :item_no, :description, :amount, :sla_id, product_attributes:[:id, :serial_no, :product_brand_id, :product_category_id, :model_no, :product_no, :pop_status_id, :sold_country_id, :pop_note, :pop_doc_url, :corporate_product, :sold_at, :sold_by, :remarks]])
    end

end