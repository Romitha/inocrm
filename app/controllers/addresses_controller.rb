class AddressesController < ApplicationController
  before_action :set_address, only: [:show, :edit, :update, :destroy, :make_primary_address]
  respond_to :html, :xml, :json

  def index
    @addresses = Address.all
    respond_with(@addresses)
  end

  def show
    respond_with(@address)
  end

  def new
    @address = Address.new
    respond_with(@address)
  end

  def edit
  end

  def create
    @address = Address.new(address_params)
    respond_to do |format|
      if @address.addressable_type == "User"
        if current_user.valid_password?(params[:current_user_password])

          if @address.save!
            @address.addressable.update_index
            format.html {redirect_to profile_user_path(@address.addressable), notice: "Address is successfully created."}
          else
            format.html {redirect_to profile_user_path(@address.addressable), error: "Something gone error with address field. #{@address.errors.full_messages.join(',')}"}
          end
        else
          flash[:error] = "Please provide your correct password."
          format.html {redirect_to profile_user_path(@address.addressable)}
        end
      else
        if @address.save
          @address.addressable.update_index
          format.html {redirect_to polymorphic_path([:edit, @address.addressable]), notice: "Address is successfully created"}
          format.json {render json: @address}
        else
          flash[:error] = "Something gone error with address field. #{@address.errors.full_messages.join(',')}"
          format.html {redirect_to polymorphic_path([:edit, @address.addressable])}
          format.json {render json: @address.errors}
        end
      end
    end
  end

  def update
    @address.update(address_params)
    respond_with(@address)
  end

  def destroy
    @address.destroy

    respond_to do |format|
      format.html {redirect_to (@address.addressable_type == "User" ? profile_user_path(@address.addressable) : polymorphic_path([@address.addressable])), notice: "Address is successfully deleted."}
    end
  end

  def make_primary_address
    @organization = Organization.find params[:organization_id]

    @organization.addresses.where(primary: true).each do |address|
      address.update_attribute(:primary, false)
    end
    @address.update_attribute(:primary, true)

    respond_to do |format|
      format.html {redirect_to (@address.addressable_type == "User" ? profile_user_path(@address.addressable) : polymorphic_path([@address.addressable])), notice: "Address is set to primary."}
    end
  end

  private
    def set_address
      @address = Address.find(params[:id])
    end

    def address_params
      params.require(:address).permit(:category, :address1, :address2, :address3, :city, :primary, :addressable_type, :addressable_id, :country_id, :province_id, :district_id, :contact_person_title_id, :contact_person_name)
    end
end
