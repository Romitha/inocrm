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
  end
end