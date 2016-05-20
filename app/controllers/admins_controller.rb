class AdminsController < ApplicationController

  layout "admins"

  def index
  	@tickets = Ticket.order("created_at DESC")
    @products = Product.all
    @ProductBrands = ProductBrand.all
    @TicketTypes = TicketType.all
    @JobTypes = JobType.all
    @Warranties = Warranty.all
    @WarrantyTypes = WarrantyType.all
  end

  def total_tickets
    Ticket
    @ticket_statuses = TicketStatus.all
  end

  def today_open_tickets
  	@tickets = Ticket.order("created_at DESC")
  end

  def today_closed_tickets
  	@tickets = Ticket.order("created_at DESC")
  end

  def open_tickets
  	@tickets = Ticket.order("created_at DESC")
  end

  def closed_tickets
    @tickets = Ticket.order("created_at DESC")
  end

  def total_products
    @products = Product.all
  end

  # GET, POST
  def inventory_product
    Inventory
    Product
    Currency
    InventorySerialItem
    if params[:create]
      @inventory_product = InventoryProduct.new inventory_product_params
      if @inventory_product.save

        params[:create] = nil
        @inventory_product = InventoryProduct.new
        @inventory_product.build_inventory_product_info
      end
    else
      @inventory_product = InventoryProduct.new
      @inventory_product.build_inventory_product_info
    end

    @inventory_product_all = InventoryProduct.order(created_at: :desc).select{|i| i.persisted? }
    render "inventories/inventory_product"
  end

  # POST
  def update_inventory_product
    Inventory
    Product
    Currency
    InventorySerialItem
    @inventory_product = InventoryProduct.new inventory_product_params
    if @inventory_product.save
      @inventory_product = InventoryProduct.new
      @inventory_product.build_inventory_product_info

    end

    @inventory_product_all = InventoryProduct.all.select{|i| i.persisted? }
    render "inventories/inventory_product"
  end

  def inventory_reason
    Inventory
    @inventory_reason = InventoryReason.new
    @inventory_reason_all = InventoryReason.all
    render "inventories/inventory_reason"
  end

  def update_inventory_reason
    Inventory
    @inventory_reason = InventoryReason.new inventory_reason_params
    if @inventory_reason.save
      @inventory_reason = InventoryReason.new
    end

    @inventory_reason_all = InventoryReason.order(created_at: :desc).select{|i| i.persisted? }
    render "inventories/inventory_reason"
  end

  def organizations

  end

  def about_us

  end

  def brands_and_categories
    Product
    ProductCategory
    @product_brands = ProductBrand.all
    if params[:status_param] == "create"
      @brand = ProductBrand.new(brands_and_categories_params)
      if @brand.save
        @brand = ProductBrand.new
        params[:status_param] = nil
      end
    else
      @brand = ProductBrand.new
    end
  end

  def problem_category
    Ticket
    ProblemCategory
    Warranty
    if params[:status_param] == "create"
      @new_problem_category = ProblemCategory.new problem_category_params

      if @new_problem_category.save
        @new_problem_category = ProblemCategory.new
        params[:status_param] = nil
      end
    else
      @new_problem_category = ProblemCategory.new
    end

    @p_q_and_a = QAndA.includes(:task_action)
    @g_q_and_a = GeQAndA.all

  end

  def q_and_a

  end

  def employees
    @users = User.all
  end

  def pop_status
    Product
    @pop_status = ProductPopStatus.new
    render "admins/master_data/pop_status"
  end

  def delete_inventory_product_form
    Inventory
    @delete_product_form = InventoryProduct.find params[:product_id]
    if @delete_product_form.present?
      @delete_product_form.delete
    end
    respond_to do |format|
      format.html { redirect_to inventory_product_admins_path }
    end
  end

  def delete_admin_sbu_engineer
    User
    @sbu_engineer = SbuEngineer.find params[:sbu_engineer_id]
    if @sbu_engineer.present?
      @sbu_engineer.delete
    end
    respond_to do |format|
      format.html { redirect_to sbu_admins_path }
    end
  end

  def delete_admin_ticket_start_action
    Ticket
    @sp_description = SparePartDescription.find params[:sp_description_id]
    if @sp_description_id.present?
      @sp_description_id.delete
    end
    respond_to do |format|
      format.html { redirect_to spare_part_description_admins_path }
    end
  end

  def update_pop_status
  end

  private

    def brands_and_categories_params
      params.require(:product_brand).permit(:organization_id, :currency_id, :name, :sla_id, :parts_return_days, :warranty_date_format, product_categories_attributes: [:name, :sla_id, :_destroy, :id])
    end

    def problem_category_params
      params.require(:problem_category).permit(:name, q_and_as_attributes: [:_destroy, :id, :active, :answer_type, :question, :action_id, :compulsory])
    end

end
