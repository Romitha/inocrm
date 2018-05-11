module Admins
  class DashboardsController < ApplicationController
    include Backburner::Performable

    layout "admins"
    
    def index
      @tickets = Ticket.order("created_at DESC")
      @products = Product.all
      @ProductBrands = ProductBrand.all
      @TicketTypes = TicketType.all
      @JobTypes = JobType.all
      @Warranties = Warranty.all
      @WarrantyTypes = WarrantyType.all
    end

    # post params[:resource_name], params[:resource_id]
    def validate_resource
      resource_name = params[:resource_name].classify.constantize
      resource_id = params[:resource_id]
      resource_column = params[:resource_column]
      resource_column_value = params[:resource_column_value]

      more_attr = params[:more_attr]

      resource_hash = {resource_column.to_sym => resource_column_value }.merge(more_attr || {})

      if resource_id.present?
        @resource = resource_name.find resource_id
        @resource.attributes = resource_hash
      else
        @resource = resource_name.new resource_hash
      end

      if @resource.valid?
        response = true
      else
        response = @resource.errors.messages[resource_column.to_sym].blank?
      end

      render json: response

    end

    def reindex_all_model
      authorize! :reindex_all_model, Organization

      DashboardsController.async( ttr: 900.seconds ).reindex_all_models_async

      respond_to do |format|
        format.html {redirect_to admins_root_url, notice: 'Index is successfully initiated. System needs around 2-5 minutes to complete indexing...'}
      end
    end

    def self.reindex_all_models_async
      [['Grn'], ['GrnItem', 'Grn'], ['GrnBatch', 'Grn'], ['InventoryProduct', 'Inventory'], ['InventorySerialItem', 'Inventory'], ['InventoryBatch', 'Inventory'], ['Product'], ['Ticket', 'ContactNumber'], ['InventoryPrn', 'Inventory'], ['InventoryPo', 'Inventory'], ["Gin"], ['Organization'], ['SoPo', 'TicketSparePart'], [ "Srr", "Srr" ], [ "Srn", "Srn" ], [ "SrnItem", "Srn" ], ["ContactPerson1", "User"], ["ContactPerson2", "User"], ["ReportPerson", "User"], ["Customer", "User"]].each do |models|
        system "rake environment tire:deep_import CLASS=#{models.first} PCLASS=#{models.last} FORCE=true"
      end
    end

    # private :reindex_all_models_async

    # handle_asynchronously :reindex_all_models_async, queue: 'model-index', pri: 5000

  end
end