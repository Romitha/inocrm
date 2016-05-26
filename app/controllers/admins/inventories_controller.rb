module Admins
  class InventoriesController < ApplicationController
    layout "admins"

    def index
    end

    def delete_admin_payment_item
      TaskAction
      @payment_itemn = PaymentItem.find params[:payment_item_id]
      if @payment_itemn.present?
        @payment_itemn.delete
      end
      respond_to do |format|
        format.html { redirect_to payment_item_admins_inventories_path }
      end
    end

    def delete_admin_brands_and_category
      Product
      @brands_and_category = ProductBrand.find params[:brands_and_category_id]
      if @brands_and_category.present?
        @brands_and_category.delete
      end
      respond_to do |format|
        format.html { redirect_to brands_and_category_admins_inventories_path }
      end
    end

    def delete_product_category
      Product
      @product_category = ProductCategory.find params[:product_category_id]
      if @product_category.present?
        @product_category.delete
      end
      respond_to do |format|
        format.html { redirect_to brands_and_category_admins_inventories_path }
      end
    end

    def delete_location_rack
      Inventory
      @delete_rack = InventoryRack.find params[:rack_id]
      if @delete_rack.present?
        @delete_rack.delete
      end
      respond_to do |format|
        format.html { redirect_to location_admins_inventories_url }
      end
    end

    def delete_location_shelf
      Inventory
      @delete_shelf = InventoryShelf.find params[:shelf_id]
      if @delete_shelf.present?
        @delete_shelf.delete
      end
      respond_to do |format|
        format.html { redirect_to location_admins_inventories_url }
      end
    end

    def delete_location_bin
      Inventory
      @delete_bin = InventoryBin.find params[:bin_id]
      if @delete_bin.present?
        @delete_bin.delete
      end
      respond_to do |format|
        format.html { redirect_to location_admins_inventories_url }
      end
    end

    def delete_inventory_brand
      Inventory
      @delete_brand = InventoryCategory1.find params[:brand_id]
      if @delete_brand.present?
        @delete_brand.delete
      end
      respond_to do |format|
        format.html { redirect_to category_admins_inventories_path }
      end
    end

    def delete_inventory_product
      Inventory
      @delete_product = InventoryCategory2.find params[:product_id]
      if @delete_product.present?
        @delete_product.delete
      end
      respond_to do |format|
        format.html { redirect_to category_admins_inventories_path }
      end
    end

    def delete_inventory_category
      Inventory
      @delete_category = InventoryCategory3.find params[:category_id]
      if @delete_category.present?
        @delete_category.delete
      end
      respond_to do |format|
        format.html { redirect_to category_admins_inventories_path }
      end
    end

    def delete_product_condition
      Inventory
      @inventory_product_condition = ProductCondition.find params[:product_condition_id]
      if @inventory_product_condition.present?
        @inventory_product_condition.delete
      end
      respond_to do |format|
        format.html { redirect_to product_condition_admins_inventories_path }
      end
    end

    def delete_disposal_method
      Inventory
      @inventory_disposal_method = InventoryDisposalMethod.find params[:disposal_id]
      if @inventory_disposal_method.present?
        @inventory_disposal_method.delete
      end
      respond_to do |format|
        format.html { redirect_to disposal_method_admins_inventories_path }
      end
    end

    def delete_admin_inventory_reason
      @inventory_reason = InventoryReason.find params[:inventory_reason_id]
      if @inventory_reason.present?
        @inventory_reason.delete
      end
      respond_to do |format|
        format.html { redirect_to reason_admins_inventories_path }
      end
    end

    def delete_inventory_manufacture
      Inventory
      @delete_manufacture = Manufacture.find params[:manufacture_id]
      if @delete_manufacture.present?
        @delete_manufacture.delete
      end
      respond_to do |format|
        format.html { redirect_to manufacture_admins_inventories_path }
      end
    end

    def delete_inventory_unit
      Inventory
      @inventory_unit = InventoryUnit.find params[:unit_id]
      if @inventory_unit.present?
        @inventory_unit.delete
      end
      respond_to do |format|
        format.html { redirect_to unit_admins_inventories_path }
      end
    end

    def payment_item
      TaskAction

      if params[:edit]
        @payment_item = PaymentItem.find params[:payment_item_id]
        if @payment_item.update admin_payment_item_params
          params[:edit] = nil
          render json: @payment_item
        end

      else
        if params[:create]
          @payment_item = PaymentItem.new admin_payment_item_params
          if @payment_item.save
            params[:create] = nil
            @payment_item = PaymentItem.new
          end
        else
          @payment_item = PaymentItem.new
        end
        @payment_item_all = PaymentItem.order(created_at: :desc).select{|i| i.persisted? }
      end
    end

    def brands_and_category
      Product
      SlaTime
      Organization
      Currency

      if params[:edit]

        if params[:brands_and_category_id]
          @brands_and_category = ProductBrand.find params[:brands_and_category_id]
          if @brands_and_category.update brands_and_category_params
            params[:edit] = nil
            render json: @brands_and_category
          end
        elsif params[:product_category_id]
          @product_category = ProductCategory.find params[:product_category_id]
          if @product_category.update product_category_params
            params[:edit] = nil
            render json: @product_category
          end
        end

      else
        if params[:create]
          @brands_and_category = ProductBrand.new brands_and_category_params
          if @brands_and_category.save
            params[:create] = nil
            @brands_and_category = ProductBrand.new
          else
            flash[:error] = "Unable to save"
          end

        elsif params[:edit_more]
          @brands_and_category = ProductBrand.find params[:brands_and_category_id]

        elsif params[:update]
          @brands_and_category = ProductBrand.find params[:brands_and_category_id]
          if @brands_and_category.update brands_and_category_params
            params[:update] = nil
            @brands_and_category = ProductBrand.new
          end


        else
          @brands_and_category = ProductBrand.new
        end
        @brands_and_category_all = ProductBrand.order(created_at: :desc).select{|i| i.persisted? }
      end
    end

    def location
      Inventory
      Product
      if params[:edit]
        if params[:rack_id]
          @inventory_rack = InventoryRack.find params[:rack_id]
          if @inventory_rack.update inventory_rack_params
            params[:edit] = nil
            render json: @inventory_rack
          end
        elsif params[:shelf_id]
          @inventory_shelf = InventoryShelf.find params[:shelf_id]
          if @inventory_shelf.update inventory_shelf_params
            params[:edit] = nil
            render json: @inventory_shelf
          end
        elsif params[:bin_id]
          @inventory_bin = InventoryBin.find params[:bin_id]
          if @inventory_bin.update inventory_bin_params
            params[:edit] = nil
            render json: @inventory_bin
          end
        end

      else
        if params[:create]
          @inventory_rack = InventoryRack.new inventory_rack_params
          if @inventory_rack.save
            params[:create] = nil
            @inventory_rack = InventoryRack.new
          end

        elsif params[:edit_more]
          @inventory_rack = InventoryRack.find params[:rack_id]

        elsif params[:update]
          @inventory_rack = InventoryRack.find params[:rack_id]
          if @inventory_rack.update inventory_rack_params
            params[:update] = nil
            @inventory_rack = InventoryRack.new
          end

        else
          @inventory_rack = InventoryRack.new
        end
        @inventory_all_rack = InventoryRack.order(created_at: :desc).select{|i| i.persisted? }
      end
    end

    def category
      Inventory
      if params[:edit]

        if params[:brand_id]
          @inventory_brand = InventoryCategory1.find params[:brand_id]
          if @inventory_brand.update inventory_brand_params
            params[:edit] = nil
            render json: @inventory_brand
          end
        elsif params[:product_id]
          @inventory_product = InventoryCategory2.find params[:product_id]
          if @inventory_product.update inventory_category2_params
            params[:edit] = nil
            render json: @inventory_product
          end
        elsif params[:category_id]
          @inventory_category = InventoryCategory3.find params[:category_id]
          if @inventory_category.update inventory_category_params
            params[:edit] = nil
            render json: @inventory_category
          end
        end

      else
        if params[:create]
          @inventory_category1 = InventoryCategory1.new inventory_brand_params
          if @inventory_category1.save
            params[:create] = nil
            @inventory_category1 = InventoryCategory1.new
          end

        elsif params[:edit_more]
          @inventory_category1 = InventoryCategory1.find params[:brand_id]

        elsif params[:update]
          @inventory_category1 = InventoryCategory1.find params[:brand_id]
          if @inventory_category1.update inventory_brand_params
            params[:update] = nil
            @inventory_category1 = InventoryCategory1.new
          end

        else
          @inventory_category1 = InventoryCategory1.new
        end
        @inventory_category1_all = InventoryCategory1.order(created_at: :desc).select{|i| i.persisted? }
      end
    end

    def product
      Inventory
      Product
      Currency
      InventorySerialItem
      if params[:edit]
        if params[:product_id]
          @inventory_product_form = InventoryProduct.find params[:product_id]
          if @inventory_product_form.update inventory_product_params
            params[:edit] = nil
            render json: @inventory_product_form
          end
        elsif params[:product_info_id]
          @inventory_product1 = InventoryProductInfo.find params[:product_id]
          if @inventory_product1.update inventory_product_info_params
            params[:edit] = nil
            render json: @inventory_product
          end
        end

      else
        if params[:create]
          @inventory_product = InventoryProduct.new inventory_product_params
          if @inventory_product.save
            params[:create] = nil
            @inventory_product = InventoryProduct.new
          end
        else
          @inventory_product = InventoryProduct.new
        end
        @inventory_product_all = InventoryProduct.order(created_at: :desc).select{|i| i.persisted? }
      end
    end

    def product_condition
      Inventory
      if params[:edit]
        @inventory_product_condition = ProductCondition.find params[:product_condition_id]
        if @inventory_product_condition.update inventory_product_condition_params
          params[:edit] = nil
          render json: @inventory_product_condition
        end

      else
        if params[:create]
          @inventory_product_condition = ProductCondition.new inventory_product_condition_params
          if @inventory_product_condition.save
            params[:create] = nil
            @inventory_product_condition = ProductCondition.new
          end
        else
          @inventory_product_condition = ProductCondition.new
        end
        @inventory_product_condition_all = ProductCondition.order(created_at: :desc).select{|i| i.persisted? }
      end
    end

    def disposal_method
      Inventory
      if params[:edit]
        @inventory_disposal_method = InventoryDisposalMethod.find params[:disposal_method]
        if @inventory_disposal_method.update inventory_disposal_method_params
          params[:edit] = nil
          render json: @inventory_disposal_method
        end

      else
        if params[:create]
          @inventory_disposal_method = InventoryDisposalMethod.new inventory_disposal_method_params
          if @inventory_disposal_method.save
            params[:create] = nil
            @inventory_disposal_method = InventoryDisposalMethod.new
          end
        else
          @inventory_disposal_method = InventoryDisposalMethod.new
        end
        @inventory_disposal_method_all = InventoryDisposalMethod.order(created_at: :desc).select{|i| i.persisted? }
      end
    end

    def reason
      Inventory
      if params[:edit]
        @inventory_reason = InventoryReason.find params[:inventory_reason_id]
        if @inventory_reason.update inventory_reason_params
          params[:edit] = nil
          render json: @inventory_reason
        end

      else
        if params[:create]
          @inventory_reason = InventoryReason.new inventory_reason_params
          if @inventory_reason.save
            params[:create] = nil
            @inventory_reason = InventoryReason.new
          end
        else
          @inventory_reason = InventoryReason.new
        end
        @inventory_reason_all = InventoryReason.order(created_at: :desc).select{|i| i.persisted? }
      end
    end

    def manufacture
      Inventory
      if params[:edit]
        @inventory_manufacture = Manufacture.find params[:manufacture_id]
        if @inventory_manufacture.update inventory_manufacture_params
          params[:edit] = nil
          render json: @inventory_manufacture
        end

      else
        if params[:create]
          @inventory_manufacture = Manufacture.new inventory_manufacture_params
          if @inventory_manufacture.save
            params[:create] = nil
            @inventory_manufacture = Manufacture.new
          end
        else
          @inventory_manufacture = Manufacture.new
        end
        @inventory_manufacture_all = Manufacture.order(created_at: :desc).select{|i| i.persisted? }
      end
    end

    def delete_manufacture
      @inventory_manufacture = Manufacture.find params[:manufacture_id]
      if @inventory_manufacture.present?
        @inventory_manufacture.delete
      end
      respond_to do |format|
        format.html { redirect_to manufacture_admins_inventories_path }
      end
    end

    def unit
      Inventory
      if params[:edit]
        @inventory_unit = InventoryUnit.find params[:unit_id]
        if @inventory_unit.update inventory_unit_params
          params[:edit] = nil
          render json: @inventory_unit
        end

      else
        if params[:create]
          @inventory_unit = InventoryUnit.new inventory_unit_params
          if @inventory_unit.save
            params[:create] = nil
            @inventory_unit = InventoryUnit.new
          end
        else
          @inventory_unit = InventoryUnit.new
        end
        @inventory_unit_all = InventoryUnit.order(created_at: :desc).select{|i| i.persisted? }
      end

    end

    def grn
      Inventory
      Grn

      case params[:purchase_order]
      when "yes"
        @stores = Organization.stores
        @render_template = "search_po"
      when "no"
        @render_template = "search_inventory"
        Rails.cache.fetch([:inventory_product_ids]).to_a.each do |ipid|
          Rails.cache.delete([:grn_item, :i_product, ipid ])
        end
        Rails.cache.delete([:inventory_product_ids])

      when "search_inventory"
        @store = Organization.find params[:store_id]
        session[:store_id] = @store.id

        Rails.cache.fetch([:po_item_ids]).to_a.each do |poid|
          Rails.cache.delete([:grn_item, poid] )
        end
        Rails.cache.delete([:po_item_ids])
        category1_id = params[:search_inventory]["brand"]
        category2_id = params[:search_inventory]["product"]
        inventory_product_hash = params[:search_inventory].except("brand", "product").to_hash
        category3_id = inventory_product_hash["mst_inv_product"]["category3_id"]

        updated_hash = inventory_product_hash["mst_inv_product"].to_hash.map { |k, v| "#{k} like '%#{v}%'" if v.present? }.compact.join(" and ")
        if category3_id.present?
          @inventory_products = @store.inventory_products.where(updated_hash)
        elsif category2_id.present?
          @inventory_products = InventoryCategory2.find(category2_id).inventory_products.where(updated_hash)
        elsif category1_id.present?
          @inventory_products = InventoryCategory1.find(category1_id).inventory_category3s.map { |c| c.inventory_products.where(updated_hash) }.flatten.uniq
        else
          @inventory_products = @store.inventory_products.where(updated_hash)
        end

        @render_template = "select_inventory"

      when "select_inventory"
        @inventory_product = InventoryProduct.find params[:inventory_product_id]

        @grn_item = Rails.cache.fetch([:grn_item, :i_product, @inventory_product.id ]) { GrnItem.new }
        @render_template = "grn_item"
        
      when "search_po"
        @pos = InventoryPo.where(closed: false).where("po_no = :po_no or store_id = :store_id or supplier_id = :supplier_id", params[:po])
        if params[:po_date_from].to_date and params[:po_date_to].to_date
          @pos = @pos.where(created_at: (params[:po_date_from]..params[:po_date_to]))
        end

        Rails.cache.delete([:inventory_product_ids])
        Rails.cache.delete([:po_item_ids])
        session[:po_id] = nil
        @render_template = "select_po"

      when "select_po"
        @po = InventoryPo.find params[:po_id]
        session[:po_id] = @po.id

        @render_template = "new_grn"

      when "select_po_item"
        @po_item = InventoryPoItem.find params[:po_item_id]

        @grn_item = Rails.cache.fetch([:grn_item, params[:po_item_id].to_i ]) { GrnItem.new }

        @render_template = "grn_item"        
      end
      render "admins/inventories/grn/grn"
    end

    def initialize_grn
      Inventory
      Grn
      @po_item = InventoryPoItem.find params[:po_item_id]

      @grn_item = GrnItem.new grn_item_params

      if params[:next].present?
        if @grn_item.valid?
          if not Rails.cache.fetch([:po_item_ids]).to_a.include? params[:po_item_id].to_i
            a = Rails.cache.fetch([:po_item_ids]).to_a
            a << params[:po_item_id].to_i
            Rails.cache.write([:po_item_ids], a)
          end
          Rails.cache.write([:grn_item, @po_item.id], @grn_item )

          if Rails.cache.fetch([:po_item_ids]).to_a.count > 0 #@po_item.inventory_po.inventory_po_items.count
            @grn = Grn.new po_id: session[:po_id]

          end
        else
          a = Rails.cache.fetch([:po_item_ids]).to_a
          a.delete(params[:po_item_id].to_i)
          Rails.cache.write([:po_item_ids], a)
        end
      elsif params[:cancel]
        a = Rails.cache.fetch([:po_item_ids]).to_a
        a.delete(params[:po_item_id].to_i)
        Rails.cache.write([:po_item_ids], a)

        Rails.cache.delete([:grn_item, @po_item.id] )
      end

      render "admins/inventories/grn/grn"
    end

    def initiate_grn_for_i_product
      Inventory
      Grn
      @inventory_product = InventoryProduct.find params[:inventory_product_id]
      @grn_item = GrnItem.new grn_item_params

      if params[:next].present?
        if @grn_item.valid?
          if not Rails.cache.fetch([:inventory_product_ids]).to_a.include? params[:inventory_product_id].to_i
            a = Rails.cache.fetch([:inventory_product_ids]).to_a
            a << params[:inventory_product_id].to_i
            Rails.cache.write([:inventory_product_ids], a)
          end
          Rails.cache.write([:grn_item, :i_product, @inventory_product.id ], @grn_item)

          if Rails.cache.fetch([:inventory_product_ids]).to_a.count > 0
            @grn = Grn.new

          end
        else
          a = Rails.cache.fetch([:inventory_product_ids]).to_a
          a.delete(params[:inventory_product_id].to_i)
          Rails.cache.write([:inventory_product_ids], a)
        end
      elsif params[:cancel]
        a = Rails.cache.fetch([:inventory_product_ids]).to_a
        a.delete(params[:inventory_product_id].to_i)
        Rails.cache.write([:inventory_product_ids], a)

        Rails.cache.delete([:grn_item, :i_product, @inventory_product.id ] )
      end

      @inventory_products = InventoryProduct.where(id: Rails.cache.fetch([:inventory_product_ids]).to_a)

      render "admins/inventories/grn/grn"
    end

    def create_grn
      Inventory
      Organization
      @grn = Grn.new grn_params
      if @grn.inventory_po.present? # With PO Items
        @grn.store_id = @grn.inventory_po.store_id
        @grn.po_id = @grn.inventory_po.id
      else                          # Without PO Items
        @grn.store_id = session[:store_id]
      end
      @grn.created_at = DateTime.now
      @grn.created_by = current_user.id
      @grn.grn_no = CompanyConfig.first.increase_inv_last_grn_no
      @grn.save!

      # With PO Items
      Rails.cache.fetch([:po_item_ids]).to_a.each do | po_item_id |
        po_item = InventoryPoItem.find po_item_id
        grn_item = Rails.cache.fetch([:grn_item, po_item_id ] )
        tot_recieved_qty = 0

        grn_item.grn_batches.each do |gb| 
          gb.remaining_quantity = gb.recieved_quantity 
          tot_recieved_qty += gb.recieved_quantity
        end
        grn_item.grn_serial_items.each do |s|
          tot_recieved_qty += 1
        end
        tot_recieved_qty = grn_item.recieved_quantity if tot_recieved_qty == 0

        grn_item.grn_id = @grn.id
        grn_item.po_item_id = po_item.id
        grn_item.product_id = po_item.inventory_prn_item.product_id
        grn_item.recieved_quantity = grn_item.remaining_quantity = tot_recieved_qty
        grn_item.unit_cost = grn_item.current_unit_cost = po_item.unit_cost_grn
        grn_item.currency_id = grn_item.inventory_product.inventory_product_info.currency_id
        grn_item.inventory_not_updated = false
        grn_item.save!

        inventory = grn_item.inventory_product.inventories.find_by_store_id(@grn.store_id)
        inventory.update stock_quantity: (inventory.stock_quantity + tot_recieved_qty), available_quantity: (inventory.available_quantity + tot_recieved_qty)

        grn_item.grn_item_current_unit_cost_histories.create created_by: current_user.id, current_unit_cost: grn_item.current_unit_cost

        Rails.cache.delete([:grn_item, po_item_id] )

        po_item.update closed: (po_item.quantity.to_f <= po_item.grn_items.sum(:recieved_quantity).to_f )
      end

      if @grn.inventory_po.present?
        @grn.inventory_po.update closed: @grn.inventory_po.inventory_po_items.all?{ |i| i.closed }
      end

      # Without PO Items
      Rails.cache.fetch([:inventory_product_ids]).to_a.each do | inventory_product_id |
        inventory_product = InventoryProduct.find inventory_product_id
        grn_item = Rails.cache.fetch( [:grn_item, :i_product, inventory_product.id ] )
        tot_recieved_qty = 0

        grn_item.grn_batches.each do |gb|
          gb.remaining_quantity = gb.recieved_quantity
          tot_recieved_qty += gb.recieved_quantity
        end
        grn_item.grn_serial_items.each do |s|
          tot_recieved_qty += 1
        end
        tot_recieved_qty = grn_item.recieved_quantity if tot_recieved_qty == 0

        grn_item.grn_id = @grn.id
        grn_item.product_id = inventory_product.id
        grn_item.recieved_quantity = tot_recieved_qty
        grn_item.remaining_quantity = tot_recieved_qty
        grn_item.current_unit_cost = grn_item.unit_cost
        grn_item.currency_id = inventory_product.inventory_product_info.currency_id
        grn_item.inventory_not_updated = false
        grn_item.save!

        inventory = grn_item.inventory_product.inventories.find_by_store_id(@grn.store_id)
        inventory.update stock_quantity: (inventory.stock_quantity + tot_recieved_qty), available_quantity: (inventory.available_quantity + tot_recieved_qty)

        grn_item.grn_item_current_unit_cost_histories.create created_by: current_user.id, current_unit_cost: grn_item.current_unit_cost

        Rails.cache.delete([:grn_item, :i_product, inventory_product.id ] )

      end

      flash[:notice] = "Successfully saved."

      Rails.cache.delete([:po_item_ids])
      session[:po_id] = nil
      session[:store_id] = nil

      redirect_to grn_admins_inventories_url

    end

    private
      def admin_payment_item_params
        params.require(:payment_item).permit(:name, :default_amount)
      end

      def brands_and_category_params
        params.require(:product_brand).permit(:name, :sla_id, :organization_id, :parts_return_days, :warranty_date_format, :currency_id, product_categories_attributes: [:id, :_destroy, :name, :sla_id])
      end

      def product_category_params
        params.require(:product_category).permit(:name, :sla_id)
      end

      def q_and_a_params
        params.require(:inventory_shelf).permit(:description)
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

      def inventory_category2_params
        params.require(:inventory_category2).permit(:code, :name)
      end

      def inventory_category_params
        params.require(:inventory_category3).permit(:code, :name)
      end

      def inventory_product_params
        params.require(:inventory_product).permit(:category3_id, :serial_no, :serial_no_order, :sku, :legacy_code, :description, :model_no, :product_no, :spare_part_no, :fifo, :active, :spare_part, :unit_id, :created_by, :updated_by, :non_stock_item, inventory_product_info_attributes: [:picture, :secondary_unit_id, :issue_fractional_allowed, :per_secondery_unit_conversion, :need_serial, :need_batch, :country_id, :manufacture_id, :average_cost, :standard_cost, :currency_id, :remarks])
      end

      def inventory_product_info_params
        params.require(:inventory_product_info).permit(:secondary_unit_id, :average_cost, :need_serial, :need_batch, :per_secondery_unit_conversion, :country_id, :manufacture_id, :currency_id, :standard_cost,:average_cost)
      end

      def inventory_product_condition_params
        params.require(:product_condition).permit(:condition, :created_by, :updated_by)
      end

      def inventory_disposal_method_params
        params.require(:inventory_disposal_method).permit(:disposal_method, :created_by, :updated_by)
      end

      def inventory_reason_params
        params.require(:inventory_reason).permit(:srn_issue_terminate, :damage, :srr, :disposal, :reason, :created_by, :updated_by)
      end

      def inventory_manufacture_params
        params.require(:manufacture).permit(:manufacture, :created_by, :created_by)
      end

      def inventory_unit_params
        params.require(:inventory_unit).permit(:unit, :base_unit_id, :base_unit_conversion, :per_base_unit, :description, :created_by, :created_by)
      end

      def inventory_po_item_params
        params.require(:inventory_po_item).permit(:id, grn_items_attributes: [:recieved_quantity, :remarks, grn_batches_attributes: [:id, :recieved_quantity, :_destroy, inventory_batch_attributes: [:id, :_destroy, :lot_no, :batch_no, :manufatured_date, :expiry_date, :remarks, ]], grn_serial_items_attributes: [:id, :_destroy, :recieved_quantity, inventory_serial_item_attributes: [:id, :_destroy, :inventory_id, :product_id, :inv_status_id, :created_by, :serial_no, :ct_no, :manufatured_date, :expiry_date, :scavenge, :parts_not_completed, :damage, :used, :repaired, :reserved, :product_condition_id, :remarks, inventory_serial_warranties_attributes: [:id, :_destroy, inventory_warranty_attributes: [:id, :_destroy, :created_by, :start_at, :end_at, :period_part, :period_labour, :period_onsight, :remarks, :warranty_type_id]]]]])
      end

      def grn_item_params
        params.require(:grn_item).permit(:id, :recieved_quantity, :unit_cost, :remarks, grn_batches_attributes: [:id, :recieved_quantity, :remaining_quantity, :_destroy, inventory_batch_attributes: [:id, :_destroy, :inventory_id, :product_id, :created_by, :lot_no, :batch_no, :manufatured_date, :expiry_date, :remarks, inventory_batch_warranties_attributes: [:id, :_destroy, inventory_warranty_attributes: [:id, :_destroy, :created_by, :start_at, :end_at, :period_part, :period_labour, :period_onsight, :remarks, :warranty_type_id]] ]], grn_serial_items_attributes: [:id, :_destroy, :recieved_quantity, :remaining, inventory_serial_item_attributes: [:id, :_destroy, :inventory_id, :product_id, :inv_status_id, :created_by, :serial_no, :ct_no, :manufatured_date, :expiry_date, :scavenge, :parts_not_completed, :damage, :used, :repaired, :reserved, :product_condition_id, :remarks, inventory_serial_warranties_attributes: [:id, :_destroy, inventory_warranty_attributes: [:id, :_destroy, :created_by, :start_at, :end_at, :period_part, :period_labour, :period_onsight, :remarks, :warranty_type_id]]]])
      end

      def grn_params
        params.require(:grn).permit(:remarks, :po_id)
      end

  end
end