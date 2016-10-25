class ContactNumbersController < ApplicationController
  before_action :set_contact_number, only: [:update, :destroy, :make_primary_contact_number]
  after_action :update_index_model, except: [:destroy_customer_contact_detail, :create]

  respond_to :html, :xml, :json

	def create
    @contact_number = ContactNumber.new(contact_number_params)
    respond_to do |format|
      if @contact_number.c_numberable_type == "User"
        if current_user.valid_password?(params[:current_user_password])
          if @contact_number.save
            format.html {redirect_to profile_user_path(@contact_number.c_numberable), notice: "contact_number is successfully created."}
          else
            format.html {redirect_to profile_user_path(@contact_number.c_numberable), error: "Something gone error with contact_number field. #{@contact_number.errors.full_messages.join(',')}"}
          end
        else
          flash[:error] = "Please provide your correct password."
          format.html {redirect_to profile_user_path(@contact_number.c_numberable)}
        end
      else
        if @contact_number.save
          @contact_number.c_numberable.update_index
          format.html {redirect_to polymorphic_path([:edit, @contact_number.c_numberable]), notice: "contact_number is successfully created"}
          format.json {render json: @contact_number}
        else
          flash[:error] = "Something gone error with contact_number field. #{@contact_number.errors.full_messages.join(',')}"
          format.html {redirect_to polymorphic_path([:edit, @contact_number.c_numberable])}
          format.json {render json: @contact_number.errors}
        end
      end
      
    end
  end

  def update
    @contact_number.update(contact_number_params)
    respond_with(@contact_number)
  end

  def destroy
    @contact_number.destroy
    # respond_with(@contact_number)
    respond_to do |format|
      format.html {redirect_to (@contact_number.c_numberable_type == "User" ? profile_user_path(@contact_number.c_numberable) : polymorphic_path([@contact_number.c_numberable])), notice: "Address is successfully deleted."}
    end
  end

  def destroy_customer_contact_detail
    @organization = Organization.find params[:organization_id]
    ContactNumber
    @customer = Customer.find params[:customer_id]
    @customer.contact_types.delete_all
    @customer.destroy
    @organization.update_index
    redirect_to organization_path(@organization), notice: "Successfully deleted!"

  end

  def make_primary_contact_number
    ContactNumber.where(primary: true).each do |contact_number|
      contact_number.update_attribute(:primary, false)
    end
    @contact_number.update_attribute(:primary, true)

    respond_to do |format|
      format.html {redirect_to (@contact_number.c_numberable_type=="User" ? profile_user_url(@contact_number.c_numberable) : polymorphic_url([@contact_number.c_numberable])), notice: "contact_number is set to primary."}
    end
  end


  private
    def set_contact_number
      @contact_number = ContactNumber.find(params[:id])
    end

    def update_index_model
      if @contact_number.c_numberable_type == "Organization"
        @contact_number.c_numberable.update_index
      end
    end

    def contact_number_params
      params.require(:contact_number).permit(:category, :value, :primary, :c_numberable_type, :c_numberable_id, :country_id, :province_id, :district_id, :type_id)
    end
end
