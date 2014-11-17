class DesignationsController < ApplicationController
  before_action :set_designation, only: [:update, :destroy, :make_primary_designation]
  respond_to :html, :xml, :json

  def create
    @designation = Designation.new(designation_params)
    respond_to do |format|
      if @designation.save
        format.html {redirect_to @designation.organization, notice: "designation is successfully created"}
        format.json {render json: @designation}
      else
        flash[:error] = "Something gone error with designation field. #{@designation.errors.full_messages.join(',')}"
        format.html {redirect_to @designation.organization}
        format.json {render json: @designation.errors}
      end
    end
  end

  def update
    @designation.update(designation_params)
    respond_with(@designation)
  end

  def destroy
    @designation.destroy
    # respond_with(@designation)
    respond_to do |format|
      format.html {redirect_to (@designation.c_numberable_type == "User" ? profile_user_path(current_user) : polymorphic_path([@designation.c_numberable])), notice: "Address is successfully deleted."}
    end
  end

  private
    def set_designation
      @designation = Designation.find(params[:id])
    end

    def designation_params
      params.require(:designation).permit(:name, :description, :organization_id)
    end

end
