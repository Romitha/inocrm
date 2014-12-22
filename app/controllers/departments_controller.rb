class DepartmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_department, only: [:update, :destroy]
  respond_to :html, :xml, :json

  def create
    @department = Department.new(department_params)
    respond_to do |format|
      if @department.save
        format.html {redirect_to edit_organization_url(@department.organization), notice: "department is successfully created. Please click departments bottom to view #{@department.name}"}
        format.json {render json: @department}
      else
        flash[:error] = "Something gone error with department field. #{@department.errors.full_messages.join(',')}"
        format.html {redirect_to edit_organization_url(@department.organization)}
        format.json {render json: @department.errors}
      end
    end
  end

  def update
    @department.update(department_params)
    respond_with(@department)
  end

  def destroy
    @department.destroy
    # respond_with(@department)
    respond_to do |format|
      format.html {redirect_to @department.organization, notice: "Address is successfully deleted."}
    end
  end

  private
    def set_department
      @department = Department.find(params[:id])
    end

    def department_params
      params.require(:department).permit(:name, :description, :organization_id)
    end

end
