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
    Product
    @inventory_rack = InventoryRack.new
    @inventory_all_rack = InventoryRack.all
    render "inventories/inventory_location"
  end

  def update_inventory_location
  end

  def inventory_product
    Inventory
    Product
    Currency
    InventorySerialItem
    @inventory_product1 = InventoryProduct.new
    @inventory_product_all = InventoryProduct.all
    render "inventories/inventory_product"
  end

  def update_inventory_product
  end

  def inventory_location_update
    # @product = Product.find(params[:product_id])
    # formatted_product_params = product_params
    # formatted_product_params["pop_note"] = "#{formatted_product_params['pop_note']} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@product.pop_note}" if formatted_product_params["pop_note"].present?
    # @product.update(formatted_product_params)
    # respond_with(@product)
  end

  def inventory_category_update
  end

  def inventory_category
    Inventory
    @inventory_category1_all = InventoryCategory1.all
    @inventory_category1 = InventoryCategory1.new
    render "inventories/inventory_category"
  end

  def update_inventory_category
  end

  def inventory_product_condition
    Inventory
    @inventory_product_condition_all = ProductCondition.all
    @inventory_product_condition = ProductCondition.new
    render "inventories/inventory_product_condition"
  end

  def update_inventory_product_condition
  end

  def inventory_disposal_method
    Inventory
    @inventory_disposal_method = InventoryDisposalMethod.new
    @inventory_disposal_method_all = InventoryDisposalMethod.all
    render "inventories/inventory_disposal_method"
  end

  def update_inventory_disposal_method
  end

  def inventory_reason
    Inventory
    @inventory_reason = InventoryReason.new
    @inventory_reason_all = InventoryReason.all
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

  def inline_update_inventory_location_rack
    Inventory
    @inventory_rack = InventoryRack.find params[:rack_id]
    if @inventory_rack.update inventory_rack_params
      render json: @inventory_rack
    end
  end

  def inline_update
    Inventory
    @inventory_product_form = InventoryProduct.find params[:product_id]
    if @inventory_product_form.update inventory_product_form_params
      render json: @inventory_product_form
    end
  end

  def inline_update_product_info
    Inventory
    Product
    Currency
    @inventory_product1 = InventoryProductInfo.find params[:product_id]
    if @inventory_product1.update inventory_product_info_params
      render json: @inventory_product
    end
  end

  def inline_update_product_condition
    Inventory
    @inventory_product_condition = ProductCondition.find params[:product_condition_id]
    if @inventory_product_condition.update inventory_product_condition_params
      render json: @inventory_product_condition
    end
  end

  def inline_update_disposal_method
    Inventory
    @inventory_disposal_method = InventoryDisposalMethod.find params[:disposal_method]
    if @inventory_disposal_method.update inventory_disposal_method_params
      render json: @inventory_disposal_method
    end
  end

  def inline_update_inventory_reason
    Inventory
    @inventory_reason = InventoryReason.find params[:inventory_reason]
    if @inventory_reason.update inventory_reason_params
      render json: @inventory_reason
    end
  end

  def inline_update_inventory_location_shelf
    Inventory
    @inventory_shelf = InventoryShelf.find params[:shelf_id]
    if @inventory_shelf.update inventory_shelf_params
      render json: @inventory_shelf
    end
  end

  def inline_update_inventory_location_bin
    Inventory
    @inventory_bin = InventoryBin.find params[:bin_id]
    if @inventory_bin.update inventory_bin_params
      render json: @inventory_bin
    end
  end

  def inline_update_inventory_brand
    Inventory
    @inventory_brand = InventoryCategory1.find params[:brand_id]
    if @inventory_brand.update inventory_brand_params
      render json: @inventory_brand
    end
  end

  def inline_update_inventory_product
    Inventory
    @inventory_product = InventoryCategory2.find params[:product_id]
    if @inventory_product.update inventory_product_params
      render json: @inventory_product
    end
  end

  def inline_update_inventory_category
    Inventory
    @inventory_category = InventoryCategory3.find params[:category_id]
    if @inventory_category.update inventory_category_params
      render json: @inventory_category
    end
  end

  def delete_location_rack
    Inventory
    @delete_rack = InventoryRack.find params[:rack_id]
    if @delete_rack.present?
      @delete_rack.delete
    end
    respond_to do |format|
      format.html { redirect_to inventory_location_admins_path }
    end
  end

  def delete_location_shelf
    Inventory
    @delete_shelf = InventoryShelf.find params[:shelf_id]
    if @delete_shelf.present?
      @delete_shelf.delete
    end
    respond_to do |format|
      format.html { redirect_to inventory_location_admins_path }
    end
  end

  def delete_location_bin
    Inventory
    @delete_bin = InventoryBin.find params[:bin_id]
    if @delete_bin.present?
      @delete_bin.delete
    end
    respond_to do |format|
      format.html { redirect_to inventory_location_admins_path }
    end
  end

  def delete_inventory_brand
    Inventory
    @delete_brand = InventoryCategory1.find params[:brand_id]
    if @delete_brand.present?
      @delete_brand.delete
    end
    respond_to do |format|
      format.html { redirect_to inventory_category_admins_path }
    end
  end

  def delete_inventory_product
    Inventory
    @delete_product = InventoryCategory2.find params[:product_id]
    if @delete_product.present?
      @delete_product.delete
    end
    respond_to do |format|
      format.html { redirect_to inventory_category_admins_path }
    end
  end

  def delete_inventory_category
    Inventory
    @delete_category = InventoryCategory3.find params[:category_id]
    if @delete_category.present?
      @delete_category.delete
    end
    respond_to do |format|
      format.html { redirect_to inventory_category_admins_path }
    end
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

  def inventory_product_form_params
    params.require(:inventory_product).permit(:serial_no, :serial_no_order, :legacy_code, :sku, :model_no, :product_no, :spare_part_no, :description, :fifo, :active, :spare_part, :unit_id)
  end

  def inventory_product_info_params
    params.require(:inventory_product_info).permit(:secondary_unit_id, :average_cost, :need_serial, :need_batch, :per_secondery_unit_conversion, :country_id, :manufacture_id, :currency_id, :standard_cost,:average_cost)
  end

  def inventory_product_condition_params
    params.require(:product_condition).permit(:condition)
  end

  def inventory_disposal_method_params 
    params.require(:inventory_disposal_method).permit(:disposal_method)
  end

  def inventory_reason_params
    params.require(:inventory_disposal_method).permit(:disposal_method)
  end

  def inventory_rack_params
    params.require(:inventory_rack).permit(:description, :location_id)
  end

  def inventory_shelf_params
    params.require(:inventory_shelf).permit(:description)
  end

  def inventory_bin_params
    params.require(:inventory_bin).permit(:description)
  end

  def inventory_brand_params
    params.require(:inventory_category1).permit(:code, :name)
  end

  def inventory_product_params
    params.require(:inventory_category2).permit(:code, :name)
  end

  def inventory_category_params
    params.require(:inventory_category3).permit(:code, :name)
  end

end
