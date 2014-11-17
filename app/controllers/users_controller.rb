class UsersController < ApplicationController

  before_action :authenticate_user!
  before_action :set_user, only: [:profile, :initiate_user_profile_edit, :update]

  def new
    begin
      organization_id = view_context.decrypt_org(params[:organization_id])
      @user = User.new(organization_id: organization_id)
    rescue
      flash[:error] = "Invalid organization is selected. Please try again or contact administrator."
      redirect_to root_url
    end
  end

  #Displaying the user details
  def profile

    #Address linked to this user
    @address_list = @user.other_addresses
    @primary_address = @user.primary_address
    @primary_contact_number = @user.primary_contact_number
    @contact_number_list = @user.other_contact_numbers
  end

  def create
    @user = User.new user_params
    respond_to do |format|
      if @user.save
        format.html {redirect_to profile_user_url(@user), notice: "Employee is successfully created"}
      else
        format.html {render :new}
      end
    end
  end
  #Updating the user details
  def update
    
    [:user_name_primary_details,:password_security_details, :additional_details].each do |template_param|
      if params[template_param]
        @template_params = template_param.to_s
        if current_user.valid_password?(params[:current_user_password])
          if @user.update_attributes user_params
            flash[:notice] = "Profile is successfully updated"
            render js: "window.location.href='"+profile_user_url+"'" and return
            break
          else
            render :initiate_user_profile_edit and return
            break
          end
        else
          flash[:error] = "Please provide your valid password"
          render js: "window.location.href='"+profile_user_url+"'" and return
          break
        end
      end
    end
  end

  #Functions for ajax
  def initiate_user_profile_edit

    @template_params = params[:template_params]
    case @template_params
    when "addresses_primary_details"
      # @user.addresses.build
    end
    respond_to do |format|
      format.js
    end
  end

  private
    def set_user
      @user =  User.find params[:id]
    end

    def user_params
      params.require(:user).permit(:email, :avatar, :user_name, :organization_id, :designation_id, :password, :password_confirmation, :NIC, :epf_no, :date_joined_at, :first_name, :last_name, :name_title, addresses_attributes: [:id, :category, :address, :_destroy])
    end

end