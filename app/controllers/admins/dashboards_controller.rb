module Admins
  class DashboardsController < ApplicationController
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
      resource_hash = {resource_column.to_sym => resource_column_value }

      if resource_id.present?
        @resource = resource_name.find resource_id
        @resource.attributes = resource_hash
      else
        @resource = resource_name.new resource_hash
      end

      if @resource.valid?
        response = true
      else
        response = false
      end

      render json: response

    end
  end
end