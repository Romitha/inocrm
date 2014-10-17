class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization, only: [:edit, :update]

  def index
    if current_user.has_role?(:admin)
      @organization = Organization.find_by_refers("VSIS")
    else
      @organization = Organization.order("created_at DESC")
    end
  end

  def new
    @organization = Organization.new
  end

  def edit
    # @address = @organization.addresses.build
    respond_to do |format|
      format.html
    end
  end

  def update
    respond_to do |format|
      if @organization.update_attributes(organization_params)
        format.html {redirect_to root_url, notice: "Organization #{@organization.name} has been updated successfully"}
      else
        format.html {render :edit}
      end
    end
  end

  private
    def set_organization
      @organization = Organization.find params[:id]
    end

    def organization_params
      params.require(:organization).permit(:name, :description, :logo, :vat_number, :web_site, :code, :short_name, addresses_attributes: [:id, :category, :address, :_destroy])
    end
end
