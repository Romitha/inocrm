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
    Inventory
    Product
    @inventory_all_rack = InventoryRack.all
    @inventory_rack = InventoryRack.new inventory_rack_params
    @inventory_rack.save
    render "inventories/inventory_location"
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
    # Inventory
    # Product
    # @inventory_product_all = InventoryProduct.all
    # @inventory_product1 = InventoryRack.new inventory_product_form_params
    # @inventory_product1.save
    # render "inventories/inventory_product"
  end

  def inventory_location_update
    # @product = Product.find(params[:product_id])
    # formatted_product_params = product_params
    # formatted_product_params["pop_note"] = "#{formatted_product_params['pop_note']} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@product.pop_note}" if formatted_product_params["pop_note"].present?
    # @product.update(formatted_product_params)
    # respond_with(@product)
  end

  # def inventory_category_update

  # end

  def inventory_category
    Inventory
    @inventory_category1_all = InventoryCategory1.all
    @inventory_category1 = InventoryCategory1.new
    render "inventories/inventory_category"
  end

  def update_inventory_category
    Inventory
    @inventory_category1_all = InventoryCategory1.all
    @inventory_category1 = InventoryCategory1.new inventory_brand_params
    @inventory_category1.save
    render "inventories/inventory_category"
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
    @inventory_manufacture_all = Manufacture.all
    render "inventories/inventory_manufacture"
  end

  def update_inventory_manufacture

  end

  def inventory_unit
    Inventory
    @inventory_unit = InventoryUnit.new
    @inventory_unit_all = InventoryUnit.all
    render "inventories/inventory_unit"
  end

  def update_inventory_unit
  end

  def reason
    Ticket
    @reason = Reason.new
    @reason_all = Reason.all
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
    Ticket
    @accessory = Accessory.new
    @accessory_all = Accessory.all
    render "admins/master_data/accessories"
  end

  def update_accessories
    Product
    Ticket
    @accessory_all = Accessory.all
    @accessory = Accessory.new admin_accessory_params
    @accessory.save
    render "admins/master_data/accessories"
    # @r = Re.new reason_params
    # @r.save
    #   # @r.errors.full_messages.each do |error|
    #   #   error.error
    #   # end
  end

  def country
    Product
    @country = ProductSoldCountry.new
    @country_all = ProductSoldCountry.all
    render "admins/master_data/country"
  end

  def update_country
  end

  def additional_charge
    TicketEstimation
    @additional_charge = AdditionalCharge.new
    @additional_charge_all = AdditionalCharge.all
    render "admins/master_data/additional_charge"
  end

  def update_additional_charge
    TicketEstimation
    @add_charge = AdditionalCharge.new admin_add_charge_params
    if @add_charge.save
      respond_to do |format|
        format.html { redirect_to additional_charge_admins_path }
      end
    else
      @add_charge.errors.full_messages.each do |error|
        error.error
      end
    end
  end

  def customer_feedback
    User
    @customer_feedback = Feedback.new
    @customer_feedback_all = Feedback.all
    render "admins/master_data/customer_feedback"
  end

  def update_customer_feedback
  end

  def general_question
    QAndA
    @general_question = GeQAndA.new
    @general_question_all = GeQAndA.all
    render "admins/master_data/general_question"
  end

  def update_general_question

  end

  def payment_item
    TaskAction
    @payment_item = PaymentItem.new
    @payment_item_all = PaymentItem.all
    render "admins/master_data/payment_item"
  end

  def update_payment_item
  end

  def sbu
    User
    @sbu = Sbu.new
    @sbu_all = Sbu.all
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
    @regional_support_center_all = RegionalSupportCenter.all
    render "admins/master_data/regional_support_center"
  end

  def update_regional_support_center

  end

  def spare_part_description
    TicketSparePart
    @spare_part_description = SparePartDescription.new
    @spare_part_description_all = SparePartDescription.all
    render "admins/master_data/spare_part_description"

  end

  def update_spare_part_description

  end

  def ticket_start_action
    Ticket
    @ticket_start_action = TicketStartAction.new
    @ticket_start_action_all = TicketStartAction.all
    render "admins/master_data/ticket_start_action"
  end

  def update_ticket_start_action

  end

  def sla
    SlaTime
    @sla = SlaTime.new
    @sla_all = SlaTime.all
    render "admins/master_data/sla"
  end

  def problem_and_category
    Ticket
    TaskAction
    @problem_category = QAndA.new
    @problem_category_all = QAndA.all
    render "admins/master_data/problem_and_category"
  end

  def brands_and_category
    Product
    SlaTime
    Organization
    Currency
    @brands_and_category = ProductBrand.new
    @brands_and_category_all = ProductBrand.all
    render "admins/master_data/brands_and_category"
  end

  def update_sla
  end

  def update_problem_and_category
  end

  def update_brands_and_category
  end

  def title
    User
    @title = MstTitle.new
    @title_all = MstTitle.all
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

  def inline_update_inventory_manufacture
    Inventory
    @inventory_manufacture = Manufacture.find params[:manufacture_id]
    if @inventory_manufacture.update inventory_manufacture_params
      render json: @inventory_manufacture
    end
  end

  def inline_update_inventory_unit
    Inventory
    @inventory_unit = InventoryUnit.find params[:unit_id]
    if @inventory_unit.update inventory_unit_params
      render json: @inventory_unit
    end
  end

  def inline_update_admin_reason
    Ticket
    @mst_reason = Reason.find params[:mst_reason_id]
    if @mst_reason.update admin_reason_params
      render json: @mst_reason
    end
  end

  def inline_update_admin_country
    Ticket
    @admin_country = ProductSoldCountry.find params[:country_id]
    if @admin_country.update admin_country_params
      render json: @admin_country
    end
  end

  def inline_update_admin_accessory
    Product
    Ticket
    @admin_accessory = Accessory.find params[:accessory_id]
    if @admin_accessory.update admin_accessory_params
      render json: @admin_accessory
    end
  end

  def inline_update_admin_additional_charge
    TicketEstimation
    @add_charge = AdditionalCharge.find params[:add_charge_id]
    if @add_charge.update admin_add_charge_params
      render json: @add_charge
    end
  end

  def inline_update_admin_customer_feedback
    User
    @ad_feedback = Feedback.find params[:customer_feedback_id]
    if @ad_feedback.update admin_ad_feedback_params
      render json: @ad_feedback
    end
  end

  def inline_update_admin_general_question
    QAndA
    @g_question = GeQAndA.find params[:g_question_id]
    if @g_question.update admin_general_question_params
      render json: @g_question
    end
  end

  def inline_update_admin_payment_item
    TaskAction
    @payment_item = PaymentItem.find params[:payment_item_id]
    if @payment_item.update admin_payment_item_params
      render json: @payment_item
    end 
  end

  def inline_update_admin_sbu
    User
    @sbu = Sbu.find params[:sbu_id]
    if @sbu.update sbu_params
      render json: @sbu
    end
  end

  def inline_update_sbu_regional_engineer
    User
    @sburegional_engineer = SbuRegionalEngineer.find params[:sbu_regional_engineer_id]
    if @sburegional_engineer.update sburegional_engineer_params
      render json: @sburegional_engineer
    end
  end

  def inline_update_admin_regional_support_center
    TaskAction
    @regional_support_center = RegionalSupportCenter.find params[:regional_support_center_id]
    if @regional_support_center.update regional_support_center_params
      render json: @regional_support_center
    end
  end

  def inline_update_admin_spare_part_description
    TicketSparePart
    @sp_description = SparePartDescription.find params[:sp_description_id]
    if @sp_description.update sp_description_params
      render json: @sp_description
    end
  end

  def inline_update_admin_ticket_start_action
    Ticket
    @ticket_start_action = TicketStartAction.find params[:ticket_start_action_id]
    if @ticket_start_action.update ticket_start_action_params
      render json: @ticket_start_action
    end
  end

  def inline_update_admin_title
    User
    @title = MstTitle.find params[:title_id]
    if @title.update title_params
      render json: @title
    end
  end

  def inline_update_admin_sla
    @sla = SlaTime.find params[:sla_id]
    if @sla.update sla_params
      render json: @sla
    end
  end

  def inline_update_brands_and_category
    Product
    @brands_and_category = ProductBrand.find params[:brands_and_category_id]
    if @brands_and_category.update brands_and_category_params
      render json: @brands_and_category
    end
  end

  def inline_update_product_category
    Product
    @product_category = ProductCategory.find params[:product_category_id]
    if @product_category.update product_category_params
      render json: @product_category
    end
  end

  def inline_update_problem_and_category
    Product
    @problem_and_category = QAndA.find params[:problem_and_category_id]
    if @problem_and_category.update problem_and_category_params
      render json: @problem_and_category
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


  def delete_admin_additional_charge
    TicketEstimation
    @add_charge = AdditionalCharge.find params[:add_charge_id]
    if @add_charge.present?
      @add_charge.delete
    end
    respond_to do |format|
      format.html { redirect_to additional_charge_admins_path }
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

  def delete_inventory_manufacture
    Inventory
    @delete_manufacture = InventoryManufacture.find params[:manufacture_id]
    if @delete_manufacture.present?
      @delete_manufacture.delete
    end
    respond_to do |format|
      format.html { redirect_to inventory_manufacture_admins_path }
    end
  end




  def delete_product_condition
    Inventory
    @inventory_product_condition = ProductCondition.find params[:product_condition_id]
    if @inventory_product_condition.present?
      @inventory_product_condition.delete
    end
    respond_to do |format|
      format.html { redirect_to inventory_product_condition_admins_path }
    end
  end

  def delete_disposal_method
    Inventory
    @inventory_disposal_method = InventoryDisposalMethod.find params[:disposal_id]
    if @inventory_disposal_method.present?
      @inventory_disposal_method.delete
    end
    respond_to do |format|
      format.html { redirect_to inventory_disposal_method_admins_path }
    end
  end

  def delete_inventory_unit
    Inventory
    @inventory_unit = InventoryUnit.find params[:unit_id]
    if @inventory_unit.present?
      @inventory_unit.delete
    end
    respond_to do |format|
      format.html { redirect_to inventory_unit_admins_path }
    end
  end

  def delete_admin_reason
    Ticket
    @inventory_unit = Reason.find params[:mst_reason_id]
    if @inventory_unit.present?
      @inventory_unit.delete
    end
    respond_to do |format|
      format.html { redirect_to reason_admins_path }
    end
  end

  def delete_admin_country
    Ticket
    @admin_country = ProductSoldCountry.find params[:country_id]
    if @admin_country.present?
      @admin_country.delete
    end
    respond_to do |format|
      format.html { redirect_to country_admins_path }
    end
  end

  def delete_admin_accessory
    Ticket
    Product
    @admin_accessory = Accessory.find params[:accessory_id]
    if @admin_accessory.present?
      @admin_accessory.delete
    end
    respond_to do |format|
      format.html { redirect_to accessories_admins_path }
    end
  end

  def delete_admin_customer_feedback
    User
    @customer_feedback = Feedback.find params[:customer_feedback_id]
    if @customer_feedback.present?
      @customer_feedback.delete
    end
    respond_to do |format|
      format.html { redirect_to customer_feedback_admins_path }
    end

  end
  
  def delete_admin_general_question
    QAndA
    @g_question = GeQAndA.find params[:g_question_id]
    if @g_question.present?
      @g_question.delete
    end
    respond_to do |format|
      format.html { redirect_to general_question_admins_path }
    end
  end

  def delete_admin_payment_item
    TaskAction
    @payment_itemn = PaymentItem.find params[:payment_item_id]
    if @payment_itemn.present?
      @payment_itemn.delete
    end
    respond_to do |format|
      format.html { redirect_to payment_item_admins_path }
    end
  end

  def delete_admin_sbu
    User
    @sbu = Sbu.find params[:sbu_id]
    if @sbu.present?
      @sbu.delete
    end
    respond_to do |format|
      format.html { redirect_to sbu_admins_path }
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

  def delete_admin_regional_support_center
    User
    @rs_center = RegionalSupportCenter.find params[:regional_support_center_id]
    if @rs_center.present?
      @rs_center.delete
    end
    respond_to do |format|
      format.html { redirect_to regional_support_center_admins_path }
    end
  end

  def delete_sbu_regional_engineer
    User
    @rs_engineer = SbuRegionalEngineer.find params[:sbu_regional_engineer_id]
    if @rs_engineer.present?
      @rs_engineer.delete
    end
    respond_to do |format|
      format.html { redirect_to regional_support_center_admins_path }
    end
  end

  def delete_admin_spare_part_description
    TicketSparePart
    @ticket_start_action = TicketStartAction.find params[:ticket_start_action_id]
    if @ticket_start_action_id.present?
      @ticket_start_action_id.delete
    end
    respond_to do |format|
      format.html { redirect_to ticket_start_action_admins_path }
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

  def delete_admin_title
    User
    @title = MstTitle.find params[:title_id]
    if @title.present?
      @title.delete
    end
    respond_to do |format|
      format.html { redirect_to title_admins_path }
    end
  end

  def delete_admin_sla
    SlaTime
    @sla = SlaTime.find params[:sla_id]
    if @sla.present?
      @sla.delete
    end
    respond_to do |format|
      format.html { redirect_to sla_admins_path }
    end
  end

  def delete_admin_brands_and_category
    Product
    @brands_and_category = ProductBrand.find params[:brands_and_category_id]
    if @brands_and_category.present?
      @brands_and_category.delete
    end
    respond_to do |format|
      format.html { redirect_to brands_and_category_admins_path }
    end
  end

  def delete_product_category
    Product
    @product_category = ProductCategory.find params[:product_category_id]
    if @product_category.present?
      @product_category.delete
    end
    respond_to do |format|
      format.html { redirect_to brands_and_category_admins_path }
    end
  end

  def delete_admin_problem_category
    @problem_and_category = QAndA.find params[:problem_and_category_id]
    if @problem_and_category.present?
      @problem_and_category.delete
    end
    respond_to do |format|
      format.html { redirect_to problem_and_category_admins_path }
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
    params.require(:inventory_product).permit(:serial_no, :serial_no_order, :sku, :legacy_code, :description, :model_no, :product_no, :spare_part_no, :fifo, :active, :spare_part, :unit_id, inventory_product_info_attributes: [:picture, :secondary_unit_id, :issue_fractional_allowed, :per_secondery_unit_conversion, :need_serial, :need_batch, :country_id, :manufacture_id, :average_cost, :standard_cost, :currency_id])
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
    params.require(:inventory_reason).permit(:reason, :srn_issue_terminate, :damage, :srr, :disposal)
  end

  def inventory_rack_params
    params.require(:inventory_rack).permit(:description, :location_id, :aisle_image, :created_by, :updated_by,inventory_shelfs_attributes: [:_destroy, :id, :description, :created_by, :updated_by, inventory_bins_attributes: [:_destroy, :id, :description, :created_by, :updated_by]])
  end

  def inventory_shelf_params
    params.require(:inventory_shelf).permit(:description)
  end

  def inventory_bin_params
    params.require(:inventory_bin).permit(:description)
  end

  def inventory_brand_params
    params.require(:inventory_category1).permit(:code, :name, :created_by, :created_by, inventory_category2s_attributes: [:_destroy, :id, :code, :name, :created_by, :updated_by, inventory_category3s_attributes: [:_destroy, :id, :code, :name, :created_by, :updated_by] ])
  end

  def inventory_product_params
    params.require(:inventory_category2).permit(:code, :name)
  end

  def inventory_category_params
    params.require(:inventory_category3).permit(:code, :name)
  end

  def inventory_manufacture_params
    params.require(:manufacture).permit(:manufacture)
  end

  def inventory_unit_params
    params.require(:inventory_unit).permit(:unit, :base_unit_id, :base_unit_conversion, :per_base_unit, :description)
  end

  def admin_reason_params
    params.require(:reason).permit(:hold, :sla_pause, :re_assign_request, :terminate_job, :terminate_spare_part, :warranty_extend, :spare_part_unused, :reject_returned_part, :reject_close, :adjust_terminate_job_payment, :reason)
  end

  def admin_country_params
    params.require(:product_sold_country).permit(:Country, :code)
  end

  def admin_accessory_params
    params.require(:accessory).permit(:accessory)
  end

  def admin_add_charge_params
    params.require(:additional_charge).permit(:additional_charge, :default_cost_price, :default_estimated_price)
  end

  def admin_ad_feedback_params
    params.require(:feedback).permit(:feedback)
  end

  def admin_general_question_params
    params.require(:ge_q_and_a).permit(:question, :answer_type, :active, :compulsory, :action_id)
  end

  def admin_payment_item_params
    params.require(:payment_item).permit(:name, :default_amount)
  end

  def regional_support_center_params
    params.require(:regional_support_center).permit(:organization_id, :active, sbu_regional_engineers_attributes: [:engineer_id])
  end

  def sburegional_engineer_params
    params.require(:sbu_regional_engineer).permit(:engineer_id)
  end

  def sp_description_params
    params.require(:spare_part_description).permit(:description)
  end

  def ticket_start_action_params
    params.require(:ticket_start_action).permit(:action, :active)
  end

  def title_params
    params.require(:mst_title).permit(:title)
  end

  def sla_params
    params.require(:sla_time).permit(:sla_time, :description)
  end

  def brands_and_category_params
    params.require(:product_brand).permit(:name, :sla_id, :organization_id, :parts_return_days, :warranty_date_format, :currency_id)
  end

  def product_category_params
    params.require(:product_category).permit(:name, :sla_id)
  end

  def problem_and_category_params
    params.require(:q_and_a).permit(:problem_category_id, :question, :answer_type, :active, :action_id, :compulsory)
  end

end
