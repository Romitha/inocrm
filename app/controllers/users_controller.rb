class UsersController < ApplicationController
  load_and_authorize_resource except: [:assign_role, :check_user_session]
  before_action :set_user, only: [:profile, :initiate_user_profile_edit, :update, :upload_avatar, :request_user_active, :accept_user_active]
  before_filter :user_session_expired, except: [:check_user_session]

  def new
    authorize! :new, User

    session[:is_customer] = nil
    begin
      organization_id = view_context.decrypt_org(params[:organization_id]) unless params[:is_customer]
      session[:is_customer] = (params[:is_customer] ? "true" : "false")
      @user = User.new(organization_id: organization_id)
    rescue
      flash[:error] = "Invalid organization is selected. Please try again or contact administrator."
      redirect_to root_url
    end
  end

  #Displaying the user details
  def profile
    authorize! :profile, @user
    if current_user.id == @user.id or current_user.current_user_role_name.try(:to_sym) == :admin
      #Address linked to this user
      @address_list = @user.other_addresses
      @primary_address = @user.primary_address
      @primary_contact_number = @user.primary_contact_number
      @contact_number_list = @user.other_contact_numbers
    else
      redirect_to root_url, error: "You are not authorized to access other profile"
    end
  end

  def create
    authorize! :create, User

    @user = User.new user_params
    respond_to do |format|
      # if(session[:is_customer]=="true" ? @user.save(validate: false) : @user.save)
      if @user.save
        # @user.roles << Role.second
        format.html {redirect_to profile_user_url(@user), notice: "Employee is successfully created"}
        session[:is_customer] = nil
      else
        format.html {render :new}
      end
    end
  end
  #Updating the user details
  def update
    authorize! :update, User

    [:user_name_primary_details,:password_security_details, :additional_details].each do |template_param|
      if params[template_param]
        @template_params = template_param.to_s
        if current_user.valid_password?(params[:current_user_password])
          if @user.update_attributes user_params

            @user.update_attributes(current_user_role_id: @user.roles.first.id, current_user_role_name: @user.roles.first.name) if @user.roles.present? and !@user.current_user_role_id.present? and !@user.current_user_role_name.present?#count == 1

            flash[:notice] = "Profile is successfully updated"
            render js: "window.location.href='"+profile_user_url(@user)+"'" and return
            break
          else
            render :initiate_user_profile_edit and return
            break
          end
        else
          flash[:error] = "Please provide your valid password"
          render js: "window.location.href='"+profile_user_url(@user)+"'" and return
          break
        end
      end
    end
  end

  #Functions for ajax
  def initiate_user_profile_edit
    authorize! :initiate_user_profile_edit, User

    Product
    @template_params = params[:template_params]
    case @template_params
    when "addresses_primary_details"
      # @user.addresses.build
    end
    respond_to do |format|
      format.js
    end
  end

  def upload_avatar
    authorize! :upload_avatar, User

    respond_to do |format|
      if @user.update_attributes user_params
        @errors = []
      else
        @errors = @user.errors
      end
      if params[:cropped_image]
        flash[:notice] = "profile image cropped successfully"
        format.js {render js: "window.location.href='"+profile_user_url(@user)+"'"}
      else
        format.js
      end
    end
  end

  def assign_role
    # authorize! :assign_role, User

    respond_to do |format|
      if current_user.role_ids.include?(params[:set_role_id].to_i)#.map{ |role| r.name }.include?(params[:set_role_id])
        role = Role.find params[:set_role_id]
        current_user.update_attributes(current_user_role_id: role.id, current_user_role_name: role.name)
        format.html { redirect_to root_url, notice: "Role #{current_user.current_user_role_name} is successfully set for you."}
      else
        format.html { redirect_to root_url, error: "Please set valid role assigned for you."}
      end
    end
  end

  def individual_customers
    @users = User.select{|user| user.is_customer?}
  end

  def check_user_session
    no_user_session = current_user.nil?
    respond_to do |format|
      format.json {render json: no_user_session}
    end
  end

  def request_user_active
    respond_to do |format|
      format.html
    end
  end

  def accept_user_active

    email_to = params[:email_to].to_s
    cc = email_to.scan(/\bcc:+[a-zA-Z0-9._%+-]+@\w+\.\w{2,}\b/).map{|e| e[3..-1]}
    to = (email_to.scan(/\bto:+[a-zA-Z0-9._%+-]+@\w+\.\w{2,}\b/).map{|e| e[3..-1]}.first or cc.first)

    if params[:send_email].present? and params[:send_email].to_bool
      if to.present?
        view_context.send_email(email_to: to, email_cc: cc, email_code: "USER_ACTIVE")
        @email_response = "Successfully sent email to: #{to}"
      end
    end

    respond_to do |format|
      format.html
    end
  end

  private
    def set_user
      @user =  User.find params[:id]
    end

    def user_params
      params.require(:user).permit(:is_customer, :email, :avatar, :coord_x, :coord_y, :coord_w, :coord_h, :user_name, {role_ids: []}, :organization_id, :designation_id, :department_id, :password, :password_confirmation, :NIC, :epf_no, :date_joined_at, :first_name, :last_name, :title_id, addresses_attributes: [:id, :category, :address, :_destroy])
    end

end