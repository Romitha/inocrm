class UsersController < ApplicationController

  before_action :authenticate_user!
  before_action :set_user, only: [:profile, :initiate_user_profile_edit, :update]

  def new
    @user = User.new
  end

  #Displaying the user details
  def profile

    #Address linked to this user
    @address_list = @user.addresses
  end

  #Updating the user details
  def update
    
    [:user_name_primary_details,:password_security_details].each do |template_param|
      if params[template_param]
        @template_params = template_param.to_s
        if current_user.valid_password?(params[:current_user_password])
          if @user.update_attributes organization_params
            flash[:notice] = "Profile is successfully updated"
            render js: "window.location.href='"+profile_user_url+"'" and return
            break
          else
            render :initiate_user_profile_edit and return
            break
          end
        else
          flash[:notice] = "Please provide your valid password"
          render js: "window.location.href='"+profile_user_url+"'" and return
          break
        end
      end
    end
  end

  #Functions for ajax
  def initiate_user_profile_edit

    @template_params = params[:template_params]
    respond_to do |format|
      format.js
    end
  end

  private
    def set_user
      @user =  User.find params[:id]
    end

    def organization_params
      params.require(:user).permit(:user_name, :designation_id, :password, :password_confirmation)
    end

end