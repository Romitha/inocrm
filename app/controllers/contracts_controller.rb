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
      end
    end

    if params[:edit_create]
      if params[:contract_id]
        @contract = TicketContract.find params[:contract_id]
        @contract.attributes = contract_params
      else
        @contract = TicketContract.new contract_params
      end
      @contract.save
    end

  end

  private
  def contract_params
    params.require(:ticket_contract).permit(:id, :created_at, :created_by, :customer_id, :contract_no, :contract_type_id, :hold, :contract_b2b, :remind_required, :currency_id, :amount, :contract_start_at, :contract_end_at, :remarks, :attachment_url, contract_products_attributes: [ :id, :_destroy, :invoice_id, :item_no, :description, :amount, product_attributes:[:id, :serial_no, :product_brand_id, :product_category_id, :model_no, :product_no, :pop_status_id, :sold_country_id, :pop_note, :pop_doc_url, :corporate_product, :sold_at, :sold_by]])
  end

end