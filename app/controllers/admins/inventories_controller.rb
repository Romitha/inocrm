module Admins
  class InventoriesController < ApplicationController
    layout "admins"

    def index
    end

    def filter_brand_product
      Inventory
      case
      when params[:inventory_category1_id].present?
        inventory_product_category1 = InventoryCategory1.find params[:inventory_category1_id]
        @inventory_product_category_all = inventory_product_category1.inventory_category2s
        @render_template = "inventory_product_categories"

      when params[:inventory_category21_id].present?
        inventory_product_category1 = InventoryCategory1.find params[:inventory_category21_id]
        @inventory_category_all = inventory_product_category1.inventory_category3s
        @render_template = "categories"

      when params[:inventory_category22_id].present?
        inventory_product_category2 = InventoryCategory2.find params[:inventory_category22_id]
        @inventory_category_all = inventory_product_category2.inventory_category3s
        @render_template = "categories"
      end
      @renderDom = params[:render_dom]
    end

    def delete_admin_brands_and_category
      Product
      @brands_and_category = ProductBrand.find params[:brands_and_category_id]
      if @brands_and_category.present?
        @brands_and_category.delete
      end
      respond_to do |format|
        format.html { redirect_to brands_and_category_admins_tickets_path }
      end
    end

    def delete_product_category
      Product
      @product_category = ProductCategory.find params[:product_category_id]
      if @product_category.present?
        @product_category.delete
      end
      respond_to do |format|
        format.html { redirect_to brands_and_category_admins_tickets_path }
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

    def delete_inventory_product_category
      Inventory
      @delete_product = InventoryCategory2.find params[:product_id]
      if @delete_product.present?
        @delete_product.delete
      end
      respond_to do |format|
        format.html { redirect_to inventory_product_category_admins_inventories_path }
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

    def location
      Inventory
      Product

      if params[:edit]
        if params[:rack_id]
          @inventory_rack = InventoryRack.find params[:rack_id]
          if @inventory_rack.update inventory_rack_params
            params[:edit] = nil
            render json: @inventory_rack
          else
            render json: @inventory_rack.errors.full_messages.join
          end
        elsif params[:shelf_id]
          @inventory_shelf = InventoryShelf.find params[:shelf_id]
          if @inventory_shelf.update inventory_shelf_params
            params[:edit] = nil
            render json: @inventory_shelf
          else
            render json: @inventory_shelf.errors.full_messages.join
          end
        elsif params[:bin_id]
          @inventory_bin = InventoryBin.find params[:bin_id]
          if @inventory_bin.update inventory_bin_params
            params[:edit] = nil
            render json: @inventory_bin
          else
            render json: @inventory_bin.errors.full_messages.join
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
        @inventory_all_rack = InventoryRack.order(updated_at: :desc)
      end

    end

    def inventory_brand
      Inventory
      if params[:edit]
        @inventory_brand = InventoryCategory1.find params[:inventory_category1_id]
        if @inventory_brand.update inventory_category1_params
          params[:edit] = nil
          render json: @inventory_brand
        end

      else
        if params[:create]
          @inventory_brand = InventoryCategory1.new inventory_category1_params
          if @inventory_brand.save
            params[:create] = nil
            @inventory_brand = InventoryCategory1.new
          end
        else
          @inventory_brand = InventoryCategory1.new
        end
        @inventory_brand_all = InventoryCategory1.order(updated_at: :desc)
      end
    end

    def inventory_product_category
      Inventory
      if params[:edit]
        @inventory_product_category = InventoryCategory2.find params[:inventory_category2_id]
        if @inventory_product_category.update inventory_category2_params
          params[:edit] = nil
          render json: @inventory_product_category
        else
          render json: @inventory_product_category.errors.full_messages.join
        end

      else
        if params[:create]
          @inventory_product_category = InventoryCategory2.new inventory_category2_params
          if @inventory_product_category.save
            params[:create] = nil
            @inventory_product_category = InventoryCategory2.new
          end
        else
          @inventory_product_category = InventoryCategory2.new
        end
        @inventory_product_category_all = InventoryCategory2.order(updated_at: :desc)
      end
    end

    def category
      Inventory
      if params[:edit]
        @inventory_category = InventoryCategory3.find params[:inventory_category3_id]
        if @inventory_category.update inventory_category3_params
          params[:edit] = nil
          render json: @inventory_category
        else
          render json: @inventory_category.errors.full_messages.join
        end

      else
        if params[:create]
          @inventory_category = InventoryCategory3.new inventory_category3_params
          if @inventory_category.save
            params[:create] = nil
            @inventory_category = InventoryCategory3.new
          end
        elsif params[:edit_more]
          @inventory_category = InventoryCategory3.find params[:inventory_category3_id]

        elsif params[:update]
          @inventory_category = InventoryCategory3.find params[:inventory_category3_id]
          if @inventory_category.update inventory_category3_params
            params[:update] = nil
            @inventory_category = InventoryCategory3.new
          end

        else
          @inventory_category = InventoryCategory3.new
        end
        @inventory_category_all = InventoryCategory3.order(updated_at: :desc)
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
          else
            render json: @inventory_product_form.errors.full_messages.join
          end
        elsif params[:product_info_id]
          @inventory_product1 = InventoryProductInfo.find params[:product_info_id]
          if @inventory_product1.update inventory_product_info_params
            params[:edit] = nil
            render json: @inventory_product1
          else
            render json: @inventory_product1.errors.full_messages.join
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
        @inventory_product_all = InventoryProduct.order(updated_at: :desc).select{ |i| i.persisted? }

      end
    end

    def product_condition
      Inventory
      if params[:edit]
        @inventory_product_condition = ProductCondition.find params[:product_condition_id]
        if @inventory_product_condition.update inventory_product_condition_params
          params[:edit] = nil
          render json: @inventory_product_condition
        else
          render json: @inventory_product_condition.errors.full_messages.join
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
        @inventory_product_condition_all = ProductCondition.order(updated_at: :desc)
      end
    end

    def disposal_method
      Inventory
      if params[:edit]
        @inventory_disposal_method = InventoryDisposalMethod.find params[:disposal_method]
        if @inventory_disposal_method.update inventory_disposal_method_params
          params[:edit] = nil
          render json: @inventory_disposal_method
        else
          render json: @inventory_disposal_method.errors.full_messages.join
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
        @inventory_disposal_method_all = InventoryDisposalMethod.order(updated_at: :desc)
      end
    end

    def reason
      Inventory
      if params[:edit]
        @inventory_reason = InventoryReason.find params[:inventory_reason_id]
        if @inventory_reason.update inventory_reason_params
          params[:edit] = nil
          render json: @inventory_reason
        else
          render json: @inventory_reason.errors.full_messages.join
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
        @inventory_reason_all = InventoryReason.order(updated_at: :desc)
      end
    end

    def manufacture
      Inventory
      if params[:edit]
        @inventory_manufacture = Manufacture.find params[:manufacture_id]
        if @inventory_manufacture.update inventory_manufacture_params
          params[:edit] = nil
          render json: @inventory_manufacture
        else
          render json: @inventory_manufacture.errors.full_messages.join
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
        @inventory_manufacture_all = Manufacture.order(updated_at: :desc)
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
        else
          render json: @inventory_unit.errors.full_messages.join
        end

      else
        if params[:create]
          @inventory_unit = InventoryUnit.new inventory_unit_params
          if @inventory_unit.save
            @inventory_unit = InventoryUnit.new
          end
        else
          @inventory_unit = InventoryUnit.new
        end
        @inventory_unit_all = InventoryUnit.order(updated_at: :desc)
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
        puts Rails.cache.fetch([:inventory_product_ids])
        @render_template = "search_inventory"

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
          @inventory_products = @store.inventory_products.where(updated_hash).uniq
        elsif category2_id.present?
          @inventory_products = InventoryCategory2.find(category2_id).inventory_products.where(updated_hash).uniq
        elsif category1_id.present?
          @inventory_products = InventoryCategory1.find(category1_id).inventory_category3s.map { |c| c.inventory_products.where(updated_hash) }.flatten.uniq
        else
          @inventory_products = @store.inventory_products.where(updated_hash).uniq
        end

        @inventory_products.to_a.each do |ipid|
          Rails.cache.delete([:grn_item, :i_product, ipid.id ])
          Rails.cache.delete([:serial_item, :i_product, ipid.id ])
        end
        Rails.cache.delete([:inventory_product_ids])

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
        if Rails.cache.fetch([:inventory_product_ids]).to_a.count > 0
          @grn = Grn.new

        end

        # Rails.cache.delete([:grn_item, :i_product, @inventory_product.id ] )
        # Rails.cache.delete([ :serial_item, :i_product, @inventory_product.id ])
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
        bulk_serial_items = Rails.cache.fetch([:serial_item, :i_product, inventory_product.id ] )
        grn_item.inventory_serial_items << bulk_serial_items if bulk_serial_items.present?
        tot_recieved_qty = 0

        grn_item.grn_batches.each do |gb|
          gb.remaining_quantity = gb.recieved_quantity
          tot_recieved_qty += gb.recieved_quantity
        end
        grn_item.grn_serial_items.each do |s|
          s.remaining = true
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
        Rails.cache.delete([:serial_item, :i_product, inventory_product.id ] )

      end

      flash[:notice] = "Successfully saved."

      Rails.cache.delete([:po_item_ids])
      session[:po_id] = nil
      session[:store_id] = nil

      redirect_to grn_admins_inventories_url

    end

    def upload_grn_file
      Inventory
      if params[:new_bulk_upload_serial].present?
        accessible_inventory_serial_item_params = inventory_serial_item_params
        # params[:inventory_product_id].to_i is used to connect to grn.
        Rails.cache.write([ :serial_item, :i_product, params[:inventory_product_id].to_i ], Rails.cache.fetch([:bulk_serial, params[:timestamp].to_i ]).map { |s| InventorySerialItem.new(accessible_inventory_serial_item_params.merge(serial_no: s[0], ct_no: s[1])) })

        Rails.cache.delete( [:bulk_serial, params[:timestamp].to_i ] )

      elsif params[:clear_import].present?
        Rails.cache.delete([ :serial_item, :i_product, params[:inventory_product_id].to_i ])

      else
        uploaded_io = params[:import_csv]
        reference_resource = params[:refer_resource_class].classify.constantize.find params[:refer_resource_id]

        Dir.mkdir(File.join(Rails.root, "public", "uploads"), 755) unless Dir.exist?(File.join(Rails.root, "public", "uploads"))

        File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
          file.write(uploaded_io.read)
        end
        @inventory_serial_item = InventorySerialItem.new inventory_id: params[:inventory_id], product_id: params[:inventory_product_id], created_by: current_user.id

        @sheet = Roo::Spreadsheet.open(File.join(Rails.root, "public", "uploads", uploaded_io.original_filename))
        @time_store = Time.now.strftime("%H%M%S")
        Rails.cache.fetch([:bulk_serial, @time_store.to_i ]) { (@sheet.last_row - 1).times.map{|m| @sheet.row(m+2)} }
        File.delete(File.join(Rails.root, "public", "uploads", uploaded_io.original_filename))

      end
      render "admins/inventories/grn/upload_grn_file"

    end

    def inventory
      Inventory
      Grn

      if params[:edit]
        @inventory = Inventory.find params[:inventory_id]
        if @inventory.update inventory_params
          params[:edit] = nil
          render json: @inventory
        else
          render json: @inventory.errors.full_messages.join
        end

      elsif params[:search_product]
        category1_id = params[:search_inventory]["brand"]
        category2_id = params[:search_inventory]["product"]
        inventory_product_hash = params[:search_inventory].except("brand", "product").to_hash
        category3_id = inventory_product_hash["mst_inv_product"]["category3_id"]

        @store = Organization.find params[:store_id]
        session[:store_id] = @store.id
        updated_hash = inventory_product_hash["mst_inv_product"].to_hash.map { |k, v| "#{k} like '%#{v}%'" if v.present? }.compact.join(" and ")
        store_product_ids = @store.inventory_product_ids.uniq
        if category3_id.present?
          @inventory_products = InventoryProduct.where.not(id: store_product_ids).where(updated_hash)
        elsif category2_id.present?
          @inventory_products = InventoryCategory2.find(category2_id).inventory_products.where.not(id: store_product_ids).where(updated_hash)
        elsif category1_id.present?
          @inventory_products = InventoryCategory1.find(category1_id).inventory_category3s.map { |c| c.inventory_products.where(updated_hash) }.flatten.uniq.keep_if{|p| !store_product_ids.uniq.include?(p.id) }
        else
          @inventory_products = InventoryProduct.where.not(id: store_product_ids).where(updated_hash)
        end
        @render_template = "admins/inventories/inventory/select_inventory"
        render "admins/inventories/inventory/inventory"

      elsif params[:store_id]
        @render_template = "admins/inventories/inventory/search_products"
        @store_available = true
        render "admins/inventories/inventory/inventory"

      elsif params[:select_product]
        @store = Organization.find session[:store_id]
        @inventory = Inventory.new
        @inventory_product = InventoryProduct.find params[:inventory_product_id]
        @render_template = "admins/inventories/inventory/inventory_form"
        render "admins/inventories/inventory/inventory"

      else
        if params[:create]
          @inventory = Inventory.new inventory_params
          if @inventory.save
            params[:create] = nil
            @inventory = Inventory.new
          end
        end
        @stores = Organization.stores
        @inventory_all = Inventory.order( store_id: :asc)
        render "admins/inventories/inventory/inventory"

      end
    end

    def srn
      Organization
      Role
      Inventory
      case params[:srn_callback]
      when "call_search"
        Inventory
        @modal_active = true
      when "search_inventory"
        @store = Organization.find params[:store_id]
        session[:store_id] = @store.id
        category1_id = params[:search_inventory]["brand"]
        category2_id = params[:search_inventory]["product"]
        inventory_product_hash = params[:search_inventory].except("brand", "product").to_hash
        category3_id = inventory_product_hash["mst_inv_product"]["category3_id"]

        updated_hash = inventory_product_hash["mst_inv_product"].to_hash.map { |k, v| "#{k} like '%#{v}%'" if v.present? }.compact.join(" and ")
        if category3_id.present?
          @inventory_products = @store.inventory_products.where(updated_hash).uniq
        elsif category2_id.present?
          @inventory_products = InventoryCategory2.find(category2_id).inventory_products.where(updated_hash).uniq
        elsif category1_id.present?
          @inventory_products = InventoryCategory1.find(category1_id).inventory_category3s.map { |c| c.inventory_products.where(updated_hash) }.flatten.uniq
        else
          @inventory_products = @store.inventory_products.where(updated_hash).uniq
        end
        @select_inventory = true
      else
        @srn = Srn.new
        @srn_all = Srn.order(updated_at: :desc).page(params[:page]).per(10)
      end
      if request.xhr?
        render "admins/inventories/srn/srn.js"
      else
        render "admins/inventories/srn/srn"
      end
    end

    def create_srn
      @srn = Srn.new srn_params
      if @srn.save
        Organization
        CompanyConfig.first.increase_inv_last_srn_no
        flash[:notice] = "Successfully created."
      else
        flash[:error] = "Unable to save. Please verify any validations"
      end
      redirect_to srn_admins_inventories_url
    end

    def gin
      case params[:gin_callback]
      when "search_srn"
        search_srn = params[:search_srn].except("srn_date_from", "srn_date_to").map{|k, v| "#{k} like '%#{v}%'"}.join(" and ")
        @srns = Srn.where(search_srn)
        @srns = @srns.where("created_at >= :start_date AND created_at <= :end_date", {start_date: params[:search_srn][:srn_date_from], end_date: params[:search_srn][:srn_date_to]}) if params[:search_srn][:srn_date_from].present? and params[:search_srn][:srn_date_to].present?
      when "select_srn"
        Inventory
        Organization
        @srn = Srn.find params[:srn_id]
        @gin = @srn.gins.build store_id: @srn.store_id
        @srn.srn_items.where(closed: false).each do |srn_item|
          Rails.cache.delete([ :gin, :grn_serial_items, srn_item.id ])
          Rails.cache.delete([ :gin, :grn_batches, srn_item.id ])
          # not null: returned_quantity
          @gin.gin_items.build product_id: srn_item.product_id, srn_item_id: srn_item.id, returnable: srn_item.returnable, spare_part: srn_item.spare_part#, currency_id: srn_item.gin_items.first.currency_id#, product_condition_id: srn_item., 
        end
      end

      if request.xhr?
        render "admins/inventories/gin/gin.js"
      else
        render "admins/inventories/gin/gin"
      end
      
    end

    def batch_or_serial_for_gin
      Inventory
      Grn
      Srn
      Gin

      if params[:batch_or_serial] == "issued_qty"
        if params[:grn_serial_item_ids].present?
          grn_items = GrnSerialItem.where(id: params[:grn_serial_item_ids])
          Rails.cache.write([ :gin, :grn_serial_items, params[:srn_item_id].to_i ], grn_items)
          @count = grn_items.count
        elsif params[:grn_batch_ids].present?
          grn_batches = GrnBatch.where(id: params[:grn_batch_ids])
          params[:recieved_quantity].each do |k, v|
            grn_batches.select{|b| b.gin_sources.build(issued_quantity: v) if b.id == k.to_i }
          end

          Rails.cache.write([ :gin, :grn_batches, params[:srn_item_id].to_i ], grn_batches)
          @count = params[:recieved_quantity].values.sum
        else
          Rails.cache.delete([ :gin, :grn_serial_items, params[:srn_item_id].to_i ])
          Rails.cache.delete([ :gin, :grn_batches, params[:srn_item_id].to_i ])
        end

        render "admins/inventories/gin/batch_or_serial_for_gin" and return

      end
      @store = Organization.find params[:store_id]
      @product = InventoryProduct.find params[:product_id]
      @inventory = @product.inventories.find_by_store_id params[:store_id]
      @srn_item = SrnItem.find params[:srn_item_id]
      @grn_items = @product.grn_items.joins(:grn).where("inventory_not_updated = false and remaining_quantity > 0 and inv_grn.store_id = #{@store.id}").order("inv_grn.created_at #{@product.fifo ? 'ASC' : 'DESC' }")
      render "admins/inventories/gin/batch_or_serial_for_gin"

    end

    def create_gin
      Srn
      Organization
      Inventory
      @gin = Gin.new gin_params

      @gin.gin_items.each{|gin_item| @gin.gin_items.delete(gin_item) if gin_item.new_record? and gin_item.issued_quantity.to_f <= 0 }

      @gin.gin_items.each do |gin_item|
        if gin_item.srn_item.issue_terminated
          gin_item.issued_quantity = 0

          gin_item.srn_item.update closed: true

        end

        # gin_item.issued_quantity = gin_item.srn_item.gin_items.sum(:issued_quantity) if gin_item.issued_quantity > gin_item.srn_item.gin_items.sum(:issued_quantity)
        gin_item.issued_quantity = gin_item.srn_item.quantity - gin_item.srn_item.gin_items.sum(:issued_quantity) if gin_item.issued_quantity.to_f > gin_item.srn_item.gin_items.sum(:issued_quantity)

        if gin_item.issued_quantity > 0
          unless gin_item.srn_item.main_product_id.present?
            store = @gin.store
            product = gin_item.inventory_product
            @inventory = product.inventories.find_by_store_id store.id
            # if product.inventory_product_info.need_serial #Issue Serial Item
            Rails.cache.fetch([ :gin, :grn_serial_items, gin_item.srn_item_id.to_i ]).to_a.each do |grn_serial_item|
              product_id = grn_serial_item.inventory_serial_item.product_id

              tot_cost_price = grn_serial_item.grn_item.current_unit_cost.to_d + grn_serial_item.inventory_serial_item.inventory_serial_items_additional_costs.sum(:cost).to_d #inventory_serial_items_additional_costs
              gin_item.currency_id  = grn_serial_item.grn_item.currency_id

              # iss_grn_serial_item_id  = grn_serial_item.id
              # iss_grn_item_id  = grn_serial_item.grn_item_id

              grn_serial_item.update remaining: false

              grn_serial_item.grn_item.decrement! :remaining_quantity, 1

              grn_serial_item.inventory_serial_item.update inv_status_id: InventorySerialItemStatus.find_by_code("NA").id, updated_by: current_user.id

              [:stock_quantity, :available_quantity].each do |attrib|
                grn_serial_item.inventory_serial_item.inventory.increment! attrib, 1
              end

              gin_item.gin_sources.build(grn_item_id: grn_serial_item.grn_item_id, grn_serial_item_id: grn_serial_item.id, issued_quantity: 1, unit_cost: tot_cost_price, returned_quantity: 0)#inv_gin_source

              # issued = true
              # iss_quantity += 1

            end

            # elsif product.inventory_product_info.need_batch #Issue Batch Item
            Rails.cache.fetch([ :gin, :grn_batches, gin_item.srn_item_id.to_i ]).to_a.each do |grn_batch|
              gin_source = grn_batch.gin_sources.select{|g| g.new_record? }.first
              grn_batch_issued_qty = gin_source.issued_quantity

              if grn_batch.remaining_quantity > 0 and grn_batch.remaining_quantity.to_f >= grn_batch_issued_qty.to_f# and grn_batch.grn_item.grn.store_id == gin.store_id
                product_id = grn_batch.grn_item.product_id

                tot_cost_price  = grn_batch.grn_item.current_unit_cost
                gin_item.currency_id  = grn_batch.grn_item.currency_id

                # iss_grn_serial_item_id  = nil
                iss_grn_item_id  = grn_batch.grn_item_id
                iss_grn_batch_id  = grn_batch.id
                # iss_grn_serial_part_id  = nil
                # iss_main_part_grn_serial_item_id  = nil


                # @grn_batch.update "remaining_quantity = remaining_quantity-#{grn_batch_issued_qty}"#remaining_quantity: (grn_batch.remaining_quantity- grn_batch_issued_qty)
                @grn_batch.decrement! :remaining_quantity, grn_batch_issued_qty
                @grn_batch.grn_item.decrement! :remaining_quantity, grn_batch_issued_qty

                # @grn_batch.grn_item.update "remaining_quantity = remaining_quantity-#{grn_batch_issued_qty}"#remaining_quantity: (grn_batch.grn_item.remaining_quantity- grn_batch_issued_qty)
                [:stock_quantity, :available_quantity].each do |attrib|
                  @inventory.decrement! attrib, grn_batch_issued_qty if @inventory.present?
                end
                # @inventory.update "stock_quantity = stock_quantity-#{grn_batch_issued_qty} and available_quantity = available_quantity-#{grn_batch_issued_qty}" if @inventory.present?

                gin_source.attributes = gin_source.attributes.merge(grn_batch_id: iss_grn_batch_id, unit_cost: tot_cost_price, returned_quantity: 0)#inv_gin_source                    

                # issued = true
                # iss_quantity += grn_batch_issued_qty
              end
            end

            if !(product.inventory_product_info.need_batch or product.inventory_product_info.need_serial) #Issue Non Serial / Non Batch Item
              @grn_items = product.grn_items.joins(:grn).where("inventory_not_updated = false and remaining_quantity > 0 and inv_grn.store_id = #{store.id}").order("inv_grn.created_at #{product.fifo ? 'ASC' : 'DESC' }")

              iss_quantity1 = 0
              @grn_items.each do |grn_item|
                grn_item_issued_qty = grn_item.remaining_quantity >= gin_item.issued_quantity ? gin_item.issued_quantity : grn_item.remaining_quantity

                # if grn_item.remaining_quantity >= grn_item_issued_qty# and (gin_item.issued_quantity > iss_quantity)# and grn_item.grn.store_id == gin.store_id

                # product_id = grn_item.product_id
                tot_cost_price  = grn_item.current_unit_cost

                grn_item.decrement! :remaining_quantity, grn_item_issued_qty

                # grn_item.update "remaining_quantity = remaining_quantity-#{grn_item_issued_qty}"#remaining_quantity: (grn_item.remaining_quantity - grn_item_issued_qty)
                [:stock_quantity, :available_quantity].each do |attrib|
                  @inventory.decrement! attrib, grn_item_issued_qty if @inventory.present?
                end
                # @inventory.update "stock_quantity = stock_quantity-#{grn_item_issued_qty} and available_quantity = available_quantity-#{grn_item_issued_qty}" if @inventory.present?

                gin_item.gin_sources.build(grn_item_id: grn_item.id, issued_quantity: grn_item_issued_qty, unit_cost: tot_cost_price, returned_quantity: 0)#inv_gin_source

                # issued = true
                iss_quantity1 += grn_item_issued_qty
                # end
              end
              gin_item.issued_quantity = iss_quantity
            end

          end
        end

        # if issued
          #gin = @srn_item.srn.gins.create(created_by: current_user.id, created_at: DateTime.now, gin_no: CompanyConfig.first.increase_inv_last_gin_no, store_id: @srn_item.srn.store.id, remarks: (@spare_part_note || @onloan_note) )#inv_gin
        gin_item.returned_quantity = 0
        # gin_item.attributes = gin_item.attributes.merge(
        # # issued_quantity: iss_quantity,
        # # currency_id: currency_id,
        # returned_quantity: 0,
        # # returnable: returnable,
        # # spare_part: @spare_part
        # )#inv_gin_item

        gin_item.srn_item.update closed: (gin_item.srn_item.quantity <= gin_item.srn_item.gin_items.sum(:issued_quantity))

        # save_gin = true

        # else
        #   flash[:error] = iss_from_inventory_not_updated ? "Trying to issue from inventory not updated GRN" : "Stock Remaining Quantity is zero."
        # end

      end

      if @gin.gin_items.any? 
        @gin.attributes = @gin.attributes.merge(created_by: current_user.id, gin_no: CompanyConfig.first.increase_inv_last_gin_no )#inv_gin
        @gin.save

        @gin.srn.update closed: true if @gin.srn.srn_items.all?{|srn_item| srn_item.closed }

        flash[:notice] = "Issued."
      else
        flash[:error] = "Issue Failed."
      end

      redirect_to gin_admins_inventories_url
    end

    private

      def product_category_params
        params.require(:product_category).permit(:name, :sla_id)
      end

      def q_and_a_params
        params.require(:inventory_shelf).permit(:description)
      end

      def inventory_params
        params.require(:inventory).permit(:id, :product_id, :store_id, :bin_id, :stock_quantity, :reserved_quantity, :available_quantity, :reorder_level, :reorder_quantity, :max_quantity, :safty_stock_quantity, :lead_time_in_days, :inventory_bin, :remarks, :created_by)
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

      def inventory_category1_params
        params.require(:inventory_category1).permit(:code, :name, :created_by, :created_by)
      end

      def inventory_category3_params
        params.require(:inventory_category3).permit(:code, :name, :created_by, :category2_id)
      end

      def inventory_category2_params
        params.require(:inventory_category2).permit(:code, :name, :created_by, :category1_id)
      end

      def inventory_product_params
        params.require(:inventory_product).permit(:category3_id, :serial_no, :serial_no_order, :sku, :legacy_code, :description, :model_no, :product_no, :spare_part_no, :fifo, :active, :spare_part, :unit_id, :created_by, :updated_by, :non_stock_item, inventory_product_info_attributes: [:picture, :secondary_unit_id, :issue_fractional_allowed, :per_secondery_unit_conversion, :need_serial, :need_batch, :country_id, :manufacture_id, :average_cost, :standard_cost, :currency_id, :remarks])
      end

      def inventory_product_info_params
        params.require(:inventory_product_info).permit(:secondary_unit_id, :manufacture_id, :country_id, :currency_id, :average_cost, :standard_cost, :issue_fractional_allowed, :per_secondery_unit_conversion, :need_serial,:need_batch)
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
        params.require(:inventory_unit).permit(:unit, :base_unit_conversion, :per_base_unit, :description, :created_by, :updated_by)
      end

      def inventory_po_item_params
        params.require(:inventory_po_item).permit(:id, grn_items_attributes: [:recieved_quantity, :remarks, grn_batches_attributes: [:id, :recieved_quantity, :_destroy, inventory_batch_attributes: [:id, :_destroy, :lot_no, :batch_no, :manufatured_date, :expiry_date, :remarks, ]], grn_serial_items_attributes: [:id, :_destroy, :recieved_quantity, inventory_serial_item_attributes: [:id, :_destroy, :inventory_id, :product_id, :inv_status_id, :created_by, :serial_no, :ct_no, :manufatured_date, :expiry_date, :scavenge, :parts_not_completed, :damage, :used, :repaired, :reserved, :product_condition_id, :remarks, inventory_serial_warranties_attributes: [:id, :_destroy, inventory_warranty_attributes: [:id, :_destroy, :created_by, :start_at, :end_at, :period_part, :period_labour, :period_onsight, :remarks, :warranty_type_id]]]]])
      end

      def grn_item_params
        params.require(:grn_item).permit(:id, :recieved_quantity, :unit_cost, :remarks, grn_batches_attributes: [:id, :recieved_quantity, :remaining_quantity, :_destroy, inventory_batch_attributes: [:id, :_destroy, :inventory_id, :product_id, :created_by, :lot_no, :batch_no, :manufatured_date, :expiry_date, :remarks, inventory_batch_warranties_attributes: [:id, :_destroy, inventory_warranty_attributes: [:id, :_destroy, :created_by, :start_at, :end_at, :period_part, :period_labour, :period_onsight, :remarks, :warranty_type_id]] ]], grn_serial_items_attributes: [:id, :_destroy, :recieved_quantity, :remaining, inventory_serial_item_attributes: [:id, :_destroy, :inventory_id, :product_id, :inv_status_id, :created_by, :serial_no, :ct_no, :manufatured_date, :expiry_date, :scavenge, :parts_not_completed, :damage, :used, :repaired, :reserved, :product_condition_id, :remarks, inventory_serial_warranties_attributes: [:id, :_destroy, inventory_warranty_attributes: [:id, :_destroy, :created_by, :start_at, :end_at, :period_part, :period_labour, :period_onsight, :remarks, :warranty_type_id]]]])
      end

      def inventory_serial_item_params
        params.require(:inventory_serial_item).permit(:id, :inventory_id, :product_id, :inv_status_id, :created_by, :serial_no, :ct_no, :manufatured_date, :expiry_date, :scavenge, :parts_not_completed, :damage, :used, :repaired, :reserved, :product_condition_id, :remarks, inventory_serial_warranties_attributes: [:id, :_destroy, inventory_warranty_attributes: [:id, :_destroy, :created_by, :start_at, :end_at, :period_part, :period_labour, :period_onsight, :remarks, :warranty_type_id]])
      end

      def grn_params
        params.require(:grn).permit(:remarks, :po_id, :po_no, :supplier_id)
      end

      def srn_params
        params.require(:srn).permit(:id, :srn_no, :requested_module_id, :created_by, :store_id, :required_at, :remarks, :so_no, :so_customer_id, srn_items_attributes: [:id, :product_id, :main_product_id, :quantity, :remarks, :_destroy, :returnable, :spare_part])
      end

      def gin_params
        params.require(:gin).permit(:id, :store_id, :srn_id, :remarks, gin_items_attributes: [:id, :_destroy, :product_id, :srn_item_id, :issued_quantity, :product_condition_id, :remarks, :returnable, :spare_part ])
      end

  end
end