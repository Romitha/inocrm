class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization, only: [:show, :edit, :update]

  def index
    @organizations = Organization.order("created_at DESC")
    @suppliers = Organization.suppliers
    @customers = Organization.customers
  end

  def new
    @organization = Organization.new(category: params[:category])
  end

  def edit
    # @address = @organization.addresses.build
    respond_to do |format|
      format.html
    end
  end

  def show

  end

  def create
    @organization = Organization.new organization_params

    respond_to do |format|
      if @organization.save
        format.html {redirect_to @organization, notice: "#{@organization.category} is successfully created."}
      else
        format.html {render :new}
      end
    end
  end

  def update
    respond_to do |format|
      if @organization.update_attributes(organization_params)
        format.html {redirect_to root_url, notice: "Organization #{@organization.name} has been updated successfully"}
        format.json { head :no_content } # 204 No Content
      else
        format.html {render :edit}
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_organization
      @organization = Organization.find params[:id]
    end

    def organization_params
      params.require(:organization).permit(:name, :category, :description, :logo, :vat_number, :web_site, :code, :short_name, addresses_attributes: [:id, :category, :address, :primary, :_destroy],  contact_numbers_attributes: [:id, :category, :value, :_destroy])
    end
end
