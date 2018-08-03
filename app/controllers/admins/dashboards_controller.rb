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

    def regenerate_jbpm
      jbpm_params = params[:jbpm_inputs]
      flash_message = {notice: 'processing...' }
      authorize! :reindex_all_model, Organization

      begin
        case
        when jbpm_params.present?
          formatted_params = eval(jbpm_params)

          @bpm_response = view_context.send_request_process_data formatted_params

          if @bpm_response[:status].try(:upcase) == "SUCCESS"
            flash_message = {notice: 'JBPM is successfully updated.' }
          else
            flash_message = {alert: 'Failed to updated.' }
          end

        end
      rescue
        flash_message = {alert: 'Application error occured' }
      end

      redirect_to admins_dashboards_url, flash_message

    end

    def reindex_all_model
      authorize! :reindex_all_model, Organization

      DashboardsController.async( ttr: 1800.seconds ).reindex_all_models_async

      respond_to do |format|
        format.html {redirect_to admins_root_url, notice: 'Index is successfully initiated. System needs around 20-30 minutes to complete indexing...'}
      end
    end

    def self.reindex_all_models_async
      # [['Grn'], ['GrnItem', 'Grn'], ['GrnBatch', 'Grn'], ['InventoryProduct', 'Inventory'], ['InventorySerialItem', 'Inventory'], ['InventoryBatch', 'Inventory'], ['Product'], ['Ticket', 'ContactNumber'], ['InventoryPrn', 'Inventory'], ['InventoryPo', 'Inventory'], ["Gin"], ['Organization'], ['SoPo', 'TicketSparePart'], [ "Srr", "Srr" ], [ "Srn", "Srn" ], [ "SrnItem", "Srn" ], ["ContactPerson1", "User"], ["ContactPerson2", "User"], ["ReportPerson", "User"], ["Customer", "User"]].each do |models|
      #   system "rake environment tire:deep_import CLASS=#{models.first} PCLASS=#{models.last} FORCE=true"
      # end
      system "rake environment tire:index_all_model RAILS_ENV=#{Rails.env}"

    end

    # private :reindex_all_models_async

    # handle_asynchronously :reindex_all_models_async, queue: 'model-index', pri: 5000

  end
end