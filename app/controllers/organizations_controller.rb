class OrganizationsController < ApplicationController
  load_and_authorize_resource
  # before_action :authenticate_user!
  before_action :set_organization, only: [:show, :edit, :update, :relate, :remove_relation, :dashboard, :option_for_vat_number, :demote_as_department, :remove_department_org, :pin_relation]

  def index
    ContactNumber
    if params[:search_members]
      @parent_organization = Organization.find params[:parent_organization] if params[:parent_organization].present?
      @organizations = Organization.joins(:organization_type).where("mst_organization_types.id = ? and organizations.name like ? and short_name like ? and organizations.id != ?", params[:type_id], "%#{params[:name]}%", "%#{params[:short_name]}%", params[:parent_organization]).references(:mst_organization_types)

      @organizations = if @parent_organization == Organization.owner
        @organizations.select{|o| !o.account.present? }
      else
        @organizations.select{|o| o.account.present? }
      end
    else
      @dealer_type = DealerType.find_by_code params[:category]
      @accounts = @dealer_type.accounts
    end
  end

  def new
    Rails.cache.delete(:upload_logo)
    @organization = Organization.new
  end

  def temp_save_user_profile_image
    @organization = params[:organization_id].present? ? Organization.find(params[:organization_id]) : Organization.new
    @organization.attributes = organization_params
    Rails.cache.write(:upload_logo, @organization)
    sleep 1
    render json: Rails.cache.fetch(:upload_logo)
  end

  def edit
    Rails.cache.delete(:upload_logo)
    ContactNumber
    Product
    respond_to do |format|
      format.html
    end
  end

  def show
    ContactNumber
    Product
  end

  def create
    @organization = Rails.cache.fetch(:upload_logo){Organization.new organization_params}
    # @organization = Organization.new organization_params
    @organization.attributes = organization_params

    respond_to do |format|
      if @organization.save
        @organization.update created_by: current_user.id
        account = @organization.account
        account.update created_by: current_user.id, active: true
        account.dealer_types << DealerType.find_by_code(params[:category])
        Organization.find(@organization.id).update_index
        Rails.cache.delete(:upload_logo)

        format.html {redirect_to @organization, notice: "#{@organization.category} is successfully created."}
      else
        format.html {render :new}
      end
    end
  end

  def dealer_types
    @organization = Organization.find params[:organization_id]
    account = @organization.account

    dealer_type_ids = params[:dealer_type_ids].to_a

    DealerType.where(id: dealer_type_ids).each do |did|
      account.dealer_types << DealerType.find(did)
    end

    respond_to do |format|
      format.html {redirect_to edit_organization_url(@organization)}
    end
  end
 
  def update
    ContactNumber
    @organization = Rails.cache.fetch(:upload_logo){@organization}
    # @organization = Organization.new organization_params
    @organization.attributes = organization_params

    respond_to do |format|
      if @organization.update_attributes(organization_params)
        Rails.cache.delete(:upload_logo)
        format.html {redirect_to organization_path(@organization), notice: "Organization #{@organization.name} has been updated successfully"}
        format.json { head :no_content } # 204 No Content
      else
        format.html {render :edit}
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  def inline_customer_contact_detail
    @customer = Customer.find params[:customer_id]
    if @customer.update customer_params
      render json: @customer
    else
      render json: @customer.errors.full_messages.join
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
          @organization.account.previous_vat_number = @organization.account.vat_number
          @organization.account.update_attribute(:vat_number, modified_vat_number) if relation_organization.save
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
          @organization.account.previous_vat_number = @organization.account.vat_number
          @organization.account.update_attribute(:vat_number, modified_vat_number) if @organization.save
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
        @organization.account.update_attribute(:vat_number, @organization.department_org.account.vat_number)
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
      format.json {render json: {current_vat_number: @organization.account.vat_number, new_vat_number: selected_organization.account.try(:vat_number), current_organization_name: @organization.name, relation_organization_name: selected_organization.try(:name)}}
    end
  end

  def pin_relation
    @parent_organization = Organization.find_by_id params[:parent_organization]
    case params[:pin_direction]
    when "closed"
      @parent_organization.members << @organization
    when "opened"
      @organization.update parent_organization_id: nil
    else
      flash[:error] = "Something gone wrong. Please try again."
    end
    render :index
  end

  def dashboard
    respond_to do |format|
      format.html
    end
  end

  def create_organization_contact_person
    @organization_contact_person = OrganizationContactPerson.new organization_contact_person_params
    respond_to do |format|
      if @organization_contact_person.save
        if params[:cp_num] == "cp1"
          @organization_contact_person.contact_person_primary_types << ContactPersonPrimaryType.find_by_code("CP1")
        else
          @organization_contact_person.contact_person_primary_types << ContactPersonPrimaryType.find_by_code("CP2")
        end
        format.html {redirect_to organization_url(@organization.id), notice: "Successfully saved"}
      else
        flash[:notice] = "Unsuccessful"
        format.html {redirect_to organization_url(@organization.id)}
      end
    end
  end

  def update_organization_contact_person
    @organization_contact_person = OrganizationContactPerson.find params[:organization_contact_person_id]
    respond_to do |format|
      if @organization_contact_person.update organization_contact_person_params
        format.json { render json: @organization_contact_person }
      else
        format.json { render json: @organization_contact_person.errors }
      end
    end
  end

  private
    def set_organization
      @organization = Organization.find params[:id]
    end

    def organization_params
      params.require(:organization).permit(:title_id, :name, :department_org_id, :category, :description, :logo, :type_id, :web_site, :code, :short_name, addresses_attributes: [:id, :category, :address, :primary, :_destroy],  contact_numbers_attributes: [:id, :category, :value, :_destroy], account_attributes: [:id, :_destroy, :industry_types_id, :credit_allow, :credit_period_day, :goodwill_status, :svat_no, :account_manager_id, :code, :vat_number, :business_registration_no], customers_attributes: [:id, :_destroy, :organization_id, :title_id, :name, :address1, :address2, :address3, :address4, :district_id, contact_type_values_attributes: [:id, :contact_type_id, :value, :_destroy]])
    end

    def organization_contact_person_params
      params.require(:organization_contact_person).permit(:id, :organization_id, :title_id, :name, :email, :mobile, :telephone, :type_id, :note, :designation)
    end
    def customer_params
      params.require(:customer).permit(:id, :_destroy, :organization_id, :title_id, :name, :address1, :address2, :address3, :address4, :district_id, contact_type_values_attributes: [:id, :contact_type_id, :value, :_destroy])
    end
end
