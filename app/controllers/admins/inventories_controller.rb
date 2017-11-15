module Admins
  class InventoriesController < ApplicationController
    include Backburner::Performable

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

      when params[:inventory_category23_id].present?
        inventory_product_category3 = InventoryCategory3.find params[:inventory_category23_id]
        @inventory_products_all = inventory_product_category3.inventory_products
        @render_template = "inventory_products_for_categories"
      end
      @renderDom = params[:render_dom]
    end

    def delete_inventory_product_form
      Product
      Inventory
      @inv_product = InventoryProduct.find params[:product_id]
      if @inv_product.present?
        @inv_product.inventory_product_info.delete
        @inv_product.delete
      end
      respond_to do |format|
        format.html { redirect_to product_admins_inventories_path }
      end
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
            flash[:notice] = "Successfully saved."
          else
            flash[:alert] = "Unable to save. Please review..."

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
        @inventory_products_all = []
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
            flash[:notice] = "Successfully saved."
          else
            flash[:alert] = "Unable to save. Please review."
          end
        else
          @inventory_product = InventoryProduct.new
        end
        # @inventory_product_all = InventoryProduct.order(updated_at: :desc).select{ |i| i.persisted? }
        @inventory_product_all = Kaminari.paginate_array(InventoryProduct.order( updated_at: :desc)).page(params[:page]).per(10)
      end
    end

    def search_product_inventories
      Inventory
      Product
      if params[:search].present?
        refined_inventory_product = params[:search_inventory].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")

      end
      params[:query] = refined_inventory_product
      @inventory_product_list = InventoryProduct.search(params)

      render "admins/inventories/product"
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

    def pos
      # refined_search = "closed:false"
      Inventory
      if params[:po_id].present?
        @po = InventoryPo.find params[:po_id]

        render "admins/inventories/po/po"
      else
        if params[:search].present?
          refined_inventory_po = params[:po].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")

          refined_search = [refined_inventory_po, refined_search].map{|v| v if v.present? }.compact.join(" AND ")
        end

        params[:query] = refined_search
        @pos = InventoryPo.search(params)

        render "admins/inventories/po/pos"
      end
    end

    def close_po
      Inventory
      if params[:po_id].present?

        @po = InventoryPo.find params[:po_id]
        if params[:form_param].present?
          if @po.update po_params
            # @po.inventory_po_items.update_all closed: @po.closed
            if @po.inventory_po_items.all? { |p| p.closed }
              @po.update closed: true
              sleep 3
            end
          end

          if @po.inventory_po_items.empty? and @po.closed and @po.grns.empty?
            @po.destroy
            @po.update_index
            sleep 3
          end

        end
      end

      if request.xhr?
        render "admins/inventories/po/pos.js"
      else
        redirect_to pos_admins_inventories_path(close_param: params[:po_id])
      end

    end

    def close_srn
      Inventory
      Ticket
      @srn = Srn.find params[:srn_id]
      unless params[:close_srn].present?
        if @srn.update srn_params
          @srn.srn_items.each do |srn_item|
            if srn_item.issue_terminated
              srn_item.update closed: true, issue_terminated_at: DateTime.now, issue_terminated_by: current_user.id
            end
          end

          if @srn.srn_items.all? { |p| p.closed }
            @srn.update closed: true, remarks: "Closed"
            sleep 3
          end
        end

      end

      if request.xhr?
        render "admins/inventories/srn/srn.js"
      else
        redirect_to srns_admins_inventories_url(srn_id: @srn.id)
      end

    end

    def close_prn
      Inventory
      Ticket
      @prn = InventoryPrn.find params[:prn_id]
      unless params[:close_prn].present?
        if @prn.update prn_params
          if @prn.inventory_prn_items.empty?
            @prn.delete
            @prn.update_index
          end
        end
        sleep 3

      end

      if request.xhr?
        render "admins/inventories/prn/prn.js"
      else
        redirect_to search_receives_admins_searches_url
      end

    end

    def view_prn

    end

    def view_srn
      render "admins/inventories/srn/view_srn"
    end

    def view_gin
      render "admins/inventories/gin/view_gin"
    end

    def grn
      Inventory
      Grn
      Organization

      case params[:purchase_order]
      when "yes"
        @stores = Organization.stores
        @render_template = "search_po"

      when "srr"
        @stores = Organization.stores
        @render_template = "search_srr"

      when "no"
        @render_template = "search_inventory"

      when "search_inventory"
        @store = Organization.find params[:store_id]
        session[:store_id] = @store.id

        Rails.cache.fetch([:po_item_ids, session[:pre_grn_arrived_time].to_i]).to_a.each do |poid|
          Rails.cache.delete([:grn_item, poid, session[:pre_grn_arrived_time].to_i] )
        end

        Rails.cache.delete([:po_item_ids, session[:pre_grn_arrived_time].to_i])

        refined_search = "stores.id:#{@store.id}"
        if params[:search].present?
          refined_inventory_product = params[:search_inventory][:inventory_product].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")

          refined_search = [refined_inventory_product, refined_search].map{|v| v if v.present? }.compact.join(" AND ")

        end

        params[:query] = refined_search

        @inventory_products = InventoryProduct.search(params)

        @inventory_products.to_a.each do |ipid|
          # Rails.cache.delete([:grn_item, :i_product, ipid.id, session[:pre_grn_arrived_time].to_i ])
          Rails.cache.delete([:grn_item, ipid.id, session[:pre_grn_arrived_time].to_i ])
          Rails.cache.delete([:serial_item, :i_product, ipid.id, session[:pre_grn_arrived_time].to_i ])
        end

        Rails.cache.delete([:inventory_product_ids, session[:pre_grn_arrived_time].to_i ])
        Rails.cache.delete([:srr_item_source_ids, session[:pre_grn_arrived_time].to_i ])

        @render_template = "select_inventory"

      when "select_inventory"
        @inventory_product = InventoryProduct.find params[:inventory_product_id]
        @bulk_upload_serials = Rails.cache.fetch([ :serial_item, @inventory_product.class.to_s.to_sym, @inventory_product.id, session[:grn_arrived_time].to_i ]).to_a

        # @grn_item = Rails.cache.fetch([:grn_item, :i_product, @inventory_product.id, session[:grn_arrived_time].to_i ]) { GrnItem.new }
        @grn_item = Rails.cache.fetch([:grn_item, @inventory_product.id, session[:grn_arrived_time].to_i ]) { GrnItem.new }

        @render_template = "grn_item"
        
      when "search_po"
        refined_search = "closed:false"

        if params[:search].present?
          refined_inventory_po = params[:po].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")

          refined_search = [refined_inventory_po, refined_search].map{|v| v if v.present? }.compact.join(" AND ")

        end

        params[:query] = refined_search
        @pos = InventoryPo.search(params)

        session[:store_id] = params[:po]["store.id"]

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
        @bulk_upload_serials = Rails.cache.fetch([ :serial_item, @po_item.class.to_s.to_sym, @po_item.id, session[:grn_arrived_time].to_i ]).to_a

        @grn_item = Rails.cache.fetch([:grn_item, params[:po_item_id].to_i, session[:grn_arrived_time].to_i ]) { GrnItem.new }
        @already_recieved = @po_item.inventory_po.grns.to_a.sum{|grn| grn.grn_batches.any? ? grn.grn_batches.sum(:recieved_quantity) : grn.grn_items.sum(:recieved_quantity) }

        @render_template = "grn_item"

      when "search_srr"
        refined_search = "closed:false"

        if params[:search].present?
          refined_inventory_srr = params[:srr].map{ |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")

          refined_search = [refined_inventory_srr, refined_search].map{|v| v if v.present? }.compact.join(" AND ")

        end

        params[:query] = refined_search
        @srrs = Srr.search(params)

        session[:store_id] = params[:srr]["store.id"]

        Rails.cache.delete([:inventory_product_ids])
        Rails.cache.delete([:po_item_ids])
        Rails.cache.delete([:srr_item_ids])
        session[:po_id] = nil
        session[:srr_id] = nil
        @render_template = "select_srr"

      when "select_srr"
        @srr = Srr.find params[:srr_id]

        session[:srr_id] = @srr.id

        @render_template = "new_grn_with_srr"

      when "select_srr_item"
        Srr
        Gin

        @srr_item = SrrItem.find params[:srr_item_id]

        # @grn_item = Rails.cache.fetch([:grn_item, params[:srr_item_id].to_i, session[:grn_arrived_time].to_i ]) do
        #   @srr_item.grn_items.build product_id: @srr_item.product_id, recieved_quantity: srr_item_source.returned_quantity, remaining_quantity: srr_item_source.returned_quantity, mcurrent_unit_cost: grn_item.unit_cost, currency_id: @srr_item.currency_id

        # end

        @render_template = "grn_item_srr"

      else
        session[:pre_grn_arrived_time] = (session[:grn_arrived_time] or Time.now.strftime("%H%M%S"))

        session[:grn_arrived_time] = Time.now.strftime("%H%M%S")

      end
      render "admins/inventories/grn/grn"
    end

    def upload_grn_file
      Inventory
      if params[:new_bulk_upload_serial].present?
        accessible_inventory_serial_item_params = inventory_serial_item_params

        Rails.cache.write([ :serial_item, params[:refer_resource_class].to_sym, params[:refer_resource_id].to_i, session[:grn_arrived_time].to_i ], Rails.cache.fetch([:bulk_serial, params[:timestamp].to_i ]).map { |s| InventorySerialItem.new(accessible_inventory_serial_item_params.merge(serial_no: s[0], ct_no: s[1])) })

        Rails.cache.delete( [:bulk_serial, params[:timestamp].to_i ] )

      elsif params[:clear_import].present?
        Rails.cache.delete([ :serial_item, :i_product, params[:inventory_product_id].to_i, session[:grn_arrived_time].to_i ])

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
        session[:time_store_for_buck_upload] = @timestore.to_i

        serial_nos = []
        Rails.cache.fetch([:bulk_serial, @time_store.to_i ]) { (@sheet.last_row - 1).times.map{|m| serial_nos << @sheet.row(m+2)[0]; @sheet.row(m+2)}.compact }

        @available_serial_items = InventorySerialItem.joins(:inventory).where(serial_no: serial_nos, inv_inventory: {store_id: session[:store_id]}).select(:serial_no).distinct()


        File.delete(File.join(Rails.root, "public", "uploads", uploaded_io.original_filename))

      end
      render "admins/inventories/grn/upload_grn_file"

    end

    def initiate_grn_for_i_product
      Inventory
      Grn
      @inventory_product = InventoryProduct.find params[:inventory_product_id]
      @grn_item = GrnItem.new grn_item_params

      @bulk_upload_serials = Rails.cache.fetch([ :serial_item, @inventory_product.class.to_s.to_sym, @inventory_product.id, session[:grn_arrived_time].to_i ]).to_a

      need_serial = @inventory_product.inventory_product_info.need_serial.present?
      need_batch = @inventory_product.inventory_product_info.need_batch.present?

      validate = if !need_serial and need_batch
        @grn_item.grn_batches.any?
      elsif need_serial and !need_batch
        @grn_item.grn_serial_items.any? or @bulk_upload_serials.any?

      else
        true
      end

      if params[:next].present?
        if validate and @grn_item.valid?
          if not Rails.cache.fetch([:inventory_product_ids, session[:grn_arrived_time].to_i]).to_a.include? params[:inventory_product_id].to_i
            a = Rails.cache.fetch([:inventory_product_ids, session[:grn_arrived_time].to_i]).to_a
            a << params[:inventory_product_id].to_i
            Rails.cache.write([:inventory_product_ids, session[:grn_arrived_time].to_i], a)
          end
          # Rails.cache.write([:grn_item, :i_product, @inventory_product.id, session[:grn_arrived_time].to_i ], @grn_item)
          Rails.cache.write([:grn_item, @inventory_product.id, session[:grn_arrived_time].to_i ], @grn_item)

          if Rails.cache.fetch([:inventory_product_ids, session[:grn_arrived_time].to_i]).to_a.count > 0
            @grn = Grn.new

          end
        else
          @grn_item.errors[:base] << "There are something wrong. Please check Serial item or Batches or Non Serials or Non Batches"
          a = Rails.cache.fetch([:inventory_product_ids, session[:grn_arrived_time].to_i]).to_a
          a.delete(params[:inventory_product_id].to_i)
          Rails.cache.write([:inventory_product_ids, session[:grn_arrived_time].to_i], a)
        end
      elsif params[:cancel]
        a = Rails.cache.fetch([:inventory_product_ids, session[:grn_arrived_time].to_i]).to_a
        a.delete(params[:inventory_product_id].to_i)
        Rails.cache.write([:inventory_product_ids, session[:grn_arrived_time].to_i], a)
        if Rails.cache.fetch([:inventory_product_ids, session[:grn_arrived_time].to_i]).to_a.count > 0
          @grn = Grn.new

        end

        Rails.cache.delete([:grn_item, :i_product, @inventory_product.id ] )
        # Rails.cache.delete([:grn_item, @inventory_product.id ] )
        # Rails.cache.delete([ :serial_item, :i_product, @inventory_product.id ])
      end

      # @inventory_products = Kaminari.paginate_array(InventoryProduct.where(id: Rails.cache.fetch([:inventory_product_ids]).to_a)).page(params[:page]).per(10)
      search_inventory_products = Tire.search 'inventory_products', query: {constant_score: {filter: {terms: {id: Rails.cache.fetch([:inventory_product_ids, session[:grn_arrived_time].to_i]).to_a}}}}
      @inventory_products = Kaminari.paginate_array(search_inventory_products.results.to_a).page(params[:page]).per(10)

      render "admins/inventories/grn/grn"
    end

    def initialize_grn
      Inventory
      Grn
      @po_item = InventoryPoItem.find params[:po_item_id]
      @already_recieved = @po_item.inventory_po.grns.to_a.sum{|grn| grn.grn_batches.any? ? grn.grn_batches.sum(:recieved_quantity) : grn.grn_items.sum(:recieved_quantity) }

      @grn_item = GrnItem.new grn_item_params

      @bulk_upload_serials = Rails.cache.fetch([ :serial_item, @po_item.class.to_s.to_sym, @po_item.id, session[:grn_arrived_time].to_i ]).to_a

      need_serial = @po_item.inventory_prn_item.inventory_product.inventory_product_info.need_serial.present?
      need_batch = @po_item.inventory_prn_item.inventory_product.inventory_product_info.need_batch.present?

      validate = if !need_serial and need_batch
        @grn_item.grn_batches.any?
      elsif need_serial and !need_batch
        @grn_item.grn_serial_items.any? or @bulk_upload_serials.any?
      else
        true
      end

      if params[:next].present?
        if validate and @grn_item.valid?

          if not Rails.cache.fetch([:po_item_ids, session[:grn_arrived_time].to_i]).to_a.include? params[:po_item_id].to_i
            a = Rails.cache.fetch([:po_item_ids, session[:grn_arrived_time].to_i]).to_a
            a << params[:po_item_id].to_i
            Rails.cache.write([:po_item_ids, session[:grn_arrived_time].to_i], a)

          end

          Rails.cache.write([:grn_item, @po_item.id, session[:grn_arrived_time].to_i], @grn_item )

          if Rails.cache.fetch([:po_item_ids, session[:grn_arrived_time].to_i]).to_a.count > 0 #@po_item.inventory_po.inventory_po_items.count
            @grn = Grn.new po_id: session[:po_id], supplier_id: @po_item.inventory_po.supplier_id

          end

        else
          @grn_item.errors[:base] << "There are something wrong. Please check Serial item or Batches or Non Serials or Non Batches"

          a = Rails.cache.fetch([:po_item_ids, session[:grn_arrived_time].to_i]).to_a
          a.delete(params[:po_item_id].to_i)
          Rails.cache.write([:po_item_ids, session[:grn_arrived_time].to_i], a)

        end

      elsif params[:cancel]

        a = Rails.cache.fetch([:po_item_ids, session[:grn_arrived_time].to_i]).to_a
        a.delete(params[:po_item_id].to_i)
        Rails.cache.write([:po_item_ids, session[:grn_arrived_time].to_i], a)

        Rails.cache.delete([:grn_item, @po_item.id, session[:grn_arrived_time].to_i] )

      end

      render "admins/inventories/grn/grn"
    end

    def initiate_grn_for_srr
      Srr
      Grn
      Gin
      Inventory
      Damage
      Organization

      @srr_item = SrrItem.find params[:srr_item_id]

      if params[:srr_item_source].present?
        srr_item_source_ids = params[:srr_item_source].keep_if{|key, value| value["accept"] == "1" }.keys

        srr_item_source_ids.each do |srr_item_source_id|
          srr_item_source = SrrItemSource.find srr_item_source_id

          @grn_item = @srr_item.grn_items.build params[:grn_item][srr_item_source_id].permit(:remarks, :unit_cost)

          @grn_item.attributes = {
            product_id: @srr_item.product_id,
            recieved_quantity: srr_item_source.returned_quantity,
            remaining_quantity: srr_item_source.returned_quantity,
            reserved_quantity: 0,
            damage_quantity: 0,
            current_unit_cost: srr_item_source.unit_cost,
            currency_id: srr_item_source.currency_id,
          }

          if params[:next].present?
            if @grn_item.valid?

              if not Rails.cache.fetch([:srr_item_source_ids, session[:grn_arrived_time].to_i]).to_a.include? srr_item_source_id
                a = Rails.cache.fetch([:srr_item_source_ids, session[:grn_arrived_time].to_i]).to_a
                a << srr_item_source_id
                Rails.cache.write([:srr_item_source_ids, session[:grn_arrived_time].to_i], a)

              end

              damaged = (params[:damage_request_source].present? and params[:damage_request_source][srr_item_source_id]['quantity'].to_f > 0)

              # For Serial Item
              # if params[:inventory_serial_item] and params[:inventory_serial_item][srr_item_source_id].present?
              if @grn_item.inventory_product.product_type == 'Serial'
                issued_inventory_serial_item = srr_item_source.gin_source.grn_serial_item.inventory_serial_item

                issued_inventory_serial_item.attributes = params[:inventory_serial_item][srr_item_source_id].permit(:scavenge, :parts_not_completed, :damage, :used, :repaired, :reserved) if params[:inventory_serial_item].present?

                issued_inventory_serial_item.inv_status_id = InventorySerialItemStatus.find_by_code('AV').id unless issued_inventory_serial_item.damage

                # @grn_item.inventory_serial_items << issued_inventory_serial_item
                @grn_item.grn_serial_items.build serial_item_id: issued_inventory_serial_item.id

                damaged = issued_inventory_serial_item.damage

                Rails.cache.write([:extra_objects, srr_item_source.id, session[:grn_arrived_time].to_i], {inventory_serial_item: issued_inventory_serial_item } )

              end

              if @grn_item.inventory_product.product_type == "Batch"
                @grn_item.grn_batches.build( inventory_batch_id: srr_item_source.gin_source.grn_batch.inventory_batch_id, recieved_quantity: srr_item_source.returned_quantity, remaining_quantity: srr_item_source.returned_quantity )

              end

              if damaged
                if params[:damage_request].present?
                  damage_request = Damage.new({
                    store_id: @srr_item.srr.store_id,
                    product_id: @srr_item.product_id,
                    grn_batch_id: nil,
                    grn_serial_item_id: nil,
                    grn_serial_part_id: nil,
                    spare_part: @grn_item.inventory_product.spare_part,
                    unit_cost: @grn_item.unit_cost,
                    currency_id: @grn_item.currency_id,
                    srr_item_id: @srr_item.id,
                    product_condition_id: nil,
                    repair_quantity: 0,
                    spare_quantity: 0,
                    disposal_quantity: 0,
                    disposed_quantity: 0
                  })

                  damage_request.attributes = params[:damage_request][srr_item_source_id].permit(:damage_reason_id)
                  damage_request.attributes = params[:damage_request_source][srr_item_source_id].permit(:quantity)

                  @grn_item.damage_quantity = damage_request.quantity

                end

                if damage_request.present?

                  extra_objects = (Rails.cache.fetch([:extra_objects, srr_item_source.id, session[:grn_arrived_time].to_i] ) || {} )

                  extra_objects[:damage_request] = damage_request
                  Rails.cache.write([:extra_objects, srr_item_source.id, session[:grn_arrived_time].to_i], extra_objects )

                end

              end

              Rails.cache.write([:grn_item, srr_item_source.id, session[:grn_arrived_time].to_i], @grn_item )

              if Rails.cache.fetch([:srr_item_source_ids, session[:grn_arrived_time].to_i]).to_a.count > 0 #@srr_item.inventory_po.inventory_srr_items.count
                @grn = Grn.new srr_id: session[:srr_id]#, supplier_id: @srr_item.inventory_po.supplier_id

              end

            else
              @grn_item.errors[:base] << "There are something wrong. Please check Serial item or Batches or Non Serials or Non Batches"

              a = Rails.cache.fetch([:srr_item_source_ids, session[:grn_arrived_time].to_i]).to_a
              a.delete(params[:srr_item_source_id].to_i)
              Rails.cache.write([:srr_item_source_ids, session[:grn_arrived_time].to_i], a)

            end

          elsif params[:cancel]

            a = Rails.cache.fetch([:srr_item_source_ids, session[:grn_arrived_time].to_i]).to_a
            a.delete(params[:srr_item_source_id].to_i)
            Rails.cache.write([:srr_item_source_ids, session[:grn_arrived_time].to_i], a)

            Rails.cache.delete([:grn_item, srr_item_source.id, session[:grn_arrived_time].to_i] )
            Rails.cache.delete([:extra_objects, srr_item_source.id, session[:grn_arrived_time].to_i] )

          end

        end

      else
      end
      render "admins/inventories/grn/grn"

    end

    def create_grn
      Inventory
      Organization
      serial_inventories = []

      @grn = Grn.new grn_params
      if @grn.inventory_po.present? # With PO Items
        @grn.store_id = @grn.inventory_po.store_id

      elsif @grn.srr.present?
        @grn.store_id = @grn.srr.store_id

      else # Without PO Items
        @grn.store_id = session[:store_id]
      end
      @grn.created_at = DateTime.now
      @grn.created_by = current_user.id
      # @grn.grn_no = CompanyConfig.first.increase_inv_last_grn_no
      @grn.save!

      # With PO Items
      Rails.cache.fetch([:po_item_ids, session[:grn_arrived_time].to_i]).to_a.each do | po_item_id |
        po_item = InventoryPoItem.find po_item_id
        grn_item = Rails.cache.fetch([ :grn_item, po_item_id, session[:grn_arrived_time].to_i ] )
        grn_item.grn = @grn

        tot_recieved_qty = 0

        bulk_serial_items = Rails.cache.fetch([ :serial_item, po_item.class.to_s.to_sym, po_item.id, session[:grn_arrived_time].to_i ]).to_a

        bulk_serial_items.each do |serial_item|
          grn_item.inventory_serial_items << serial_item

        end

        grn_item.grn_batches.each do |gb| 
          gb.remaining_quantity = gb.recieved_quantity 
          tot_recieved_qty += gb.recieved_quantity
        end

        tot_recieved_qty += grn_item.grn_serial_items.to_a.count

        tot_recieved_qty = grn_item.recieved_quantity if tot_recieved_qty == 0

        grn_item.grn_id = @grn.id
        grn_item.po_item_id = po_item.id
        grn_item.product_id = po_item.inventory_prn_item.product_id
        grn_item.recieved_quantity = grn_item.remaining_quantity = tot_recieved_qty
        grn_item.unit_cost = grn_item.current_unit_cost = po_item.unit_cost_grn
        grn_item.currency_id = grn_item.inventory_product.inventory_product_info.currency_id
        grn_item.inventory_not_updated = false

        inventory = grn_item.inventory_product.inventories.find_by_store_id(@grn.store_id)
        # inventory.stock_quantity += tot_recieved_qty
        # inventory.available_quantity += tot_recieved_qty

        grn_item.grn_item_current_unit_cost_histories.build created_by: current_user.id, current_unit_cost: grn_item.current_unit_cost


        po_item.update closed: (po_item.quantity.to_f <= po_item.grn_items.sum(:recieved_quantity).to_f )

        # serial_inventories << inventory #inventory has to save
        serial_inventories << {id: inventory.id, stock_quantity: tot_recieved_qty, available_quantity: tot_recieved_qty}

        grn_item.save!
        grn_item.update_relation_index
        Rails.cache.delete([:grn_item, po_item_id, session[:grn_arrived_time].to_i] )
        Rails.cache.delete([ :serial_item, po_item.class.to_s.to_sym, po_item.id, session[:grn_arrived_time].to_i ])

      end

      if @grn.inventory_po.present?
        @grn.inventory_po.update closed: @grn.inventory_po.inventory_po_items.all?{ |i| i.closed }
      end

      # Without PO Items
      Rails.cache.fetch([:inventory_product_ids, session[:grn_arrived_time].to_i]).to_a.each do | inventory_product_id |
        inventory_product = InventoryProduct.find inventory_product_id
        # grn_item = Rails.cache.fetch( [:grn_item, :i_product, inventory_product.id, session[:grn_arrived_time].to_i ] )
        grn_item = Rails.cache.fetch( [:grn_item, inventory_product.id, session[:grn_arrived_time].to_i ] )
        grn_item.grn = @grn

        bulk_serial_items = Rails.cache.fetch([ :serial_item, inventory_product.class.to_s.to_sym, inventory_product.id, session[:grn_arrived_time].to_i ]).to_a

        bulk_serial_items.each do |serial_item|
          grn_item.inventory_serial_items << serial_item

        end

        # grn_item.inventory_serial_items << bulk_serial_items if bulk_serial_items.present?
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
        # grn_item.save!

        inventory = grn_item.inventory_product.inventories.find_by_store_id(@grn.store_id)
        # inventory.stock_quantity += tot_recieved_qty
        # inventory.available_quantity += tot_recieved_qty

        grn_item.grn_item_current_unit_cost_histories.build created_by: current_user.id, current_unit_cost: grn_item.current_unit_cost

        # Rails.cache.delete([:grn_item, :i_product, inventory_product.id, session[:grn_arrived_time].to_i ] )

        # serial_inventories << inventory #inventory has to save
        serial_inventories << {id: inventory.id, stock_quantity: tot_recieved_qty, available_quantity: tot_recieved_qty}

        grn_item.save! # this is to update index
        grn_item.update_relation_index

        Rails.cache.delete([:grn_item, inventory_product.id, session[:grn_arrived_time].to_i ] )
        Rails.cache.delete([ :serial_item, inventory_product.class.to_s.to_sym, inventory_product.id, session[:grn_arrived_time].to_i ])
      end

      # With SRR Items
      Rails.cache.fetch([:srr_item_source_ids, session[:grn_arrived_time].to_i]).to_a.each do | srr_item_source_id |

        srr_item_source = SrrItemSource.find srr_item_source_id

        grn_item = Rails.cache.fetch([:grn_item, srr_item_source_id, session[:grn_arrived_time].to_i])

        grn_item.inventory_not_updated = false

        grn_item.srr_item = srr_item_source.srr_item
        grn_item.current_unit_cost = grn_item.unit_cost
        grn_item.grn = @grn


        grn_item.grn_item_current_unit_cost_histories.build created_by: current_user.id, current_unit_cost: grn_item.current_unit_cost

        srr_item_source.srr_item.update closed: (srr_item_source.srr_item.quantity.to_f <= srr_item_source.srr_item.srr_item_sources.sum(:returned_quantity).to_f )

        # grn_item.grn_serial_items.offset(1).destroy_all
        # grn_item.update_index

        inventory = grn_item.inventory_product.inventories.find_by_store_id(@grn.store_id)
        # inventory = srr_item_source.srr_item.inventory_product.inventories.find_by_store_id(srr_item_source.srr_item.srr.store_id)

        # inventory.stock_quantity += grn_item.recieved_quantity
        # inventory.available_quantity += (grn_item.recieved_quantity - grn_item.damage_quantity)
        # inventory.damage_quantity += grn_item.damage_quantity

        # serial_inventories << inventory #inventory has to save
        serial_inventories << {id: inventory.id, stock_quantity: grn_item.recieved_quantity, available_quantity: (grn_item.recieved_quantity - grn_item.damage_quantity), damage_quantity: grn_item.damage_quantity}
        grn_item.save!

        # if grn_item.inventory_product.product_type == "Batch"
        #   grn_item.grn_batches.create( inventory_batch_id: srr_item_source.gin_source.grn_batch.inventory_batch_id, recieved_quantity: srr_item_source.returned_quantity, remaining_quantity: srr_item_source.returned_quantity )

        # end

        if Rails.cache.fetch([ :extra_objects, srr_item_source_id, session[:grn_arrived_time].to_i ] ).present?
          inventory_serial_item = Rails.cache.fetch([ :extra_objects, srr_item_source_id, session[:grn_arrived_time].to_i ] )[:inventory_serial_item]

          damage_request = Rails.cache.fetch([ :extra_objects, srr_item_source_id, session[:grn_arrived_time].to_i ] )[:damage_request]

          if damage_request.present?

            damage_request.grn_item_id = grn_item.id
            damage_request.grn_batch_id = grn_item.grn_batches.first.id if grn_item.grn_batches.first.present?
            damage_request.grn_serial_item_id = grn_item.grn_serial_items.first.id if grn_item.grn_serial_items.first.present?
            damage_request.grn_serial_part_id = grn_item.grn_serial_parts.first.id if grn_item.grn_serial_parts.first.present?
            damage_request.product_condition_id = inventory_serial_item.product_condition_id if inventory_serial_item.present?

            damage_request.save!

            grn_item.remaining_quantity -= grn_item.damage_quantity

            grn_item.grn_serial_items.first.update remaining: false if grn_item.grn_serial_items.first.present?

            grn_item.grn_batches.first.update remaining_quantity: (grn_item.grn_batches.first.remaining_quantity - damage_request.quantity) if grn_item.grn_batches.first.present?  

            grn_item.grn_batches.first.update damage_quantity: damage_request.quantity if grn_item.grn_batches.first.present?      
          end

          # InventorySerialItem.find(inventory_serial_item.id).update_index
          inventory_serial_item.save! if inventory_serial_item.present? # it make anavailable item to available item 

        end

        grn_item.save! # this is to update index
        grn_item.update_relation_index

        Rails.cache.delete([ :extra_objects, srr_item_source_id, session[:grn_arrived_time].to_i ] )

        # inventory.update_index
        # InventoryProduct.find(grn_item.inventory_product.id).async.update_index # cached object doesnt have elasticsearch existance

      end

      if @grn.srr.present?
        @grn.srr.update closed: @grn.srr.srr_items.all?{ |i| i.closed }
      end

      @grn.async.update_index # It indexes all its children rather than @grn.update_index
      # Inventory.where(store_id: @grn.store_id, product_id: @grn.grn_items.pluck(:product_id)).async.import

      serial_inventories.group_by{|i| i[:id]}.each do |k, v|
        inventory = Inventory.find(k)
        inventory.stock_quantity += v.sum{|i| i[:stock_quantity].to_f }
        inventory.available_quantity += v.sum{|i| i[:available_quantity].to_f }
        inventory.damage_quantity += v.sum{|i| i[:damage_quantity].to_f }

        inventory.save
      end
      # serial_inventories.each(&:save) if serial_inventories.present?

      Srn.joins(:srn_items).where( store_id: @grn.store_id, inv_srn_item: {product_id: @grn.grn_items.pluck(:product_id)} ).where.not(closed: true, inv_srn_item: {closed: true}).each do |srn|
        srn.async(queue: 'index-model').update_index
      end

      srn_item_ids = []
      InventoryProduct.where(id: @grn.grn_items.pluck(:product_id).uniq).each do |product|
        product.async(queue: 'index-model').update_index
        srn_item_ids += product.srn_items.by_store(@grn.store_id).ids
      end # cached object doesnt have elasticsearch existance

      SrnItem.where(id: srn_item_ids.uniq).each{|s| s.async(queue: 'index-model').update_index}

      flash[:notice] = "Successfully saved."

      Rails.cache.delete([:po_item_ids, session[:grn_arrived_time].to_i])
      Rails.cache.fetch([:srr_item_source_ids, session[:grn_arrived_time].to_i])

      session[:po_id] = nil
      session[:store_id] = nil

      redirect_to grn_admins_inventories_url

    end

    def po
      Inventory
      Invoice

      if params[:prn_id].present?
        @prn = InventoryPrn.find params[:prn_id]
        @po = InventoryPo.new
        @prn.inventory_prn_items.where(closed: false).each do |prn_item|
          @po.inventory_po_items.build quantity: prn_item.quantity, prn_item_id: prn_item.id
        end
        @store = @prn.store
        render "admins/inventories/po/form"
      else
        refined_search = "closed:false"
        if params[:search].present?
          refined_prn = params[:search_prn].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")

          refined_search = [refined_prn, refined_search].map{|v| v if v.present? }.compact.join(" AND ")
        end
        params[:query] = refined_search

        @prns = InventoryPrn.search(params)
        # begin
        # rescue Exception => e
        #   flash[:alert] = "There are no Purchase recieve notes. Please generate and continue..."
        # end

        render "admins/inventories/po/search_prn"

      end
    end

    def prns
      Inventory
      Invoice
      Srn

      if params[:prn_id].present?
        @prn = InventoryPrn.find params[:prn_id]
        @store = @prn.store
        render "admins/inventories/prn/prns"
        # @prn.inventory_prn_items.where(closed: false).each do |prn_item|
        #   @po.inventory_po_items.build quantity: prn_item.quantity, prn_item_id: prn_item.id
        # end
      end
    end

    def create_po
      Organization
      Inventory
      @po = InventoryPo.new po_params
      @po.inventory_po_items.each{|po_item| @po.inventory_po_items.delete(po_item) if po_item.new_record? and po_item.quantity.to_f <= 0 }

      respond_to do |format|
        @prn = InventoryPrn.find params[:prn_id]
        @store = @prn.store

        if @po.save
          CompanyConfig.first.increase_inv_last_po_no
          @prn.inventory_prn_items.each do |prn_item|
            prn_item.update closed: true if prn_item.quantity <= prn_item.inventory_po_items.sum(:quantity)
          end
          @prn.update closed: @prn.inventory_prn_items.all?{ |e| e.closed }
          sleep 3

          # @prn.update_index

          flash[:notice] = "Successfully saved"
          format.html{ redirect_to po_admins_inventories_url }
        else
          flash[:alert] = "Unable to save. Please review."
          format.html{ render "admins/inventories/po/form"}
        end

      end
    end

    def search_grn
      Inventory
      Grn
      render "admins/inventories/grn/search_grn"
    end

    def grn_main_part
      Inventory
      Grn
      Organization
      @store = Organization.find params[:store_id] if params[:store_id].present?

      if params[:search].present?
        store_id = params[:store_id]

        refined_search_query = params[:search_inventory].except('inventory_product').map{|k, v| "#{k}:#{v}" if k.present? and v.present? }.compact.join(" AND ")
        refined_inventory_product = params[:search_inventory][:inventory_product].map { |k, v| "inventory_product.#{k}:#{v}" if v.present? }.compact.join(" AND ")
        # refined_inventory_serial_items = params[:search_inventory].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")

        refined_search = [refined_search_query, refined_inventory_product, "inventory.store_id:#{store_id}"].map{|v| v if v.present? }.compact.join(" AND ")
        params[:query] = refined_search

        @inventory_serial_items = InventorySerialItem.search(params)

      elsif params[:inventory_serial_item_id].present?
        @store = Organization.find params[:store_id]
        @inventory_serial_item = InventorySerialItem.find params[:inventory_serial_item_id]
        @grn_item = @inventory_serial_item.grn_items.first
        render "admins/inventories/grn/main_part/selected_main_part_form" and return

      elsif @store
        params[:query] = "inventory.store_id:#{@store.id}"
        @inventory_serial_items = InventorySerialItem.search(params)

      end
      render "admins/inventories/grn/main_part/search_main_part"

    end

    def create_grn_for_main_part
      Organization
      Inventory
      @grn = Grn.new store_id: params[:store_id], created_by: current_user.id, grn_no: CompanyConfig.first.increase_inv_last_grn_no
      @inventory_serial_item = InventorySerialItem.find params[:inventory_serial_item_id]
      @inventory_serial_item.attributes = inventory_serial_item_params


      @inventory_serial_item.inventory_serial_parts.each do |p|
        if p.new_record?

          p.grn_serial_parts.each do |gp|
            # gp.grn_item.current_unit_cost = gp.grn_item.unit_cost
            gp.grn_item.inventory_not_updated = true
            gp.grn_item.currency_id = p.inventory_product.inventory_product_info.currency_id
            gp.grn_item.product_id = p.product_id
            gp.grn_item.unit_cost = gp.grn_item.current_unit_cost
            gp.grn_item.recieved_quantity = 1
            gp.grn_item.remaining_quantity = 1
            gp.grn_item.grn = @grn

            gp.serial_item_id = @inventory_serial_item.id

            gp.grn_item.grn_item_current_unit_cost_histories.build current_unit_cost: gp.grn_item.current_unit_cost, created_by: current_user.id
          end
        end
      end

      @grn.save
      if @inventory_serial_item.save
        flash[:notice] = "Successfully saved."

      else
        flash[:alert] = "Unable to save. Please review submission again. #{@inventory_serial_item.errors.full_messages.join(', ')}"
      end
      redirect_to grn_main_part_admins_inventories_url
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
          @inventory_products = InventoryProduct.where.not(id: store_product_ids, non_stock_item: true ).where(updated_hash)
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
            @inventory.inventory_product.async.update_index
            params[:create] = nil
            @inventory = Inventory.new
            flash[:notice] = "Successfully saved."
          else
            flash[:alert] = "Unable to saved. Please review."
          end
        end
        @stores = Organization.stores
        @inventory_all = Kaminari.paginate_array(Inventory.order( store_id: :asc)).page(params[:page]).per(10)
        render "admins/inventories/inventory/inventory"

      end
    end

    def srns
      if params[:srn_id].present?
        Role
        Inventory
        @srn = Srn.find params[:srn_id]

        render "admins/inventories/srn/srns"
      end
    end

    def srrs
      Inventory
      Invoice
      Role
      if params[:srr_id].present?
        @srr = Srr.find params[:srr_id]

        render "admins/inventories/srr/srrs"
      end
    end

    def create_srn
      Role

      @srn = Srn.new srn_params
      if @srn.srn_items.any? and @srn.save
        Organization
        CompanyConfig.first.increase_inv_last_srn_no
        flash[:notice] = "Successfully created."
      else
        flash[:error] = "Unable to save. Please verify any validations and availabilities of SRN Item"
      end

      redirect_to srn_admins_inventories_url
    end

    def gin
      Role
      Srn
      Inventory
      Grn
      Organization
      case params[:gin_callback]

      when "search_srn"

        # refined_search = "closed:false"
        refined_search = ""

        if params[:search].present?
          refined_inventory_srn = params[:search_srn].map{ |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")

          refined_search = [refined_inventory_srn, refined_search].map{|v| v if v.present? }.compact.join(" AND ")

        end
        params[:query] = refined_search
        @srns = Srn.search(params)

        # search_srn = params[:search_srn].except("srn_date_from", "srn_date_to").map{|k, v| "#{k} like '%#{v}%'"}.join(" and ")

        # @srns = Srn.where(search_srn).where(closed: false)

        # @srns = @srns.where("created_at >= :start_date AND created_at <= :end_date AND closed = :closed", { start_date: params[:search_srn][:srn_date_from], end_date: params[:search_srn][:srn_date_to] }) if params[:search_srn][:srn_date_from].present? and params[:search_srn][:srn_date_to].present?

      when "select_srn"
        @srn = Srn.find params[:srn_id]
        @gin = @srn.gins.build store_id: @srn.store_id
        @srn.srn_items.where(closed: false).each do |srn_item|
          Rails.cache.delete([ :gin, :grn_serial_items, srn_item.id ])
          Rails.cache.delete([ :gin, :grn_batches, srn_item.id ])
          # not null: returned_quantity
          @gin.gin_items.build product_id: srn_item.product_id, srn_item_id: srn_item.id, returnable: srn_item.returnable, spare_part: srn_item.spare_part, main_product_id: srn_item.main_product_id, currency_id: srn_item.inventory_product.inventory_product_info.currency_id#, product_condition_id: srn_item., 
        end

      end

      if request.xhr?
        render "admins/inventories/gin/gin.js"
      else
        render "admins/inventories/gin/gin"
      end

    end

    def gins
      Inventory
      Invoice
      Role
      if params[:gin_id].present?
        @gin = Gin.find params[:gin_id]

        render "admins/inventories/gin/gins"
      end
    end

    def create_gin
      Srn
      Organization
      Inventory
      grn_item_ids = []
      inventories_array = []
      product_id_arrays = []
      grn_items_array = []

      @gin = Gin.new gin_params
      main_inventory_serial_part_id = params[:main_inventory_serial_part_id]

      @gin.gin_items.each{|gin_item| @gin.gin_items.delete(gin_item) if gin_item.new_record? and main_inventory_serial_part_id.blank? and gin_item.issued_quantity.to_f <= 0 }

      @gin.gin_items.each do |gin_item|
        if gin_item.srn_item.issue_terminated
          gin_item.issued_quantity = 0

          gin_item.srn_item.update closed: true

        end

        gin_item.issued_quantity ||= 0

        # gin_item.issued_quantity = gin_item.srn_item.gin_items.sum(:issued_quantity) if gin_item.issued_quantity > gin_item.srn_item.gin_items.sum(:issued_quantity)
        already_issued_quantities = gin_item.srn_item.gin_items.sum(:issued_quantity)
        store_requested_quantities = gin_item.srn_item.quantity

        still_to_issue = store_requested_quantities - already_issued_quantities

        gin_item.issued_quantity = still_to_issue if gin_item.issued_quantity.to_f > still_to_issue

        if main_inventory_serial_part_id.present? or gin_item.issued_quantity.to_f > 0
          if gin_item.srn_item.main_product_id.present?

            main_inventory_serial_part = InventorySerialPart.find_by_id(main_inventory_serial_part_id)

            if main_inventory_serial_part and [main_inventory_serial_part.inv_status_id, main_inventory_serial_part.inventory_serial_item.inv_status_id].all? { |id| id == InventorySerialItemStatus.find_by_code("AV").id }

              @product_id = main_inventory_serial_part.inventory_product.id

              main_product_id = main_inventory_serial_part.inventory_serial_item.product_id


              part_cost_price = main_inventory_serial_part.grn_serial_parts.active_serial_parts.first.grn_item.current_unit_cost.to_d + main_inventory_serial_part.inventory_serial_part_additional_costs.sum(:cost).to_d

              currency_id = main_inventory_serial_part.grn_serial_parts.active_serial_parts.first.grn_item.currency_id

              product_condition_id  = main_inventory_serial_part.product_condition_id


              @main_grn_serial_item_id = main_inventory_serial_part.inventory_serial_item.grn_serial_items.active_serial_parts.first.try(:id)

              main_inventory_serial_part.update inv_status_id: InventorySerialItemStatus.find_by_code("NA").id, updated_by: current_user.id

              main_inventory_serial_part.inventory_serial_item.update parts_not_completed: true, updated_by: current_user.id


              @grn_serial_part =  main_inventory_serial_part.grn_serial_parts.active_serial_parts.first

              @grn_serial_part_id =  @grn_serial_part.try(:id)

              @grn_item_id  = @grn_serial_part.try(:grn_item).try(:id)


              gin_item.attributes = {
              issued_quantity: 1,
              product_condition_id: product_condition_id,
              currency_id: currency_id,
              main_product_id: main_product_id,
              returned_quantity: 0,
              returnable: gin_item.srn_item.returnable,
              return_completed: false,
              spare_part: gin_item.srn_item.spare_part,
              inventory_not_updated: true
              }

              gin_source = gin_item.gin_sources.build(grn_item_id: @grn_item_id, issued_quantity: 1, unit_cost: part_cost_price, returned_quantity: 0, grn_serial_part_id: @grn_serial_part_id, main_part_grn_serial_item_id: @main_grn_serial_item_id )#inv_gin_source

            end

          else  
            store = @gin.store
            product = gin_item.inventory_product
            @inventory = product.inventories.find_by_store_id store.id
            # if product.inventory_product_info.need_serial #Issue Serial Item
            Rails.cache.fetch([ :gin, :grn_serial_items, gin_item.srn_item_id.to_i ]).to_a.each do |grn_serial_item|
              product_id = grn_serial_item.inventory_serial_item.product_id

              tot_cost_price = grn_serial_item.grn_item.current_unit_cost.to_d + grn_serial_item.inventory_serial_item.inventory_serial_items_additional_costs.sum(:cost).to_d #inventory_serial_items_additional_costs
              gin_item.currency_id  = grn_serial_item.grn_item.currency_id

              # grn_serial_item.grn_item.decrement! :remaining_quantity, 1
              # grn_serial_item.grn_item.remaining_quantity -= 1 #grn_item has to save
              grn_items_array << {id: grn_serial_item.grn_item.id, remaining_quantity: 1}

              grn_serial_item.remaining = false #grn_serial_item has to save

              grn_serial_item.inventory_serial_item.inv_status_id = InventorySerialItemStatus.find_by_code("NA").id
              grn_serial_item.inventory_serial_item.updated_by = current_user.id #inventory serial item has to save

              # grn_serial_item.inventory_serial_item.inventory.stock_quantity -= 1
              # grn_serial_item.inventory_serial_item.inventory.available_quantity -= 1
              inventory = grn_serial_item.inventory_serial_item.inventory
              inventories_array << {id: inventory.id, stock_quantity: 1, available_quantity: 1}

              gin_item.gin_sources.build(grn_item_id: grn_serial_item.grn_item_id, grn_serial_item_id: grn_serial_item.id, issued_quantity: 1, unit_cost: tot_cost_price, returned_quantity: 0)#inv_gin_source

              gin_item.inventory_not_updated = false

            end

            # elsif product.inventory_product_info.need_batch #Issue Batch Item
            Rails.cache.fetch([ :gin, :grn_batches, gin_item.srn_item_id.to_i ]).to_a.each do |grn_batch|
              gin_source = grn_batch.gin_sources.select{|g| g.new_record? }.first
              # gin_source = grn_batch.gin_sources.build

              grn_batch_issued_qty = gin_source.issued_quantity.to_f

              if grn_batch.remaining_quantity > 0 and grn_batch.remaining_quantity.to_f >= grn_batch_issued_qty.to_f# and grn_batch.grn_item.grn.store_id == gin.store_id
                product_id = grn_batch.grn_item.product_id

                tot_cost_price  = grn_batch.grn_item.current_unit_cost
                gin_item.currency_id  = grn_batch.grn_item.currency_id

                # iss_grn_serial_item_id  = nil
                iss_grn_item_id  = grn_batch.grn_item_id


                grn_batch.remaining_quantity = ( grn_batch.remaining_quantity.to_f-grn_batch_issued_qty.to_f )
                # grn_batch.grn_item.remaining_quantity -= grn_batch_issued_qty # has to save grn_item
                # grn_item_ids << grn_batch.grn_item.id
                grn_items_array << {id: grn_batch.grn_item.id, remaining_quantity: grn_batch_issued_qty}


                # grn_batch.inventory_batch.inventory.stock_quantity -= grn_batch_issued_qty# if @inventory.present? has to save inventory
                # grn_batch.inventory_batch.inventory.available_quantity -= grn_batch_issued_qty# if @inventory.present? has to save inventory

                # inventories_array << grn_batch.inventory_batch.inventory
                inventory = grn_batch.inventory_batch.inventory
                inventories_array << {id: inventory.id, stock_quantity: grn_batch_issued_qty, available_quantity: grn_batch_issued_qty}


                gin_item.inventory_not_updated = false

                gin_source.attributes = gin_source.attributes.merge(grn_item_id: iss_grn_item_id, unit_cost: tot_cost_price, returned_quantity: 0)#inv_gin_source                    
                gin_source.gin_item = gin_item

              end
            end

            if !(product.inventory_product_info.need_batch or product.inventory_product_info.need_serial) #Issue Non Serial / Non Batch Item
              @grn_items = product.grn_items.joins(:grn).where("inventory_not_updated = false and remaining_quantity > 0 and inv_grn.store_id = #{store.id}").order("inv_grn.created_at #{product.fifo ? 'ASC' : 'DESC' }")
              grn_item_ids += @grn_items.ids

              iss_quantity1 = 0
              @grn_items.each do |grn_item|
                grn_item_issued_qty = grn_item.remaining_quantity >= (gin_item.issued_quantity.to_f - iss_quantity1) ? (gin_item.issued_quantity.to_f - iss_quantity1) : grn_item.remaining_quantity

                if grn_item.remaining_quantity >= grn_item_issued_qty and (gin_item.issued_quantity.to_f > iss_quantity1)# and grn_item.grn.store_id == gin.store_id
                  # product_id = grn_item.product_id

                  tot_cost_price  = grn_item.current_unit_cost

                  grn_item.remaining_quantity -= grn_item_issued_qty # has to save grn_item


                  if @inventory.present?
                    # @inventory.stock_quantity -= grn_item_issued_qty if @inventory.present? # has to save @inventory
                    # @inventory.available_quantity -= grn_item_issued_qty if @inventory.present? # has to save @inventory
                    # inventories_array << @inventory
                    inventory = @inventory
                    inventories_array << {id: inventory.id, stock_quantity: grn_item_issued_qty, available_quantity: grn_item_issued_qty}

                  end

                  gin_item.inventory_not_updated = false

                  gin_item.gin_sources.build(grn_item_id: grn_item.id, issued_quantity: grn_item_issued_qty, unit_cost: tot_cost_price, returned_quantity: 0)#inv_gin_source

                  iss_quantity1 += grn_item_issued_qty

                  grn_item.save

                end
              end
              gin_item.issued_quantity = iss_quantity1
            end

            # product.async.update_index
            # @inventory.async.update_index

          end
        end

        gin_item.returned_quantity = 0

        # gin_item.srn_item.closed = (gin_item.srn_item.quantity <= gin_item.srn_item.gin_items.sum(:issued_quantity) + gin_item.issued_quantity.to_f)

      end

      if @gin.gin_items.any? 
        @gin.attributes = @gin.attributes.merge(created_by: current_user.id, gin_no: CompanyConfig.first.increase_inv_last_gin_no )#inv_gin
        @gin.save!

        @gin.gin_items.each do |gin_item|
          serial_inventory_ids = []

          Rails.cache.fetch([ :gin, :grn_serial_items, gin_item.srn_item_id.to_i ]).to_a.each do |grn_serial_item|
            grn_serial_item.save!

            grn_serial_item.inventory_serial_item.save!
            # grn_serial_item.grn_item.async(queue: 'index-model').save!
          end

          Rails.cache.fetch([ :gin, :grn_batches, gin_item.srn_item_id.to_i ]).to_a.each do |grn_batch|
            # to update index fot batches
            serial_inventory_ids << grn_batch.inventory_batch.inventory.id

            # grn_batch.grn_item.async(queue: 'index-model').save!
            grn_batch.inventory_batch.inventory.save!
            grn_batch.save!
            # grn_batch.inventory_batch.inventory_product.update_index
            # inventories_array.each(&:save) if inventories_array.present?

          end

          product = gin_item.inventory_product

          if !(product.inventory_product_info.need_batch or product.inventory_product_info.need_serial)
            GrnItem.where(id: grn_item_ids.uniq).each {|grn_item| grn_item.async(queue: 'index-model').update_index } if grn_item_ids.present?
            # Inventory.where(id: inventory_ids.uniq).import if inventory_ids.present?
            # inventories_array.each(&:save) if inventories_array.present?
          end

          # gin_item.srn_item.update closed: (gin_item.srn_item.quantity <= gin_item.srn_item.gin_items.sum(:issued_quantity) + gin_item.issued_quantity.to_f)
          gin_item.srn_item.update closed: (gin_item.srn_item.quantity <= gin_item.srn_item.gin_items.sum(:issued_quantity))

          Rails.cache.delete([ :gin, :grn_serial_items, gin_item.srn_item_id.to_i ])
          Rails.cache.delete([ :gin, :grn_batches, gin_item.srn_item_id.to_i ])

        end


        grn_items_array.group_by{|i| i[:id]}.each do |k, v|
          grn_item = GrnItem.find(k)
          grn_item.remaining_quantity -= v.sum{|i| i[:remaining_quantity].to_f }

          grn_item.save!
        end

        inventories_array.group_by{|i| i[:id]}.each do |k, v|
          inventory = Inventory.find(k)
          product_id_arrays << inventory.product_id

          inventory.stock_quantity -= v.sum{|i| i[:stock_quantity].to_f }
          inventory.available_quantity -= v.sum{|i| i[:available_quantity].to_f }

          inventory.save!
        end

        InventoryProduct.where(id: product_id_arrays.uniq).each do |product|
          product.async(queue: 'index-model').update_index
        end

        @gin.srn.update closed: @gin.srn.srn_items.all?{|srn_item| srn_item.closed }

        flash[:notice] = "Issued."
      else
        flash[:error] = "Issue Failed."
      end

      redirect_to gin_admins_inventories_url
    end

    def serial_item_or_part
      Inventory

      items = {}
      item_product_id = params[:item_product_id]

      case params[:item_type]
      when "serial_item"
        product = InventoryProduct.find params[:item_id]

        items.merge! items: product.inventory_serial_items.joins(:inventory_serial_parts).where(inv_inventory_serial_part: {inv_status_id: 1, product_id: item_product_id}, inv_status_id: 1).map.with_index { |i, index| {index: (index+1), serialNo: i.generated_serial_no, ctNo: i.ct_no, partsNotCompleted: i.parts_not_completed, damage: i.damage, scavenge: i.scavenge, used: i.used, repaired: i.repaired, status: i.inventory_serial_item_status.name, action: view_context.link_to("select", "javascript:void(0)", onclick: "Admins.select_serial_item_or_part_in_srn(this, 'serial_part', '#{i.id}', 'false', '#{item_product_id}'); return false;") }}# if i.inventory_serial_parts.where(inv_status_id: 1, product_id: item_product_id).present? }.compact

      when "serial_part"

        serial_item = InventorySerialItem.find params[:item_id]

        item_info = {productDescription: serial_item.inventory_product.description, productSerialNo: serial_item.inventory_product.generated_serial_no, inventoryName: serial_item.inventory.store_name, serialNo: serial_item.serial_no}

        items.merge! items: serial_item.inventory_serial_parts.where(inv_status_id: 1, product_id: item_product_id).map.with_index { |i, index| {index: (index+1), serialNo: i.serial_no, ctNo: i.ct_no, partsNotCompleted: i.parts_not_completed, damage: i.damage, scavenge: i.scavenge, used: i.used, repaired: i.repaired, status: i.inventory_serial_item_status.name, action: view_context.link_to("select", "javascript:void(0)", onclick: "Admins.select_serial_item_or_part_in_srn(this, 'serial_part_selected', '#{i.id}'); return false;", data: {info: {item: item_info, part: {productDescription: i.inventory_product.description, serialNo: i.serial_no, ct_no: i.ct_no}}} ) } }, back: view_context.link_to("Back", "javasctipt.void(0)", onclick: "Admins.select_serial_item_or_part_in_srn(this, 'serial_item', '#{serial_item.product_id}', 'false', '#{item_product_id}'); return false;")

      end
      render json: items

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
          @count = params[:recieved_quantity].values.sum{|i| i.to_f }
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

      # @grn_items = GrnItem.search(query: "inventory_product.id:#{@product.id} AND inventory_not_updated:false AND remaining_quantity:>0 AND grn.store_id:#{@store.id} AND grn_serial_items.remaining:true")

      # @grn_items = GrnItem.search(query: "inventory_not_updated:false AND remaining_quantity:>0 AND grn.store_id:#{@store.id}")
      render "admins/inventories/gin/batch_or_serial_for_gin"

    end

    def prn
      Inventory
      Srn
      Organization

      case params[:srn]
      when "yes"
        @render_template = "main_prn"
      when "no"
        Rails.cache.delete(session[:prn_srn_arrived_time]) if session[:prn_srn_arrived_time].present?

        session[:prn_srn_arrived_time] = nil

        @render_template = "with_srn"
      when "search_srn"
        session[:page] = params[:page] ? params[:page].to_i + 1 : nil
        if params[:search].present?
          refined_search = "closed:false"
          refined_inventory_product = params[:search_inventory][:srn_item].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
          refined_search = [refined_inventory_product, refined_search].map{|v| v if v.present? }.compact.join(" AND ")

          params[:query] = refined_search

        end
        @srn_items = SrnItem.search(params)
      end

      if params[:store_id].present?
        @store = Organization.find params[:store_id]
        @prn = InventoryPrn.new
        @render_template = "main_prn"
      end
      if params[:store_id_with_srn].present?
        @store = Organization.find params[:store_id_with_srn]
        @render_template = "with_srn"
      end
      respond_to do |format|
        format.html {render "admins/inventories/prn/prn"}
        format.js {render "admins/inventories/prn/prn"}
      end
    end

    def submit_selected_products
      Inventory
      Srn
      Gin
      Organization

      if params[:done].present?
        session[:prn_srn_arrived_time] ||= Time.now.strftime("%H%M%S")

        params[:with_srn] = "no"
        @store = Organization.find params[:store_id_with_srn]
        @prn = InventoryPrn.new
        @srn_item_array = []
        prn_items_attributes = []

        params[:srn_item_ids].to_a.each do |srn_item_id|
          srn_item = SrnItem.find(srn_item_id)

          prn_items_attributes << {product_id: srn_item.product_id, quantity: srn_item.quantity, srn_item: srn_item}

        end


        prn_items_attributes.group_by{|e| e[:product_id]}.each do |k, v|

          prn_item = @prn.inventory_prn_items.build quantity: v.sum{|e| e[:quantity]}, product_id: k
          # prn_item.prn_item_object_id = prn_item.object_id

          @srn_item_array << {srn_items: v.map { |e| e[:srn_item] }, prn_item_object_id: prn_item.object_id }
        end

        Rails.cache.write(session[:prn_srn_arrived_time], @srn_item_array)

        # if params[:products_ids].present?
        #   inventory_product = InventoryProduct.where(id: params[:products_ids])
        #   puts inventory_product.country_id
          # Rails.cache.delete([:contract_products, request.remote_ip])

          # @cached_products = Rails.cache.fetch([:contract_products, request.remote_ip]){ inventory_product.to_a }
        # end
      end

      if params[:srn_form] == "yes"
        @srn_form_show = true
      end
      respond_to do |format|
        format.html {render "admins/inventories/prn/prn"}
        format.js {render "admins/inventories/prn/prn"}
      end
    end

    def create_prn
      Organization
      Inventory
      @prn = InventoryPrn.new prn_params

      respond_to do |format|
        if @prn.inventory_prn_items.any? and @prn.save
          if session[:prn_srn_arrived_time].present?
            Rails.cache.fetch(session[:prn_srn_arrived_time]).to_a.each do |item_element|
              prn_item = @prn.inventory_prn_items.select{|prn_item|prn_item.prn_item_object_id.to_i == item_element[:prn_item_object_id].to_i }.first

              if prn_item.present?
                prn_item.srn_items << item_element[:srn_items]
                prn_item.srn_items.import
              end

            end
          end

          CompanyConfig.first.increase_inv_last_prn_no
          flash[:notice] = "Successfully saved"

          if session[:prn_srn_arrived_time].present?
            Rails.cache.delete(session[:prn_srn_arrived_time])
            session[:prn_srn_arrived_time] = nil
          end

        else
          flash[:alert] = "Unable to save. Please check whether items are validated. There must be atleast one item."
        end

        format.html{ redirect_to prn_admins_inventories_url }
      end
    end

    def update_grn_cost
      Inventory
      User
      Grn
      @grnitem = GrnItem.find params[:grnitem_id]
      @grnitem.update grn_item_params
      # @grnitem.update current_unit_cost: @grnitem.grn_item_current_unit_cost_histories.order(created_at: :desc).first.current_unit_cost
      render "admins/searches/grn/change_cost"
    end

    def create_additional_cost
      Inventory
      @cost_parent = InventorySerialItem.find params[:id]
      if @cost_parent.update inventory_serial_item_params
        flash[:notice] = "Successfully saved."
      else
        flash[:alert] = "Unable to save. Please review."
      end

      case params[:type]
      when "InventorySerialItem"
        template = inventories_admins_searches_url(select_action: "select_serial_item_more", inventory_serial_item_id: @cost_parent.id, store_id: params[:store_id] )
      when "InventorySerialPart"
        template = inventories_admins_searches_url(select_action: "select_inventory_serial_part_more", inventory_serial_part_id: params[:serial_part_id], store_id: params[:store_id] )

      end
        redirect_to template
    end

    def srr
      if params[:gin_id].present?
        Inventory
        @gin = Gin.find params[:gin_id]

        @srr = Srr.new store_id: @gin.store.id, created_by: current_user.id, requested_module_id: @gin.srn.try(:requested_module_id)

        @saveable = false
        srr_item_sources_availability = []

        @gin.gin_items.each do |gin_item|

          gin_item.gin_sources.each do |gin_source|
            if gin_source.returned_quantity.to_f < gin_source.issued_quantity.to_f
              srr_item = @srr.srr_items.build product_id: gin_item.product_id, product_condition_id: gin_item.product_condition_id, spare_part: gin_item.spare_part, currency_id: gin_item.currency_id
              srr_item.returned_quantity = gin_item.gin_sources.sum(:returned_quantity)
              srr_item.issued_quantity = gin_item.gin_sources.sum(:issued_quantity)

              srr_item.srr_item_sources.build gin_source_id: gin_source.id, unit_cost: gin_source.grn_item.unit_cost, currency_id: gin_source.grn_item.currency_id#, returned_quantity: gin_source.returned_quantity, 
              srr_item_sources_availability << srr_item.srr_item_sources.present?

            end

          end


        end

        @saveable = srr_item_sources_availability.include?(true)

      else
        @remote = true

      end

      render "admins/inventories/srr/srr"

    end

    def create_srr
      @srr = Srr.new srr_params

      @srr.srr_items.each do |srr_item|
        if srr_item.new_record? and srr_item.quantity.to_f <= 0
          @srr.srr_items.delete(srr_item)

        else
          srr_item.srr_item_sources.each do |srr_item_source|
            srr_item.srr_item_sources.delete(srr_item_source) if srr_item_source.new_record? and srr_item_source.returned_quantity.to_f <= 0
          end

        end

      end
      # @srr.attributes = {}
      if @srr.srr_items.present?
        if @srr.save
          @srr.srr_item_sources.each do |srr_item_source|
            srr_item_source.gin_source.increment! :returned_quantity, srr_item_source.returned_quantity.to_f
            srr_item_source.gin_source.gin_item.increment! :returned_quantity, srr_item_source.returned_quantity.to_f
          end

          CompanyConfig.first.increase_inv_last_srr_no

          flash[:success] = "Successfully saved."
        else
          flash[:alert] = "Unable to save. Please try again"
        end
      else
        flash[:alert] = "There are no item to return. Please try with any returnable item (s)"

      end

      redirect_to srr_admins_inventories_url
    end


    def srn
      Organization
      Role
      Inventory
      @store = Organization.find params[:store_id] if params[:store_id].present?
      case params[:srn_callback]
      when "call_search"
        Inventory
        @modal_active = true
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
        params.require(:inventory_product).permit(:generated_serial_no, :category3_id, :serial_no, :serial_no_order, :sku, :legacy_code, :description, :model_no, :product_no, :spare_part_no, :fifo, :active, :spare_part, :unit_id, :created_by, :updated_by, :non_stock_item, inventory_product_info_attributes: [:picture, :secondary_unit_id, :issue_fractional_allowed, :per_secondery_unit_conversion, :need_serial, :need_batch, :country_id, :manufacture_id, :average_cost, :standard_cost, :currency_id, :remarks])
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
        params.require(:grn_item).permit(:id, :recieved_quantity, :product_id, :unit_cost, :remarks, :current_user_id, grn_item_current_unit_cost_histories_attributes: [:id, :current_unit_cost, :created_by, :created_at], grn_batches_attributes: [:id, :recieved_quantity, :remaining_quantity, :_destroy, inventory_batch_attributes: [:id, :_destroy, :inventory_id, :product_id, :created_by, :lot_no, :batch_no, :manufatured_date, :expiry_date, :remarks, inventory_batch_warranties_attributes: [:id, :_destroy, inventory_warranty_attributes: [:id, :_destroy, :created_by, :start_at, :end_at, :period_part, :period_labour, :period_onsight, :remarks, :warranty_type_id]] ]], grn_serial_items_attributes: [:id, :_destroy, :recieved_quantity, :remaining, inventory_serial_item_attributes: [:id, :_destroy, :inventory_id, :product_id, :inv_status_id, :created_by, :serial_no, :ct_no, :manufatured_date, :expiry_date, :scavenge, :parts_not_completed, :damage, :used, :repaired, :reserved, :product_condition_id, :remarks, inventory_serial_warranties_attributes: [:id, :_destroy, inventory_warranty_attributes: [:id, :_destroy, :created_by, :start_at, :end_at, :period_part, :period_labour, :period_onsight, :remarks, :warranty_type_id]]]])
      end

      def inventory_serial_item_params
        params.require(:inventory_serial_item).permit(:id, :inventory_id, :product_id, :inv_status_id, :created_by, :serial_no, :ct_no, :manufatured_date, :expiry_date, :scavenge, :parts_not_completed, :damage, :used, :repaired, :reserved, :product_condition_id, :remarks, inventory_serial_warranties_attributes: [:id, :_destroy, inventory_warranty_attributes: [:id, :_destroy, :created_by, :start_at, :end_at, :period_part, :period_labour, :period_onsight, :remarks, :warranty_type_id]], inventory_serial_items_additional_costs_attributes: [:id, :_destroy, :cost, :note, :currency_id, :created_by, ], grn_serial_items_attributes: [:id, :_destroy, grn_item_attributes: [:_destroy, :main_product_id, :unit_cost, :remarks, :id, :current_user_id]  ], inventory_serial_parts_attributes: [ :id, :product_id, :_destroy, :serial_no, :ct_no, :manufatured_date, :expiry_date, :product_condition_id, :inv_status_id, :created_by, :scavenge, :damage, :used, :repaired, :reserved, :added, :parts_not_completed, :remarks, grn_serial_parts_attributes: [:id, :_destroy, :serial_item_id, grn_item_attributes: [:id, :_destroy, :recieved_quantity, :remaining_quantity, :current_unit_cost, :currency_id, :product_id, :current_user_id, :main_product_id, :unit_cost, :remarks]], inventory_serial_part_warranties_attributes: [ :id, :_destroy, inventory_warranty_attributes: [:id, :_destroy, :warranty_type_id, :start_at, :end_at, :period_part, :period_labour, :period_onsight, :remarks, :created_by]], inventory_serial_part_additional_costs_attributes: [:id, :_destroy, :cost, :note, :currency_id, :created_by] ] )
      end

      def grn_params
        params.require(:grn).permit(:remarks, :po_id, :po_no, :supplier_id, :srn_id, :srr_id)
      end

      def srn_params
        srn_params = params.require(:srn).permit(:id, :srn_no, :requested_module_id, :created_by, :store_id, :required_at, :remarks, :so_no, :so_customer_id, srn_items_attributes: [:id, :product_id, :main_product_id, :quantity, :remarks, :_destroy, :returnable, :spare_part, :issue_terminated, :issue_terminated_reason_id])
        srn_params[:current_user_id] = current_user.id
        srn_params
      end

      def gin_params
        params.require(:gin).permit(:id, :store_id, :srn_id, :remarks, gin_items_attributes: [:id, :_destroy, :product_id, :main_product_id, :srn_item_id, :issued_quantity, :product_condition_id, :remarks, :returnable, :spare_part, :currency_id ])
      end

      def prn_params
        prn_params = params.require(:inventory_prn).permit(:id, :store_id, :created_by, :prn_no, :required_at, :remarks, inventory_prn_items_attributes: [:id, :product_id, :_destroy, :quantity, :remarks, :prn_item_object_id])
        prn_params[:current_user_id] = current_user.id
        prn_params
      end

      def po_params
        po_params = params.require(:inventory_po).permit(:id, :created_by, :store_id, :supplier_id, :po_no, :delivery_date, :your_ref, :payment_term_id, :discount_amount, :currency_id, :remarks, :deliver_to, :delivery_date_text, :quotation_no, :delivery_mode, :closed, inventory_po_items_attributes: [ :id, :_destroy, :prn_item_id, :quantity, :unit_cost, :unit_id, :unit_cost_grn, :remarks, :description, :closed, inventory_po_item_taxes_attributes: [ :id, :_destroy, :po_item_id, :tax_id, :tax_rate, :amount ], inventory_prn_item_attributes: [ :id, :_destroy, :closed, inventory_prn_attributes: [ :id, :_destroy, :closed ] ],  ] )
        po_params[:current_user_id] = current_user.id
        po_params
      end

      def srr_params
        params.require(:srr).permit(:created_by, :srr_no, :store_id, :requested_module_id, :remarks, srr_items_attributes: [ :id, :product_id, :product_condition_id, :spare_part, :currency_id, :return_reason_id, :remarks, :quantity, :current_user_id, :_destroy, srr_item_sources_attributes: [ :id, :_destroy, :unit_cost, :currency_id, :returned_quantity, :gin_source_id] ])
      end

  end
end