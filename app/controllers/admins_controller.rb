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

  # def inventory_location
  #   Inventory
  #   Product
  #   @inventory_rack = InventoryRack.new
  #   @inventory_all_rack = InventoryRack.all
  #   render "inventories/inventory_location"
  # end

  # def update_inventory_location
  #   Inventory
  #   Product
  #   @inventory_all_rack = InventoryRack.all
  #   @inventory_rack = InventoryRack.new inventory_rack_params
  #   @inventory_rack.save
  #   render "inventories/inventory_location"
  # end

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

  def inventory_location_update
    # @product = Product.find(params[:product_id])
    # formatted_product_params = product_params
    # formatted_product_params["pop_note"] = "#{formatted_product_params['pop_note']} <span class='pop_note_e_time'> on #{Time.now.strftime('%d/ %m/%Y at %H:%M:%S')}</span> by <span class='pop_note_created_by'> #{current_user.email}</span><br/>#{@product.pop_note}" if formatted_product_params["pop_note"].present?
    # @product.update(formatted_product_params)
    # respond_with(@product)
  end

  # def inventory_category_update

  # end

  # def inventory_category
  #   Inventory
  #   @inventory_category1_all = InventoryCategory1.all
  #   @inventory_category1 = InventoryCategory1.new
  #   render "inventories/inventory_category"
  # end

  # def update_inventory_category
  #   Inventory
  #   @inventory_category1_all = InventoryCategory1.all
  #   @inventory_category1 = InventoryCategory1.new inventory_brand_params
  #   @inventory_category1.save
  #   render "inventories/inventory_category"
  # end

  # def inventory_product_condition
  #   Inventory
  #   @inventory_product_condition_all = ProductCondition.order(created_at: :desc).select{|i| i.persisted? }
  #   @inventory_product_condition = ProductCondition.new
  #   render "inventories/inventory_product_condition"
  # end

  # def update_inventory_product_condition
  #   Inventory

  #   if params[:create]
  #     @inventory_product_condition = ProductCondition.new inventory_product_condition_params
  #     if @inventory_product_condition.save
  #       params[:create] = nil
  #       @inventory_product_condition = ProductCondition.new
  #     end
  #   else
  #     @inventory_product_condition = ProductCondition.new
  #   end

  #   @inventory_product_condition_all = ProductCondition.order(created_at: :desc).select{|i| i.persisted? }
  #   render "inventories/inventory_product_condition"
  # end

  # def inventory_disposal_method
  #   Inventory
  #   @inventory_disposal_method = InventoryDisposalMethod.new
  #   @inventory_disposal_method_all = InventoryDisposalMethod.order(created_at: :desc).select{|i| i.persisted? }
  #   render "inventories/inventory_disposal_method"
  # end

  # def update_inventory_disposal_method
  #   Inventory
  #   @inventory_disposal_method = InventoryDisposalMethod.new inventory_disposal_method_params
  #   if @inventory_disposal_method.save
  #     @inventory_disposal_method = InventoryDisposalMethod.new
  #   end

  #   @inventory_disposal_method_all = InventoryDisposalMethod.order(created_at: :desc).select{|i| i.persisted? }
  #   render "inventories/inventory_disposal_method"

  # end

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

  # def inventory_manufacture
  #   Inventory
  #   @inventory_manufacture = Manufacture.new
  #   @inventory_manufacture_all = Manufacture.all
  #   render "inventories/inventory_manufacture"
  # end

  # def update_inventory_manufacture
  #   Inventory
  #   @inventory_manufacture = Manufacture.new inventory_manufacture_params
  #   if @inventory_manufacture.save
  #     @inventory_manufacture = Manufacture.new
  #   end

  #   @inventory_manufacture_all = Manufacture.order(created_at: :desc).select{|i| i.persisted? }
  #   render "inventories/inventory_manufacture"

  # end

  # def inventory_unit
  #   Inventory
  #   @inventory_unit = InventoryUnit.new
  #   @inventory_unit_all = InventoryUnit.all
  #   render "inventories/inventory_unit"
  # end

  # def update_inventory_unit
  #   Inventory
  #   @inventory_unit = InventoryUnit.new inventory_unit_params
  #   if @inventory_unit.save
  #     @inventory_unit = InventoryUnit.new
  #   end

  #   @inventory_unit_all = InventoryUnit.order(created_at: :desc).select{|i| i.persisted? }
  #   render "inventories/inventory_unit"
  # end

  # def reason
  #   Ticket
  #   if params[:edit]
  #     @mst_reason = Reason.find params[:mst_reason_id]
  #     if @mst_reason.update admin_reason_params
  #       render json: @mst_reason
  #     end
  #   else
  #     if params[:create]
  #       @reason = Reason.new admin_reason_params
  #       if @reason.save
  #         params[:create] = nil
  #         @reason = Reason.new
  #       end
  #     else
  #       @reason = Reason.new
  #     end
  #     @reason_all = Reason.order(created_at: :desc).select{|i| i.persisted? }
  #     render "admins/master_data/reason"
  #   end

  #   # Ticket
  #   # @reason = Reason.new
  #   # @reason_all = Reason.order(created_at: :desc).select{|i| i.persisted? }
  #   # render "admins/master_data/reason"
  end

  # def update_reason

  #   Ticket
  #   @reason = Reason.new admin_reason_params
  #   if @reason.save
  #     @reason = Reason.new
  #   end

  #   @reason_all = Reason.order(created_at: :desc).select{|i| i.persisted? }
  #   render "admins/master_data/reason"

  # end

  # def inline_update_admin_reason
  #   Ticket
  #   @mst_reason = Reason.find params[:mst_reason_id]
  #   if @mst_reason.update admin_reason_params
  #     render json: @mst_reason
  #   end
  # end

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
    # def brands_and_categories_params
    #   params.require(:product_brand).permit(:name, :sla_id, :parts_return_days, :warranty_date_format, :currency_id, product_categories_attributes: [:name, :sla_id, :_destroy, :id])
    # end

    def brands_and_categories_params
      params.require(:product_brand).permit(:organization_id, :currency_id, :name, :sla_id, :parts_return_days, :warranty_date_format, product_categories_attributes: [:name, :sla_id, :_destroy, :id])
    end

    def problem_category_params
      params.require(:problem_category).permit(:name, q_and_as_attributes: [:_destroy, :id, :active, :answer_type, :question, :action_id, :compulsory])
    end

    # def sbu_params
    #   params.require(:sbu).permit(:sbu, sbu_engineers_attributes: [:_destroy, :id, :sbu_id, :engineer_id])
    # end

    # def inventory_product_params
    #   params.require(:inventory_product).permit(:category3_id, :serial_no, :serial_no_order, :sku, :legacy_code, :description, :model_no, :product_no, :spare_part_no, :fifo, :active, :spare_part, :unit_id, :created_by, :updated_by, :non_stock_item, inventory_product_info_attributes: [:picture, :secondary_unit_id, :issue_fractional_allowed, :per_secondery_unit_conversion, :need_serial, :need_batch, :country_id, :manufacture_id, :average_cost, :standard_cost, :currency_id, :remarks])
    # end

    # def inventory_product_info_params
    #   params.require(:inventory_product_info).permit(:secondary_unit_id, :average_cost, :need_serial, :need_batch, :per_secondery_unit_conversion, :country_id, :manufacture_id, :currency_id, :standard_cost,:average_cost)
    # end

    # def inventory_product_condition_params
    #   params.require(:product_condition).permit(:condition, :created_by, :updated_by)
    # end

    # def inventory_disposal_method_params
    #   params.require(:inventory_disposal_method).permit(:disposal_method, :created_by, :updated_by)
    # end

    # def inventory_reason_params
    #   params.require(:inventory_reason).permit(:reason, :srn_issue_terminate, :damage, :srr, :disposal, :created_by, :updated_by)
    # end

    # def inventory_rack_params
    #   params.require(:inventory_rack).permit(:description, :location_id, :aisle_image, :created_by, :updated_by,inventory_shelfs_attributes: [:_destroy, :id, :description, :created_by, :updated_by, inventory_bins_attributes: [:_destroy, :id, :description, :created_by, :updated_by]])
    # end

    # def inventory_shelf_params
    #   params.require(:inventory_shelf).permit(:description)
    # end

    # def inventory_bin_params
    #   params.require(:inventory_bin).permit(:description)
    # end

    # def inventory_brand_params
    #   params.require(:inventory_category1).permit(:code, :name, :created_by, :created_by, inventory_category2s_attributes: [:_destroy, :id, :code, :name, :created_by, :updated_by, inventory_category3s_attributes: [:_destroy, :id, :code, :name, :created_by, :updated_by] ])
    # end

    # def inventory_category2_params
    #   params.require(:inventory_category2).permit(:code, :name)
    # end

    # def inventory_category_params
    #   params.require(:inventory_category3).permit(:code, :name)
    # end

    # def inventory_manufacture_params
    #   params.require(:manufacture).permit(:manufacture, :created_by, :created_by)
    # end

    # def inventory_unit_params
    #   params.require(:inventory_unit).permit(:unit, :base_unit_id, :base_unit_conversion, :per_base_unit, :description, :created_by, :created_by)
    # end

    # def admin_reason_params
    #   params.require(:reason).permit(:hold, :sla_pause, :re_assign_request, :terminate_job, :terminate_spare_part, :warranty_extend, :spare_part_unused, :reject_returned_part, :reject_close, :adjust_terminate_job_payment, :reason)
    # end

    # def admin_country_params
    #   params.require(:product_sold_country).permit(:Country, :code)
    # end

    # def admin_accessory_params
    #   params.require(:accessory).permit(:accessory)
    # end

    # def admin_add_charge_params
    #   params.require(:additional_charge).permit(:additional_charge, :default_cost_price, :default_estimated_price)
    # end

    # def admin_ad_feedback_params
    #   params.require(:feedback).permit(:feedback)
    # end

    # def admin_general_question_params
    #   params.require(:ge_q_and_a).permit(:question, :answer_type, :active, :compulsory, :action_id)
    # end

    # def admin_payment_item_params
    #   params.require(:payment_item).permit(:name, :default_amount)
    # end

    # def regional_support_center_params
    #   params.require(:regional_support_center).permit(:organization_id, :active, sbu_regional_engineers_attributes: [:engineer_id])
    # end

    # def sburegional_engineer_params
    #   params.require(:sbu_regional_engineer).permit(:engineer_id)
    # end

    # def sp_description_params
    #   params.require(:spare_part_description).permit(:description)
    # end

    # def ticket_start_action_params
    #   params.require(:ticket_start_action).permit(:action, :active)
    # end

    # def title_params
    #   params.require(:mst_title).permit(:title)
    # end

    # def sla_params
    #   params.require(:sla_time).permit(:sla_time, :description, :created_by)
    # end

    # def brands_and_category_params
    #   params.require(:product_brand).permit(:name, :sla_id, :organization_id, :parts_return_days, :warranty_date_format, :currency_id)
    # end

    # def product_category_params
    #   params.require(:product_category).permit(:name, :sla_id)
    # end

    # def problem_and_category_params
    #   params.require(:q_and_a).permit(:problem_category_id, :question, :answer_type, :active, :action_id, :compulsory)
    # end

end
