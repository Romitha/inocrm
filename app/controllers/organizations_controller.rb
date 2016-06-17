class OrganizationsController < ApplicationController
  load_and_authorize_resource
  # before_action :authenticate_user!
  before_action :set_organization, only: [:show, :edit, :update, :relate, :remove_relation, :dashboard, :option_for_vat_number, :demote_as_department, :remove_department_org]

  def index
    @dealer_type = DealerType.find_by_code params[:category]
    @accounts = @dealer_type.accounts
  end

  def new
    @organization = Organization.new
  end

  def edit
    Product
    respond_to do |format|
      format.html
    end
  end

  def show
    Product
  end

  def create
    @organization = Organization.new organization_params

    respond_to do |format|
      if @organization.save
        @organization.update created_by: current_user.id
        account = @organization.account
        account.update created_by: current_user.id, active: true
        account.dealer_types << DealerType.find_by_code(params[:category])

        format.html {redirect_to @organization, notice: "#{@organization.category} is successfully created."}
      else
        format.html {render :new}
      end
    end
  end

  def update
    respond_to do |format|
      if @organization.update_attributes(organization_params)
        format.html {redirect_to root_url, notice: "Organization #{@organization.name} has been updated successfully"}
        format.json { head :no_content } # 204 No Content
      else
        format.html {render :edit}
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  def relate
    relation_organization = Organization.find_by_id params[:relate_id]
    to_url = organization_url(@organization)
    modified_vat_number = params[:modified_vat_number]
    case params[:relate]
      when "member"
        if relation_organization.try(:parent_organization)
          flash[:error] = "Parent #{relation_organization.parent_organization.name} is assigned. Please remove relationship and continue again."
          to_url = organization_url(relation_organization)
        elsif @organization.try(:parent_organization) == relation_organization
            flash[:error] = "#{relation_organization.name} is parent. Please remove relationship and continue again."
            to_url = organization_url(relation_organization)
        else
          relation_organization.parent_organization = @organization
          @organization.previous_vat_number = @organization.vat_number
          @organization.update_attribute(:vat_number, modified_vat_number) if relation_organization.save
          flash[:notice] = "Member is added successfully"
        end
      when "parent"
        if @organization.try(:parent_organization)
          flash[:error] = "Parent #{@organization.parent_organization.name} is assigned. Please remove relationship and continue again."
          to_url = organization_url(@organization.parent_organization)
        elsif relation_organization.try(:parent_organization) == @organization
          flash[:error] = "Parent #{@organization.name} is assigned. Please remove relationship and continue again."
        else
          @organization.parent_organization = Organization.find_by_id params[:relate_id]
          @organization..previous_vat_number = @organization.vat_number
          @organization.update_attribute(:vat_number, modified_vat_number) if @organization.save
          flash[:notice] = "parent is added successfully"
        end
      else
        flash[:error] = "Please assign relationship and organization"
      end
      redirect_to to_url
  end

  def demote_as_department
    demote_params = params.require(:organization).permit(:department_org_id, :name)
    respond_to do |format|
      notice = "Please correct the problem and re-try."
      if @organization.update_attributes(demote_params)
        @organization.update_attribute(:vat_number, @organization.department_org.vat_number)
        notice = "successfully demoted as department"
      end
      format.html {redirect_to @organization, notice: notice}
    end
  end

  def remove_department_org
    @organization.update_attribute :department_org_id, nil
    respond_to do |format|
      format.html {redirect_to @organization, notice: "Promoted as Organization from department"}
    end
  end

  def option_for_vat_number
    selected_organization = Organization.find_by_id params[:selected_organization_id]
    respond_to do |format|
      format.json {render json: {current_vat_number: @organization.vat_number, new_vat_number: selected_organization.try(:vat_number), current_organization_name: @organization.name, relation_organization_name: selected_organization.try(:name)}}
    end
  end

  def remove_relation
    relation_organization = Organization.find_by_id params[:relation_organization]

    case params[:relation]
    when "Parent"
      relation_organization.parent_organization = nil
      relation_organization.save
      flash[:notice] = "Parent relationship is removed successfully"
    when "Member"
      @organization.parent_organization = nil
      @organization.save
      flash[:notice] = "Member relationship is removed successfully"
    else
      flash[:error] = "Something gone wrong. Please try again."
    end
    redirect_to @organization
  end

  def dashboard
    respond_to do |format|
      format.html
    end
  end

  private
    def set_organization
      @organization = Organization.find params[:id]
    end

    def organization_params
      params.require(:organization).permit(:name, :department_org_id, :category, :description, :logo, :vat_number, :type_id, :web_site, :code, :short_name, addresses_attributes: [:id, :category, :address, :primary, :_destroy],  contact_numbers_attributes: [:id, :category, :value, :_destroy], account_attributes: [:id, :_destroy, :industry_types_id])
    end
end
