class UsersController < ApplicationController

  def new
    @user = User.new
  end

  #Displaying the user details
  def profile
    #User
    @user = User.find( params[:id] )
    #Address linked to this user
    @address_list = @user.addresses
  end

  #Updating the user details
  def update
    #User to be updated
    @user = User.find( params[:id] )
    
    #Selection of necessary field to be updated, this makes this method reusable
    case params[:user_attrib]
    when "UN"
        @user.update_attribute( :user_name, params[:user_name] )
        update_msg = 'User name'

    when "EM"
        @user.update_attribute( :email, params[:user_email] )
        update_msg = 'User email'

    else
        #redirect_to()
    end

    flash[:notice] = update_msg+' was successfully updated.'
    redirect_to :action => 'profile', :id => @user
  end

  #Functions for ajax
  def getusername
    @user = User.find( params[:id] )
    respond_to do |format|
      format.json { render json: @user }
    end
  end

end