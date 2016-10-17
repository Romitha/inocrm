class RolesAndPermissionsController < ApplicationController


  before_action :set_organization, only: [:new, :create, :edit, :load_permissions, :update]

  def new
    # @rpermissions = Rpermission.all.map { |rpermission| {resource: rpermission.controller_resource, name: rpermission.name, id: rpermission.id, checked: false} }
    @rpermissions = [] #Rpermission.all.group_by{|g| g.controller_resource}.map{|k, v| {resource: k, value: v.map{|rpermission| {resource: rpermission.controller_resource, name: rpermission.name, id: rpermission.id, checked: false}}}}
    respond_to do |format|
      format.html
    end
  end

  def load_permissions
    @role = Role.find params[:role_id]
    # @rpermissions = Rpermission.all.map { |rpermission| {resource: rpermission.controller_resource, name: rpermission.name, id: rpermission.id, checked: "#{'checked' if @role.rpermissions.include?(rpermission)}"} }
    @rpermissions = [] #Rpermission.all.group_by{|g| g.controller_resource}.map{|k, v| {resource: k, value: v.map{|rpermission| {resource: rpermission.controller_resource, name: rpermission.name, id: rpermission.id, checked: "#{'checked' if @role.rpermissions.include?(rpermission)}"}}}}
    respond_to do |format|
      format.json
      format.html
    end
  end

  def create
    new_role_name = params[:role][:name]
    rpermission_ids = params[:rpermissions]
    @bpm_role = BpmModuleRole.find params[:bpm_role] if params[:bpm_role].present?
    @role = @organization.roles.build(name: new_role_name)
    if @role.save
      @role.rpermission_ids = rpermission_ids
      @role.bpm_module_roles << @bpm_role if @bpm_role.present?

      flash[:notice] = "Roles and Permissions are successfully assigned"
      redirect_to new_organization_roles_and_permission_url(@organization)
    else
      flash[:error] = "Roles and Permissions are not successfully assigned. Please correct those errors and try again"
      # redirect_to new_organization_roles_and_permission_url(@organization)
      render :new
    end
  end

  def edit
    @role = Role.find params[:id]
    # @rpermissions = Rpermission.all.map { |rpermission| {resource: rpermission.controller_resource, name: rpermission.name, id: rpermission.id, checked: "#{'checked' if @role.rpermissions.include?(rpermission)}"} }
    @rpermissions = [] #Rpermission.all.group_by{|g| g.controller_resource}.map{|k, v| {resource: k, value: v.map{|rpermission| {resource: rpermission.controller_resource, name: rpermission.name, id: rpermission.id, checked: "#{'checked' if @role.rpermissions.include?(rpermission)}"}}}}
    
  end

  def update
    @role = Role.find params[:id]
    rpermission_ids = params[:rpermissions]
    if @role.update_attribute(:name, params[:role][:name])
      @role.rpermission_ids = rpermission_ids
      redirect_to edit_organization_roles_and_permission_url(@organization, @role), notice: "Roles and Permissions are successfully updated."
    else
      redirect_to edit_organization_roles_and_permission_url(@organization, @role), error: "Roles and Permissions are unsuccessfully updated. Please try again."
    end
  end

  def assign_bpm_role
    organization = Organization.find params[:organization_id]
    @system_role = Role.find params[:system_role] if params[:system_role].present?
    @bpm_role = BpmModuleRole.find params[:bpm_role] if params[:bpm_role].present?

    respond_to do |format|
      if @system_role and @bpm_role and @system_role.bpm_module_roles.blank?
        @system_role.bpm_module_roles << @bpm_role
        flash[:notice] = "Bpm role is successfully assigned."
      else
        flash[:error] = "Bpm role is already assigned. or Please select both system role and bpm role and try again."
      end
      format.html { redirect_to new_organization_roles_and_permission_url(organization)}
    end
  end

  private
    def set_organization
      @organization = Organization.find params[:organization_id]
    end
end
