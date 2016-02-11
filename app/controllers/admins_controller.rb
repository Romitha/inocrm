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

  def inventory_location
    Inventory
    @inventory_rack = InventoryRack.new
    render "inventories/inventory_location"
  end

  def update_inventory_location
  end

  def inventory_product
    Inventory
    Product
    InventorySerialItem
    @inventory_product = InventoryProduct.new
    render "inventories/inventory_product"
  end

  def update_inventory_product
  end

  def inventory_category
    Inventory
    @inventory_category1 = InventoryCategory1.new
    render "inventories/inventory_category"
  end

  def update_inventory_category
  end

  def inventory_product_condition
    Inventory
    @inventory_product_condition = ProductCondition.new
    render "inventories/inventory_product_condition"
  end

  def update_inventory_product_condition
  end

  def inventory_disposal_method
    Inventory
    @inventory_disposal_method = InventoryDisposalMethod.new
    render "inventories/inventory_disposal_method"
  end

  def update_inventory_disposal_method
  end

  def inventory_reason
    Inventory
    @inventory_reason = InventoryReason.new
    render "inventories/inventory_reason"
  end

  def update_inventory_reason
  end

  def inventory_manufacture
    Inventory
    @inventory_manufacture = Manufacture.new
    render "inventories/inventory_manufacture"
  end

  def update_inventory_manufacture

  end

  def inventory_unit
    Inventory
    @inventory_unit = InventoryUnit.new
    render "inventories/inventory_unit"
  end

  def update_inventory_unit
  end

  def reason
    Ticket
    @reason = Reason.new
    render "admins/master_data/reason"
  end

  def update_reason

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
    # Ticket
    # ProblemCategory
    # Warranty
    # if params[:status_param] == "create"
    #   @new_problem_category = ProblemCategory.new problem_category_params

    #   if @new_problem_category.save
    #     @new_problem_category = ProblemCategory.new
    #     params[:status_param] = nil
    #   end

    # else
    #   @new_problem_category = ProblemCategory.new
    # end

  end

  def employees
    @users = User.all
  end

  def accessories
    Product
    @accessory = Accessory.new
    render "admins/master_data/accessories"
  end

  def update_accessories
  end

  def country
    Product
    @country = ProductSoldCountry.new
    render "admins/master_data/country"
  end

  def update_country
  end

  def additional_charge
    TicketEstimation
    @additional_charge = AdditionalCharge.new
    render "admins/master_data/additional_charge"
  end

  def update_additional_charge
  end

  def customer_feedback
    User
    @customer_feedback = Feedback.new
    render "admins/master_data/customer_feedback"
  end

  def update_customer_feedback
  end

  def general_question
    QAndA
    @general_question = GeQAndA.new
    render "admins/master_data/general_question"
  end

  def update_general_question

  end

  def payment_item
    TaskAction
    @payment_item = PaymentItem.new
    render "admins/master_data/payment_item"
  end

  def update_payment_item
  end

  def sbu
    User
    @sbu = Sbu.new
    # @sbu_eng = SbuEngineer.new
    render "admins/master_data/sbu"

  end

  def update_sbu
  end

  def regional_support_center
    TaskAction
    User
    Organization
    @regional_support_center = RegionalSupportCenter.new
    render "admins/master_data/regional_support_center"
  end

  def update_regional_support_center

  end

  def spare_part_description
    TicketSparePart
    @spare_part_description = SparePartDescription.new
    render "admins/master_data/spare_part_description"

  end

  def update_spare_part_description

  end

  def ticket_start_action
    Ticket
    @ticket_start_action = TicketStartAction.new
    render "admins/master_data/ticket_start_action"
  end

  def update_ticket_start_action

  end

  def sla
    SlaTime
    @sla = SlaTime.new
    render "admins/master_data/sla"
  end

  def update_sla
  end

  def title
    User
    @title = MstTitle.new
    render "admins/master_data/title"
  end

  def update_title
  end

  def pop_status
    Product
    @pop_status = ProductPopStatus.new
    render "admins/master_data/pop_status"
  end

  def update_pop_status
  end

  def brands_and_categories_params
    params.require(:product_brand).permit(:name, :sla_id, :parts_return_days, :warranty_date_format, :currency_id, product_categories_attributes: [:name, :sla_id, :_destroy, :id])
  end

  def brands_and_categories_params
    params.require(:product_brand).permit(:name, :sla_id, :parts_return_days, :warranty_date_format, :currency_id, product_categories_attributes: [:name, :sla_id, :_destroy, :id])
  end

  def problem_category_params
    params.require(:problem_category).permit(:name, q_and_as_attributes: [:_destroy, :id, :active, :answer_type, :question, :action_id, :compulsory])
  end

  def sbu_params
    params.require(:sbu).permit(:sbu, sbu_engineers_attributes: [:_destroy, :id, :sbu_id, :engineer_id])
  end

end
